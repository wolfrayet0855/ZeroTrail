//
//  ContentView.swift
//  ZeroTrail
//
//  Created by user on 10/15/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            Task {
                let api = ChatGPTAPI(apiKey: String = try Configuration.value(for: "API_KEY"))
                do {
                    let stream = try await api.sendMessageStream(text: "Who is James Bond?")
                    for try await line in stream {
                        print(line)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            
        }
    }
}

#Preview {
    ContentView()
}
