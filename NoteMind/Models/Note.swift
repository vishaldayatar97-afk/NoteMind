//
//  Note.swift
//  NoteMind
//
//  Created by VishalD. on 07/08/26.
//

import Foundation

// MARK: - Note Type

enum NoteType: String, Codable {
    case text
    case checklist
    case photo
}

// MARK: - Checklist Item

struct ChecklistItem: Codable, Equatable {

    var id: UUID
    var text: String
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        text: String,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.text = text
        self.isCompleted = isCompleted
    }
}

// MARK: - Note

struct Note: Equatable, Codable {

    var id: UUID
    var title: String
    var content: String
    var date: Date
    var isFavourite: Bool
    var category: String

    // MARK: - New Note Features

    var noteType: NoteType
    var photoData: Data?
    var checklistItems: [ChecklistItem]

    // MARK: - Initializer

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        date: Date,
        isFavourite: Bool = false,
        category: String = "Personal",
        noteType: NoteType = .text,
        photoData: Data? = nil,
        checklistItems: [ChecklistItem] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.isFavourite = isFavourite
        self.category = category
        self.noteType = noteType
        self.photoData = photoData
        self.checklistItems = checklistItems
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {

        case id
        case title
        case content
        case date
        case isFavourite
        case category

        // New properties
        case noteType
        case photoData
        case checklistItems
    }

    // MARK: - Decoder

    init(from decoder: Decoder) throws {

        let container =
            try decoder.container(
                keyedBy: CodingKeys.self
            )

        // MARK: Existing Properties

        id =
            try container.decode(
                UUID.self,
                forKey: .id
            )

        title =
            try container.decode(
                String.self,
                forKey: .title
            )

        content =
            try container.decode(
                String.self,
                forKey: .content
            )

        date =
            try container.decode(
                Date.self,
                forKey: .date
            )

        // MARK: Favourite

        // Old notes may not contain isFavourite.
        isFavourite =
            try container.decodeIfPresent(
                Bool.self,
                forKey: .isFavourite
            ) ?? false

        // MARK: Category

        // Old notes may not contain category.
        category =
            try container.decodeIfPresent(
                String.self,
                forKey: .category
            ) ?? "Personal"

        // MARK: New Note Type

        // Old notes were normal text notes.
        noteType =
            try container.decodeIfPresent(
                NoteType.self,
                forKey: .noteType
            ) ?? .text

        // MARK: Photo

        // Old notes don't have photo data.
        photoData =
            try container.decodeIfPresent(
                Data.self,
                forKey: .photoData
            )

        // MARK: Checklist

        // Old notes don't have checklist items.
        checklistItems =
            try container.decodeIfPresent(
                [ChecklistItem].self,
                forKey: .checklistItems
            ) ?? []
    }
}
