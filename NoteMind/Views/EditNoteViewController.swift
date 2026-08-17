//
//  EditNoteViewController.swift
//  NoteMind
//
//  Created by VishalD. on 08/08/26.
//


import UIKit
import PhotosUI

class EditNoteViewController: UIViewController,
                              UITextFieldDelegate,
                              UITextViewDelegate {

    // MARK: - Outlets

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!

    @IBOutlet weak var textFormatButton: UIButton!
    @IBOutlet weak var checklistButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!

    // MARK: - Delegate

    weak var delegate: EditNoteDelegate?

    // MARK: - Note

    var note: Note?

    // MARK: - Properties

    private let contentPlaceholder =
        "Start writing your note..."

    // Current note type
    private var selectedNoteType: NoteType = .text

    // Photo attached to the note
    private var selectedPhotoData: Data?

    // Checklist items
    private var checklistItems: [ChecklistItem] = []

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitleField()
        setupContentTextView()
        setupToolbarButtons()
        setupKeyboardDismissal()
        loadNote()
        updateSaveButton()
    }

    // MARK: - Title Field

    private func setupTitleField() {

        titleTextField.delegate = self

        titleTextField.clearButtonMode =
            .whileEditing

        titleTextField.returnKeyType =
            .next

        titleTextField.addTarget(
            self,
            action: #selector(titleTextChanged),
            for: .editingChanged
        )
    }

    // MARK: - Content Text View

    private func setupContentTextView() {

        contentTextView.delegate = self

        contentTextView.font =
            UIFont.preferredFont(
                forTextStyle: .body
            )

        contentTextView.backgroundColor =
            .clear

        contentTextView.alwaysBounceVertical =
            true

        contentTextView.isScrollEnabled =
            true
    }

    // MARK: - Toolbar Buttons

    private func setupToolbarButtons() {

        textFormatButton?.layer.cornerRadius = 8
        checklistButton?.layer.cornerRadius = 8
        photoButton?.layer.cornerRadius = 8

        textFormatButton?.tintColor =
            .systemBlue

        checklistButton?.tintColor =
            .systemBlue

        photoButton?.tintColor =
            .systemBlue
    }

    // MARK: - Load Existing Note

    private func loadNote() {

        guard let note = note else {
            return
        }

        // Load title

        titleTextField.text =
            note.title

        // Restore note type

        selectedNoteType =
            note.noteType

        // Restore checklist items

        checklistItems =
            note.checklistItems

        // Restore photo

        selectedPhotoData =
            note.photoData

        // Restore text content

        let trimmedContent =
            note.content.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        if trimmedContent.isEmpty {

            contentTextView.text =
                contentPlaceholder

            contentTextView.textColor =
                .secondaryLabel

        } else {

            contentTextView.text =
                note.content

            contentTextView.textColor =
                .label
        }

        // Restore photo if this is a photo note

        if note.noteType == .photo,
           let photoData = note.photoData,
           let image = UIImage(
                data: photoData
           ) {

            insertImageAtEnd(
                image
            )
        }
    }

    // MARK: - Save Button

    private func updateSaveButton() {

        let title =
            titleTextField.text?
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ) ?? ""

        navigationItem.rightBarButtonItem?
            .isEnabled =
            !title.isEmpty
    }

    // MARK: - Title Changed

    @objc private func titleTextChanged() {

        updateSaveButton()
    }

    // MARK: - Text View Placeholder

    func textViewDidBeginEditing(
        _ textView: UITextView
    ) {

        if textView.text ==
            contentPlaceholder {

            textView.text = ""

            textView.textColor =
                .label
        }
    }

    func textViewDidEndEditing(
        _ textView: UITextView
    ) {

        if textView.text
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty {

            textView.text =
                contentPlaceholder

            textView.textColor =
                .secondaryLabel
        }
    }

    // MARK: - Keyboard

    private func setupKeyboardDismissal() {

        let tapGesture =
            UITapGestureRecognizer(
                target: self,
                action: #selector(
                    dismissKeyboard
                )
            )

        tapGesture.cancelsTouchesInView =
            false

        view.addGestureRecognizer(
            tapGesture
        )
    }

    @objc private func dismissKeyboard() {

        view.endEditing(true)
    }

    // MARK: - Text Field Return

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {

        contentTextView.becomeFirstResponder()

        return true
    }

    // MARK: - Text Format

    @IBAction func textFormatButtonPressed(
        _ sender: UIButton
    ) {

        contentTextView.becomeFirstResponder()

        let alert =
            UIAlertController(
                title: "Text Format",
                message:
                    "Choose a formatting option.",
                preferredStyle: .actionSheet
            )

        let boldAction =
            UIAlertAction(
                title: "Bold",
                style: .default
            ) { [weak self] _ in

                self?.applyFontTrait(
                    .traitBold
                )
            }

        let italicAction =
            UIAlertAction(
                title: "Italic",
                style: .default
            ) { [weak self] _ in

                self?.applyFontTrait(
                    .traitItalic
                )
            }

        let underlineAction =
            UIAlertAction(
                title: "Underline",
                style: .default
            ) { [weak self] _ in

                self?.applyUnderline()
            }

        let cancelAction =
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )

        alert.addAction(
            boldAction
        )

        alert.addAction(
            italicAction
        )

        alert.addAction(
            underlineAction
        )

        alert.addAction(
            cancelAction
        )

        present(
            alert,
            animated: true
        )
    }

    // MARK: - Font Trait

    private func applyFontTrait(
        _ trait:
        UIFontDescriptor.SymbolicTraits
    ) {

        let selectedRange =
            contentTextView.selectedRange

        guard selectedRange.length > 0 else {

            showInformationAlert(
                title: "Select Text",
                message:
                    "Select some text first, then choose a formatting option."
            )

            return
        }

        let attributedText =
            NSMutableAttributedString(
                attributedString:
                    contentTextView.attributedText
            )

        attributedText.enumerateAttribute(
            .font,
            in: selectedRange
        ) { value, range, _ in

            let currentFont =
                value as? UIFont ??
                self.contentTextView.font ??
                UIFont.preferredFont(
                    forTextStyle: .body
                )

            var traits =
                currentFont.fontDescriptor
                    .symbolicTraits

            if traits.contains(trait) {

                traits.remove(trait)

            } else {

                traits.insert(trait)
            }

            if let descriptor =
                currentFont.fontDescriptor
                    .withSymbolicTraits(
                        traits
                    ) {

                let newFont =
                    UIFont(
                        descriptor: descriptor,
                        size:
                            currentFont.pointSize
                    )

                attributedText.addAttribute(
                    .font,
                    value: newFont,
                    range: range
                )
            }
        }

        contentTextView.attributedText =
            attributedText

        contentTextView.selectedRange =
            selectedRange
    }

    // MARK: - Underline

    private func applyUnderline() {

        let selectedRange =
            contentTextView.selectedRange

        guard selectedRange.length > 0 else {

            showInformationAlert(
                title: "Select Text",
                message:
                    "Select some text first, then choose Underline."
            )

            return
        }

        let attributedText =
            NSMutableAttributedString(
                attributedString:
                    contentTextView.attributedText
            )

        attributedText.addAttribute(
            .underlineStyle,
            value:
                NSUnderlineStyle.single.rawValue,
            range:
                selectedRange
        )

        contentTextView.attributedText =
            attributedText

        contentTextView.selectedRange =
            selectedRange
    }

    // MARK: - Checklist

    @IBAction func checklistButtonPressed(
        _ sender: UIButton
    ) {

        contentTextView.becomeFirstResponder()

        selectedNoteType =
            .checklist

        insertChecklistItem()
    }

    private func insertChecklistItem() {

        let checklistText =
            "☐ "

        let selectedRange =
            contentTextView.selectedRange

        let attributedText =
            NSMutableAttributedString(
                attributedString:
                    contentTextView.attributedText
            )

        let font =
            contentTextView.font ??
            UIFont.preferredFont(
                forTextStyle: .body
            )

        attributedText.insert(
            NSAttributedString(
                string: checklistText,
                attributes: [
                    .font: font,
                    .foregroundColor:
                        UIColor.label
                ]
            ),
            at:
                selectedRange.location
        )

        contentTextView.attributedText =
            attributedText

        contentTextView.selectedRange =
            NSRange(
                location:
                    selectedRange.location +
                    checklistText.count,
                length: 0
            )

        // Add a real checklist item
        let item =
            ChecklistItem(
                text: ""
            )

        checklistItems.append(
            item
        )
    }

    // MARK: - Photo

    @IBAction func photoButtonPressed(
        _ sender: UIButton
    ) {

        var configuration =
            PHPickerConfiguration(
                photoLibrary:
                    PHPhotoLibrary.shared()
            )

        configuration.filter =
            .images

        configuration.selectionLimit =
            1

        let picker =
            PHPickerViewController(
                configuration:
                    configuration
            )

        picker.delegate =
            self

        present(
            picker,
            animated: true
        )
    }

    // MARK: - Save Note

    @IBAction func saveButtonPressed(
        _ sender: UIBarButtonItem
    ) {

        // Validate title

        guard let title =
                titleTextField.text?
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
              !title.isEmpty
        else {

            titleTextField.becomeFirstResponder()

            return
        }

        // Make sure an existing note is available

        guard let oldNote = note else {
            return
        }

        // Get content

        let content: String

        if contentTextView.text ==
            contentPlaceholder {

            content = ""

        } else {

            content =
                contentTextView.text ?? ""
        }

        // Determine final note type

        let finalNoteType: NoteType

        if selectedPhotoData != nil {

            finalNoteType =
                .photo

        } else if !checklistItems.isEmpty {

            finalNoteType =
                .checklist

        } else {

            finalNoteType =
                selectedNoteType
        }

        // Create updated note

        let updatedNote =
            Note(
                id:
                    oldNote.id,

                title:
                    title,

                content:
                    content,

                date:
                    Date(),

                isFavourite:
                    oldNote.isFavourite,

                category:
                    oldNote.category,

                noteType:
                    finalNoteType,

                photoData:
                    selectedPhotoData,

                checklistItems:
                    checklistItems
            )

        // Send updated note back

        delegate?.didUpdateNote(
            updatedNote
        )

        // Return to previous screen

        navigationController?.popViewController(
            animated: true
        )
    }

    // MARK: - Alert

    private func showInformationAlert(
        title: String,
        message: String
    ) {

        let alert =
            UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: .default
            )
        )

        present(
            alert,
            animated: true
        )
    }
}

