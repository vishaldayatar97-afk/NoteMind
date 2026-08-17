//
//  NoteTableViewCell.swift
//  NoteMind
//
//  Created by VishalD. on 07/08/26.
//

import UIKit

protocol NoteTableViewCellDelegate: AnyObject {
    func didTapFavouriteButton(in cell: NoteTableViewCell)
}

class NoteTableViewCell: UITableViewCell {

    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!

    // MARK: - Properties

    weak var delegate: NoteTableViewCellDelegate?

    private let favouriteColor =
        UIColor.systemPurple

    // MARK: - Cell Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        contentLabel.text = nil
        dateLabel.text = nil

        favouriteButton.setImage(
            UIImage(systemName: "star"),
            for: .normal
        )

        favouriteButton.tintColor =
            favouriteColor

        favouriteButton.accessibilityValue =
            "Not favourite"
    }

    // MARK: - UI Setup

    private func setupUI() {

        // MARK: Title

        titleLabel.font =
            UIFont.preferredFont(
                forTextStyle: .headline
            )

        titleLabel.numberOfLines = 1

        // MARK: Content

        contentLabel.font =
            UIFont.preferredFont(
                forTextStyle: .subheadline
            )

        contentLabel.textColor =
            .secondaryLabel

        contentLabel.numberOfLines = 2

        // MARK: Date

        dateLabel.font =
            UIFont.preferredFont(
                forTextStyle: .caption1
            )

        dateLabel.textColor =
            .tertiaryLabel

        dateLabel.numberOfLines = 1

        // MARK: Favourite Button

        favouriteButton.tintColor =
            favouriteColor

        favouriteButton.accessibilityLabel =
            "Favourite note"
    }

    // MARK: - Configure Cell

    func configure(
        with note: Note
    ) {

        titleLabel.text =
            note.title

        configureContent(
            for: note
        )

        configureDate(
            for: note
        )

        updateFavouriteButton(
            isFavourite:
                note.isFavourite
        )
    }

    // MARK: - Configure Content

    private func configureContent(
        for note: Note
    ) {

        switch note.noteType {

        // MARK: Text

        case .text:

            if note.content
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty {

                contentLabel.text =
                    "No content"

            } else {

                contentLabel.text =
                    note.content
            }

        // MARK: Checklist

        case .checklist:

            let totalItems =
                note.checklistItems.count

            let completedItems =
                note.checklistItems.filter {
                    $0.isCompleted
                }.count

            if totalItems > 0 {

                contentLabel.text =
                    "☑ \(completedItems) of \(totalItems) items completed"

            } else if !note.content.isEmpty {

                contentLabel.text =
                    "☐ \(note.content)"

            } else {

                contentLabel.text =
                    "Checklist"
            }

        // MARK: Photo

        case .photo:

            if note.photoData != nil {

                if note.content
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty {

                    contentLabel.text =
                        "📷 Photo"

                } else {

                    contentLabel.text =
                        "📷 \(note.content)"
                }

            } else {

                contentLabel.text =
                    "📷 No photo"
            }
        }
    }

    // MARK: - Configure Date

    private func configureDate(
        for note: Note
    ) {

        let formatter =
            DateFormatter()

        formatter.dateStyle =
            .medium

        formatter.timeStyle =
            .short

        dateLabel.text =
            formatter.string(
                from: note.date
            )
    }

    // MARK: - Favourite Button Appearance

    private func updateFavouriteButton(
        isFavourite: Bool
    ) {

        let imageName =
            isFavourite
            ? "star.fill"
            : "star"

        favouriteButton.setImage(
            UIImage(
                systemName:
                    imageName
            ),
            for: .normal
        )

        favouriteButton.tintColor =
            favouriteColor

        favouriteButton.accessibilityValue =
            isFavourite
            ? "Favourite"
            : "Not favourite"
    }

    // MARK: - Favourite Button Action

    @IBAction func favouriteButtonTapped(
        _ sender: UIButton
    ) {

        let generator =
            UIImpactFeedbackGenerator(
                style: .light
            )

        generator.prepare()
        generator.impactOccurred()

        delegate?.didTapFavouriteButton(
            in: self
        )
    }

    // MARK: - Selected State

    override func setSelected(
        _ selected: Bool,
        animated: Bool
    ) {

        super.setSelected(
            selected,
            animated: animated
        )
    }
}
