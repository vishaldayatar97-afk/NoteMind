//
//  AIService.swift
//  NoteMind
//
//  Created by VishalD. on 14/08/26.
//

import Foundation

// MARK: - AI Service Error

enum AIServiceError: Error {
    case invalidURL
    case invalidResponse
    case serverError
    case invalidData
    case emptyResponse
}

// MARK: - AI Response

struct AISummaryResponse {
    let summary: String
    let keyPoints: [String]
}

// MARK: - AI Service

final class AIService {

    // MARK: - Properties

    private let session: URLSession

    // Local FastAPI backend
    // Your local NoteMind backend endpoint
    private let endpoint = URL(
        string: "http://127.0.0.1:8000/api/summarize"
        )

    // MARK: - Init

    init(
        session: URLSession = .shared
    ) {
        self.session = session
    }

    // MARK: - Generate Summary

    func generateSummary(
        for note: Note,
        completion: @escaping (
            Result<AISummaryResponse, Error>
        ) -> Void
    ) {

        guard let endpoint = endpoint else {
            completion(
                .failure(
                    AIServiceError.invalidURL
                )
            )
            return
        }

        var request = URLRequest(
            url: endpoint
        )

        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let requestBody = [
            "title": note.title,
            "content": note.content
        ]

        do {

            request.httpBody = try JSONSerialization.data(
                withJSONObject: requestBody
            )

        } catch {

            completion(
                .failure(error)
            )

            return
        }

        session.dataTask(
            with: request
        ) { data, response, error in

            if let error = error {

                DispatchQueue.main.async {
                    completion(
                        .failure(error)
                    )
                }

                return
            }

            guard let httpResponse =
                    response as? HTTPURLResponse else {

                DispatchQueue.main.async {
                    completion(
                        .failure(
                            AIServiceError.invalidResponse
                        )
                    )
                }

                return
            }

            guard (200...299).contains(
                httpResponse.statusCode
            ) else {

                DispatchQueue.main.async {
                    completion(
                        .failure(
                            AIServiceError.serverError
                        )
                    )
                }

                return
            }

            guard let data = data else {

                DispatchQueue.main.async {
                    completion(
                        .failure(
                            AIServiceError.invalidData
                        )
                    )
                }

                return
            }

            do {

                let decodedResponse =
                    try JSONDecoder().decode(
                        AISummaryAPIResponse.self,
                        from: data
                    )

                let result = AISummaryResponse(
                    summary: decodedResponse.summary,
                    keyPoints: decodedResponse.keyPoints
                )

                DispatchQueue.main.async {
                    completion(
                        .success(result)
                    )
                }

            } catch {

                DispatchQueue.main.async {
                    completion(
                        .failure(error)
                    )
                }
            }

        }.resume()
    }
}

// MARK: - API Response Model

private struct AISummaryAPIResponse: Codable {

    let summary: String
    let keyPoints: [String]
}