// MARK: - PHPicker Delegate

extension EditNoteViewController:
    PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results:
        [PHPickerResult]
    ) {

        picker.dismiss(
            animated: true
        )

        guard let result =
                results.first
        else {
            return
        }

        let provider =
            result.itemProvider

        guard provider.canLoadObject(
            ofClass: UIImage.self
        ) else {
            return
        }

        provider.loadObject(
            ofClass: UIImage.self
        ) { [weak self] object, error in

            guard
                let self = self,
                let image =
                    object as? UIImage,
                error == nil
            else {
                return
            }

            DispatchQueue.main.async {

                // Save photo data

                self.selectedPhotoData =
                    image.jpegData(
                        compressionQuality: 0.8
                    )

                // Change note type

                self.selectedNoteType =
                    .photo

                // Display image

                self.insertImage(
                    image
                )
            }
        }
    }

    // MARK: - Insert New Image

    private func insertImage(
        _ image: UIImage
    ) {

        let textAttachment =
            NSTextAttachment()

        textAttachment.image =
            image

        let maxWidth =
            contentTextView.bounds.width -
            32

        if image.size.width > maxWidth {

            let scale =
                maxWidth /
                image.size.width

            textAttachment.bounds =
                CGRect(
                    x: 0,
                    y: 0,
                    width:
                        image.size.width *
                        scale,
                    height:
                        image.size.height *
                        scale
                )
        }

        let imageString =
            NSAttributedString(
                attachment:
                    textAttachment
            )

        let mutableText =
            NSMutableAttributedString(
                attributedString:
                    contentTextView.attributedText
            )

        let location =
            contentTextView.selectedRange.location

        mutableText.insert(
            imageString,
            at:
                location
        )

        mutableText.insert(
            NSAttributedString(
                string: "\n"
            ),
            at:
                location +
                imageString.length
        )

        contentTextView.attributedText =
            mutableText

        contentTextView.selectedRange =
            NSRange(
                location:
                    location +
                    imageString.length +
                    1,
                length: 0
            )
    }

    // MARK: - Insert Existing Image

    private func insertImageAtEnd(
        _ image: UIImage
    ) {

        let textAttachment =
            NSTextAttachment()

        textAttachment.image =
            image

        let maxWidth =
            contentTextView.bounds.width -
            32

        if image.size.width > maxWidth {

            let scale =
                maxWidth /
                image.size.width

            textAttachment.bounds =
                CGRect(
                    x: 0,
                    y: 0,
                    width:
                        image.size.width *
                        scale,
                    height:
                        image.size.height *
                        scale
                )
        }

        let imageString =
            NSAttributedString(
                attachment:
                    textAttachment
            )

        let mutableText =
            NSMutableAttributedString(
                attributedString:
                    contentTextView.attributedText
            )

        if mutableText.length > 0 {

            mutableText.append(
                NSAttributedString(
                    string: "\n\n"
                )
            )
        }

        mutableText.append(
            imageString
        )

        contentTextView.attributedText =
            mutableText

        contentTextView.selectedRange =
            NSRange(
                location:
                    mutableText.length,
                length: 0
            )
    }
}
