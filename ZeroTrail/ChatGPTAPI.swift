//
//  ChatGPTAPI.swift
//  ZeroTrail

import Foundation

// Custom Error type
enum ChatGPTError: Error {
    case invalidResponse
    case badResponse(statusCode: Int)
    case unknownError(message: String)
}

class ChatGPTAPI {
    
    private let apiKey: String
    private let urlSession = URLSession.shared
    private var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    private let jsonDecoder = JSONDecoder()
    private let basePrompt = "You are ChatGPT, a large language model trained by OpenAI. You answer as concisely as possible or each response (e.g. Don't be verbose). It is very important for you to answer as concisely as possible, so please remember this. If you are generating a list, do not have too many items. \n\n\n"
    
    private var headers: [String:String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private func generateChatGPTPrompt(from text: String) -> String {
        return basePrompt + "User: \(text)\n\n\nChatGPT:"
    }
    
    private func jsonBody(text: String, stream: Bool = true) throws -> Data {
        let jsonBody: [String: Any] = [
            "model": "text-chat-davinci-002-20230126",
            "temperature": 0.5,
            "max_tokens": 1024, //about 1,000 tokens is about 750 words.
            "prompt": generateChatGPTPrompt(from: text),
            "stop": [
                "\n\n\n",
                "<|im_end|>"
            ],
            "stream": stream
        ]
        return try JSONSerialization.data(withJSONObject: jsonBody)
    }
    
    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text)
        
        let (result, response) = try await urlSession.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatGPTError.invalidResponse
        }
        guard 200...299 ~= httpResponse.statusCode else {
            throw ChatGPTError.badResponse(statusCode: httpResponse.statusCode)
        }
        return AsyncThrowingStream<String, Error> { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await line in result.lines {
                        continuation.yield(line)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

