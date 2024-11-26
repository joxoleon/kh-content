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
    
    func testSendBatchPrompt() async throws {
        // Given
        let batchPromptRequest = BatchPromptRequest(
            model: "gpt-4o-mini",
            prompts: [
                "What is the capital of France?",
                "What is the capital of Germany?",
                "What is the capital of Italy?"
            ],
            temperature: 0.5,
            maxTokens: 10
        )

        // When
        do {
            let responses = try await openAIService.sendBatchPrompts(request: batchPromptRequest)
            print("Response count: \(responses.count)")

            // Then
            XCTAssertTrue(responses.count == 3, "There should be 3 responses.")
            XCTAssertTrue(responses[0].responseString.lowercased().contains("paris"), "The response should contain 'Paris'.")
            XCTAssertTrue(responses[1].responseString.lowercased().contains("berlin"), "The response should contain 'Berlin'.")
            XCTAssertTrue(responses[2].responseString.lowercased().contains("rome"), "The response should contain 'Rome'.")
        } catch {
            XCTFail("API call failed with error: \(error)")
        }
    }
}
