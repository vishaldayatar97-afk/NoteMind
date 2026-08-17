
//
//  NoteDetailViewController.swift
//  NoteMind
//
//  Created by VishalD. on 08/08/26.
//

import UIKit

protocol NoteDetailDelegate: AnyObject {
    func didUpdateNote(_ note: Note)
    func didDeleteNote(_ note: Note)
}

class NoteDetailViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!

    // MARK: - Properties

    var note: Note?

    weak var delegate: NoteDetailDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        displayNote()
        updateFavoriteButton()
    }

    // MARK: - Setup UI

    private func setupUI() {

        // Title
        titleLabel.font = UIFont.preferredFont(
            forTextStyle: .title2
        )

        titleLabel.numberOfLines = 0

        // Date
        dateLabel.font = UIFont.preferredFont(
            forTextStyle: .caption1
        )

        dateLabel.textColor = .secondaryLabel

        // Content
        contentTextView.font = UIFont.preferredFont(
            forTextStyle: .body
        )

        contentTextView.textColor = .label
        contentTextView.backgroundColor = .clear

        contentTextView.isEditable = false
        contentTextView.isSelectable = true

        // Favourite button
        favoriteButton.tintColor = .systemYellow

        favoriteButton.accessibilityLabel =
            "Favourite note"
    }

    // MARK: - Display Note

    private func displayNote() {

        guard let note = note else {
            return
        }

        titleLabel.text = note.title

        // Date
        let formatter = DateFormatter()

        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        dateLabel.text = formatter.string(
            from: note.date
        )

        // Content
        displayContent(for: note)
    }

    // MARK: - Display Content

    private func displayContent(
        for note: Note
    ) {

        // Clear previous content first.
        contentTextView.text = nil
        contentTextView.attributedText = nil
        contentTextView.textColor = .label

        switch note.noteType {

        case .text:
            displayTextNote(note)

        case .checklist:
            displayChecklistNote(note)

        case .photo:
            displayPhotoNote(note)
        }
    }

    // MARK: - Text Note

    private func displayTextNote(
        _ note: Note
    ) {

        let content =
            note.content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if content.isEmpty {

            contentTextView.text = "No content"

            contentTextView.textColor =
                .secondaryLabel

        } else {

            // IMPORTANT:
            // Set normal text only.
            // Do NOT set attributedText = nil afterwards.

            contentTextView.text =
                note.content

            contentTextView.textColor =
                .label
        }
    }

    // MARK: - Checklist Note

    private func displayChecklistNote(
        _ note: Note
    ) {

        var checklistText = ""

        if !note.checklistItems.isEmpty {

            for item in note.checklistItems {

                let checkbox =
                    item.isCompleted
                    ? "☑"
                    : "☐"

                checklistText +=
                    "\(checkbox) \(item.text)\n"
            }

            contentTextView.text =
                checklistText

            contentTextView.textColor =
                .label

        } else {

            // Fallback if checklist items
            // are not available.

            let content =
                note.content.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            if content.isEmpty {

                contentTextView.text =
                    "No checklist items"

                contentTextView.textColor =
                    .secondaryLabel

            } else {

                contentTextView.text =
                    note.content

                contentTextView.textColor =
                    .label
            }
        }
    }

    // MARK: - Photo Note

    private func displayPhotoNote(
        _ note: Note
    ) {

        guard let photoData = note.photoData,
              let image = UIImage(data: photoData)
        else {

            let content =
                note.content.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            if content.isEmpty {

                contentTextView.text =
                    "No photo available"

                contentTextView.textColor =
                    .secondaryLabel

            } else {

                contentTextView.text =
                    content

                contentTextView.textColor =
                    .label
            }

            return
        }

        let attachment =
            NSTextAttachment()

        attachment.image = image

        // Maximum image width
        let maxWidth =
            contentTextView.bounds.width - 32

        if image.size.width > maxWidth,
           maxWidth > 0 {

            let scale =
                maxWidth / image.size.width

            attachment.bounds =
                CGRect(
                    x: 0,
                    y: 0,
                    width:
                        image.size.width * scale,
                    height:
                        image.size.height * scale
                )
        }

        let attributedString =
            NSMutableAttributedString()

        attributedString.append(
            NSAttributedString(
                attachment: attachment
            )
        )

        // Add text below photo if available.

        let content =
            note.content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if !content.isEmpty {

            attributedString.append(
                NSAttributedString(
                    string:
                        "\n\n\(note.content)"
                )
            )
        }

        contentTextView.attributedText =
            attributedString

        contentTextView.textColor =
            .label
    }

    // MARK: - Favourite Button

    @IBAction func favoriteButtonPressed(
        _ sender: UIButton
    ) {

        guard var note = note else {
            return
        }

        note.isFavourite.toggle()

        self.note = note

        updateFavoriteButton()

        // Send updated note to HomeScreen
        delegate?.didUpdateNote(note)
    }

    // MARK: - Update Favourite Button

    private func updateFavoriteButton() {

        guard let note = note else {
            return
        }

        let imageName =
            note.isFavourite
            ? "star.fill"
            : "star"

        favoriteButton.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )

        favoriteButton.accessibilityValue =
            note.isFavourite
            ? "Favourite"
            : "Not favourite"
    }

    // MARK: - Edit / AI Summary Segues

    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {

        // Edit Note
        if let editVC =
            segue.destination
                as? EditNoteViewController {

            editVC.note = note
            editVC.delegate = self
        }

        // AI Summary
        if segue.identifier == "AISummarySegue",
           let summaryVC =
            segue.destination
                as? AISummaryViewController {

            summaryVC.note = note
        }
    }

    // MARK: - Share Button

    @IBAction func shareButtonPressed(
        _ sender: UIButton
    ) {

        guard let note = note else {
            return
        }

        var shareContent =
            """
            NoteMind

            \(note.title)

            """

        switch note.noteType {

        case .text:

            shareContent += note.content

        case .checklist:

            if note.checklistItems.isEmpty {

                shareContent += note.content

            } else {

                for item in note.checklistItems {

                    let checkbox =
                        item.isCompleted
                        ? "☑"
                        : "☐"

                    shareContent +=
                        "\(checkbox) \(item.text)\n"
                }
            }

        case .photo:

            if note.content.isEmpty {

                shareContent +=
                    "Photo note"

            } else {

                shareContent +=
                    note.content
            }
        }

        let activityViewController =
            UIActivityViewController(
                activityItems: [
                    shareContent
                ],
                applicationActivities: nil
            )

        // iPad support
        activityViewController
            .popoverPresentationController?
            .sourceView = sender

        activityViewController
            .popoverPresentationController?
            .sourceRect = sender.bounds

        present(
            activityViewController,
            animated: true
        )
    }

    // MARK: - Delete Button

    @IBAction func deleteButtonPressed(
        _ sender: UIButton
    ) {

        guard let note = note else {
            return
        }

        let alert =
            UIAlertController(
                title: "Delete Note?",
                message:
                    "This note will be permanently deleted.",
                preferredStyle: .alert
            )

        let cancelAction =
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )

        let deleteAction =
            UIAlertAction(
                title: "Delete",
                style: .destructive
            ) { [weak self] _ in

                guard let self = self else {
                    return
                }

                // Haptic feedback
                let generator =
                    UINotificationFeedbackGenerator()

                generator.notificationOccurred(
                    .warning
                )

                // Tell HomeScreen to delete
                self.delegate?.didDeleteNote(
                    note
                )

                // Go back
                self.navigationController?
                    .popViewController(
                        animated: true
                    )
            }

        alert.addAction(cancelAction)
        alert.addAction(deleteAction)

        present(
            alert,
            animated: true
        )
    }
}

// MARK: - Edit Note Delegate

extension NoteDetailViewController:
    EditNoteDelegate {

    func didUpdateNote(
        _ note: Note
    ) {

        // Update local note
        self.note = note

        // Refresh screen
        displayNote()
        updateFavoriteButton()

        // Send update to HomeScreen
        delegate?.didUpdateNote(note)
    }
}
