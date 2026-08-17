//
//  AISummaryViewController.swift
//  NoteMind
//
//  Created by VishalD. on 12/08/26.
//
import UIKit

class AISummaryViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var keyPointsTitleLabel: UILabel!
    @IBOutlet weak var keyPointsLabel: UILabel!
    @IBOutlet weak var copySummaryButton: UIButton!

    // MARK: - Properties

    var note: Note?

    private let activityIndicator = UIActivityIndicatorView(
        style: .medium
    )

    private let aiService = AIService()

    // MARK: - Navigation Bar

    private var regenerateBarButton: UIBarButtonItem?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupLoadingIndicator()
        setupRegenerateButton()

        showLoadingState()
        generateAISummary()
    }

    // MARK: - UI Setup

    private func setupUI() {

        summaryTitleLabel.text = "Summary"
        keyPointsTitleLabel.text = "Key Points"

        summaryLabel.numberOfLines = 0
        keyPointsLabel.numberOfLines = 0

        summaryLabel.text = ""
        keyPointsLabel.text = ""

        summaryLabel.textColor = .label
        keyPointsLabel.textColor = .label

        copySummaryButton.isHidden = true
    }

    // MARK: - Navigation Bar Button

    private func setupRegenerateButton() {

        regenerateBarButton = UIBarButtonItem(
            image: UIImage(
                systemName: "arrow.clockwise"
            ),
            style: .plain,
            target: self,
            action: #selector(
                regenerateButtonPressed
            )
        )

        navigationItem.rightBarButtonItem =
            regenerateBarButton

        regenerateBarButton?.accessibilityLabel =
            "Regenerate AI Summary"
    }

    // MARK: - Loading Indicator

    private func setupLoadingIndicator() {

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([

            activityIndicator.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            activityIndicator.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }

    // MARK: - Loading State

    private func showLoadingState() {

        activityIndicator.startAnimating()

        summaryTitleLabel.isHidden = true
        summaryLabel.isHidden = true

        keyPointsTitleLabel.isHidden = true
        keyPointsLabel.isHidden = true

        copySummaryButton.isHidden = true

        regenerateBarButton?.isEnabled = false
    }

    // MARK: - Generate AI Summary

    private func generateAISummary() {

        guard let note = note else {

            showErrorState(
                message: "Unable to load this note."
            )

            return
        }

        let content = note.content.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !content.isEmpty else {

            showErrorState(
                message:
                    "This note doesn't contain enough content to summarize."
            )

            return
        }

        aiService.generateSummary(
            for: note
        ) { [weak self] result in

            guard let self = self else {
                return
            }

            DispatchQueue.main.async {

                switch result {

                case .success(let response):

                    let cleanedResponse =
                        self.cleanAIResponse(
                            summary: response.summary,
                            keyPoints: response.keyPoints
                        )

                    self.showResult(
                        summary: cleanedResponse.summary,
                        keyPoints: cleanedResponse.keyPoints
                    )

                case .failure(let error):

                    print(
                        "AI Summary Error: \(error)"
                    )

                    self.showErrorState(
                        message: self.errorMessage(
                            for: error
                        )
                    )
                }
            }
        }
    }

    // MARK: - Regenerate Summary

    @objc
    private func regenerateButtonPressed() {

        showLoadingState()

        generateAISummary()
    }

    // MARK: - Clean AI Response

    private func cleanAIResponse(
        summary: String,
        keyPoints: [String]
    ) -> (
        summary: String,
        keyPoints: String
    ) {

        var cleanedSummary =
            summary.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        var cleanedKeyPoints = keyPoints

        // MARK: Handle SUMMARY / KEY_POINTS inside summary

        if let summaryRange =
            cleanedSummary.range(
                of: "SUMMARY:",
                options: .caseInsensitive
            ) {

            cleanedSummary = String(
                cleanedSummary[
                    summaryRange.upperBound...
                ]
            )
        }

        if let keyPointsRange =
            cleanedSummary.range(
                of: "KEY_POINTS:",
                options: .caseInsensitive
            ) {

            let keyPointsSection =
                String(
                    cleanedSummary[
                        keyPointsRange.upperBound...
                    ]
                )

            cleanedSummary =
                String(
                    cleanedSummary[
                        ..<keyPointsRange.lowerBound
                    ]
                )

            let extractedPoints =
                extractKeyPoints(
                    from: keyPointsSection
                )

            if !extractedPoints.isEmpty {

                cleanedKeyPoints =
                    extractedPoints
            }
        }

        // MARK: Remove accidental labels

        cleanedSummary =
            cleanedSummary
            .replacingOccurrences(
                of: "SUMMARY:",
                with: "",
                options: .caseInsensitive
            )
            .replacingOccurrences(
                of: "KEY_POINTS:",
                with: "",
                options: .caseInsensitive
            )
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // MARK: Clean key points

        var finalKeyPoints: [String] = []

        for point in cleanedKeyPoints {

            let cleanedPoint =
                cleanKeyPoint(point)

            if !cleanedPoint.isEmpty {

                finalKeyPoints.append(
                    cleanedPoint
                )
            }
        }

        // MARK: Handle giant key point string

        if finalKeyPoints.count == 1 {

            let singlePoint =
                finalKeyPoints[0]

            let extractedPoints =
                extractKeyPoints(
                    from: singlePoint
                )

            if extractedPoints.count > 1 {

                finalKeyPoints =
                    extractedPoints
            }
        }

        // MARK: Remove duplicates

        var uniqueKeyPoints: [String] = []

        for point in finalKeyPoints {

            let normalizedPoint =
                point
                .lowercased()
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let alreadyExists =
                uniqueKeyPoints.contains {

                    $0.lowercased()
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ) == normalizedPoint
                }

            if !alreadyExists {

                uniqueKeyPoints.append(point)
            }
        }

        // Maximum 3 points

        uniqueKeyPoints =
            Array(
                uniqueKeyPoints.prefix(3)
            )

        let keyPointsText: String

        if uniqueKeyPoints.isEmpty {

            keyPointsText =
                "No key points available."

        } else {

            keyPointsText =
                uniqueKeyPoints
                    .map {
                        "• \($0)"
                    }
                    .joined(
                        separator: "\n\n"
                    )
        }

        return (
            summary: cleanedSummary,
            keyPoints: keyPointsText
        )
    }

    // MARK: - Extract Key Points

    private func extractKeyPoints(
        from text: String
    ) -> [String] {

        var points: [String] = []

        let lines =
            text.components(
                separatedBy: .newlines
            )

        for line in lines {

            var cleanedLine =
                line.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            if cleanedLine.isEmpty {
                continue
            }

            if cleanedLine.hasPrefix("-") {

                cleanedLine =
                    String(
                        cleanedLine.dropFirst()
                    )

            } else if cleanedLine.hasPrefix("•") {

                cleanedLine =
                    String(
                        cleanedLine.dropFirst()
                    )

            } else if cleanedLine.hasPrefix("*") {

                cleanedLine =
                    String(
                        cleanedLine.dropFirst()
                    )
            }

            cleanedLine =
                cleanedLine.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            // Numbered format: 1. Point

            if let firstCharacter =
                cleanedLine.first,
               firstCharacter.isNumber {

                if let dotIndex =
                    cleanedLine.firstIndex(
                        of: "."
                    ) {

                    let afterDot =
                        cleanedLine.index(
                            after: dotIndex
                        )

                    cleanedLine =
                        String(
                            cleanedLine[
                                afterDot...
                            ]
                        )
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                }
            }

            if !cleanedLine.isEmpty {

                points.append(
                    cleanedLine
                )
            }
        }

        return points
    }

    // MARK: - Clean Individual Key Point

    private func cleanKeyPoint(
        _ point: String
    ) -> String {

        var cleaned =
            point.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        cleaned =
            cleaned.replacingOccurrences(
                of: "KEY_POINTS:",
                with: "",
                options: .caseInsensitive
            )

        cleaned =
            cleaned.replacingOccurrences(
                of: "KEY POINTS:",
                with: "",
                options: .caseInsensitive
            )

        cleaned =
            cleaned.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if cleaned.hasPrefix("-") {

            cleaned =
                String(
                    cleaned.dropFirst()
                )
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
        }

        if cleaned.hasPrefix("•") {

            cleaned =
                String(
                    cleaned.dropFirst()
                )
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
        }

        return cleaned
    }

    // MARK: - Show Result

    private func showResult(
        summary: String,
        keyPoints: String
    ) {

        activityIndicator.stopAnimating()

        summaryTitleLabel.isHidden = false
        summaryLabel.isHidden = false

        keyPointsTitleLabel.isHidden = false
        keyPointsLabel.isHidden = false

        summaryLabel.textColor = .label
        keyPointsLabel.textColor = .label

        summaryLabel.text = summary
        keyPointsLabel.text = keyPoints

        copySummaryButton.isHidden = false

        regenerateBarButton?.isEnabled = true
    }

    // MARK: - Error State

    private func showErrorState(
        message: String
    ) {

        activityIndicator.stopAnimating()

        summaryTitleLabel.isHidden = false
        summaryLabel.isHidden = false

        keyPointsTitleLabel.isHidden = true
        keyPointsLabel.isHidden = true

        copySummaryButton.isHidden = true

        regenerateBarButton?.isEnabled = true

        summaryTitleLabel.text =
            "Unable to Generate Summary"

        summaryLabel.textColor =
            .secondaryLabel

        summaryLabel.text = message
    }

    // MARK: - Error Message

    private func errorMessage(
        for error: Error
    ) -> String {

        if let aiError =
            error as? AIServiceError {

            switch aiError {

            case .invalidURL:
                return "The AI service URL is invalid."

            case .invalidResponse:
                return "The AI service returned an invalid response."

            case .serverError:
                return "The AI server returned an error."

            case .invalidData:
                return "The AI server returned invalid data."

            case .emptyResponse:
                return "The AI returned an empty response."
            }
        }

        return """
        Unable to generate the AI summary.

        Please make sure the NoteMind AI server is running.
        """
    }

    // MARK: - Copy Summary

    @IBAction func copySummaryButtonPressed(
        _ sender: UIButton
    ) {

        guard let summary =
            summaryLabel.text,
              !summary
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty else {

            return
        }

        UIPasteboard.general.string =
            summary

        let generator =
            UINotificationFeedbackGenerator()

        generator.notificationOccurred(
            .success
        )

        let originalTitle =
            sender.title(
                for: .normal
            )

        sender.setTitle(
            "Copied ✓",
            for: .normal
        )

        sender.isEnabled = false

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 1.0
        ) {

            sender.setTitle(
                originalTitle ??
                "Copy Summary",
                for: .normal
            )

            sender.isEnabled = true
        }
    }
}
