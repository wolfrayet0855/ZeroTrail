
import Foundation

enum ChatGPTError: Error {
    case invalidResponse
    case badResponse(statusCode: Int)
    case parsingError
    case networkError(message: String)
    case unknownError(message: String)
}

struct ChatRequestBody: Codable {
    let model: String
    let messages: [[String: String]]
    let temperature: Double
    let max_tokens: Int
    let stream: Bool
}

class ChatGPTAPI {
    
    private let apiKey: String
    private let urlSession = URLSession.shared
    private let baseURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private let jsonDecoder = JSONDecoder()
    private let basePrompt = "You are ChatGPT, a large language model trained by OpenAI. Be as concise as possible."
    
    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private func generateMessages(from text: String) -> [[String: String]] {
        return [
            ["role": "system", "content": basePrompt],
            ["role": "user", "content": text]
        ]
    }
    
    private func jsonBody(text: String, stream: Bool = true) throws -> Data {
        let body = ChatRequestBody(
            model: "gpt-4-turbo",
            messages: generateMessages(from: text),
            temperature: 0.5,
            max_tokens: 1024,
            stream: stream
        )
        return try JSONEncoder().encode(body)
    }
    
    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        urlRequest.httpBody = try jsonBody(text: text)
        
        let (result, response) = try await urlSession.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatGPTError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            let errorData = try await urlSession.data(for: urlRequest).0
            let responseBody = String(data: errorData, encoding: .utf8) ?? "No response body"
            print("Error Response Body: \(responseBody)")
            throw ChatGPTError.badResponse(statusCode: httpResponse.statusCode)
        }
        
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await line in result.lines {
                        if let dataStart = line.range(of: "data:") {
                            let jsonString = line[dataStart.upperBound...].trimmingCharacters(in: .whitespaces)
                            guard jsonString != "[DONE]", !jsonString.isEmpty else {
                                continuation.finish()
                                break
                            }
                            if let jsonData = jsonString.data(using: .utf8),
                               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                               let choices = jsonObject["choices"] as? [[String: Any]],
                               let delta = choices.first?["delta"] as? [String: Any],
                               let content = delta["content"] as? String {
                                continuation.yield(content)
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
