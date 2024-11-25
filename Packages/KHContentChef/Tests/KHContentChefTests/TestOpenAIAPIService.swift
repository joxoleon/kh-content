//
//  File.swift
//  KHContentChef
//
//  Created by Jovan Radivojsa on 25.11.24..
//

import Foundation
import XCTest
@testable import KHContentChef

final class OpenAIAPIServiceTests: XCTestCase {

    private var openAIService: OpenAIAPIService!

    override func setUpWithError() throws {
        super.setUp()
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("API key not set in environment variables.")
        }
        print("API Key: \(apiKey)")
        openAIService = OpenAIAPIService(apiKey: apiKey)
    }

    func testSendPrompt() async throws {
        // Given
        let promptRequest = PromptRequest(
            model: "gpt-4o-mini",
            prompt: "What is the capital of France?",
            temperature: 0.5,
            maxTokens: 10
        )

        // When
        do {
            let response = try await openAIService.sendPrompt(request: promptRequest)
            print("Response: \(response.responseString)")

            // Then
            XCTAssertTrue(response.responseString.lowercased().contains("paris"), "The response should contain 'Paris'.")
        } catch {
            XCTFail("API call failed with error: \(error)")
        }
    }
}
