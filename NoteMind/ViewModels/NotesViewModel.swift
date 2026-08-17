//
//  NotesViewModel.swift
//  NoteMind
//
//  Created by VishalD. on 07/08/26.
//
import Foundation

class NotesViewModel {

    // MARK: - Properties

    private(set) var notes: [Note] = []

    private var searchText: String = ""

    // Current segment/filter
    private var selectedFilter: String = "All"

    // UserDefaults key
    private let notesKey = "savedNotes"

    // MARK: - Filter Information

    var currentSearchText: String {
        return searchText
    }

    var currentFilter: String {
        return selectedFilter
    }

    var showingFavouriteOnly: Bool {
        return selectedFilter == "Favourites"
    }

    var currentCategory: String? {

        switch selectedFilter {

        case "Work",
             "Study",
             "Ideas",
             "Personal":

            return selectedFilter

        default:

            return nil
        }
    }

    // MARK: - Categories

    /// Actual categories available for notes.
    let categories = [
        "Work",
        "Study",
        "Ideas",
        "Personal"
    ]

    /// Filters displayed on HomeScreen.
    let filters = [
        "All",
        "Favourites",
        "Work",
        "Study",
        "Ideas",
        "Personal"
    ]

    // MARK: - Filtered Notes

    var filteredNotes: [Note] {

        var result = notes

        // MARK: Segment Filter

        switch selectedFilter {

        case "Favourites":

            result = result.filter {
                $0.isFavourite
            }

        case "Work",
             "Study",
             "Ideas",
             "Personal":

            result = result.filter {
                $0.category == selectedFilter
            }

        case "All":

            break

        default:

            break
        }

        // MARK: Search Filter

        let trimmedSearch =
            searchText
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        if !trimmedSearch.isEmpty {

            result = result.filter { note in

                note.title
                    .lowercased()
                    .contains(trimmedSearch)

                ||

                note.content
                    .lowercased()
                    .contains(trimmedSearch)

                ||

                note.category
                    .lowercased()
                    .contains(trimmedSearch)

                ||

                noteTypeSearchText(
                    for: note
                )
                .contains(trimmedSearch)
            }
        }

        // MARK: Newest First

        result.sort {
            $0.date > $1.date
        }

        return result
    }

    // MARK: - Init

    init() {

        loadNotes()
    }

    // MARK: - Add Note

    func addNote(
        _ note: Note
    ) {

        notes.append(
            note
        )

        saveNotes()
    }

    // MARK: - Delete Note

    func deleteNote(
        _ note: Note
    ) {

        guard let index =
                notes.firstIndex(
                    where: {
                        $0.id == note.id
                    }
                )
        else {
            return
        }

        notes.remove(
            at: index
        )

        saveNotes()
    }

    // MARK: - Delete Note At Filtered Index

    func deleteNote(
        at index: Int
    ) {

        let filtered =
            filteredNotes

        guard filtered.indices.contains(
            index
        )
        else {
            return
        }

        let selectedNote =
            filtered[index]

        deleteNote(
            selectedNote
        )
    }

    // MARK: - Update Note

    func updateNote(
        _ note: Note
    ) {

        guard let index =
                notes.firstIndex(
                    where: {
                        $0.id == note.id
                    }
                )
        else {
            return
        }

        notes[index] =
            note

        saveNotes()
    }

    // MARK: - Get Filtered Note

    func note(
        at index: Int
    ) -> Note {

        return filteredNotes[index]
    }

    // MARK: - Note Count

    var numberOfNotes: Int {

        return filteredNotes.count
    }

    // MARK: - Search

    func updateSearchText(
        _ text: String
    ) {

        searchText =
            text
    }

    // MARK: - Segment Filter

    func updateFilter(
        _ filter: String
    ) {

        guard filters.contains(
            filter
        )
        else {

            selectedFilter =
                "All"

            return
        }

        selectedFilter =
            filter
    }

    // MARK: - Reset Filters

    func resetFilters() {

        searchText = ""

        selectedFilter =
            "All"
    }

    // MARK: - Search Note Type

    private func noteTypeSearchText(
        for note: Note
    ) -> String {

        switch note.noteType {

        case .text:

            return "text"

        case .checklist:

            return "checklist todo task"

        case .photo:

            return "photo image picture"
        }
    }

    // MARK: - Save Notes

    private func saveNotes() {

        do {

            let encoder =
                JSONEncoder()

            let data =
                try encoder.encode(
                    notes
                )

            UserDefaults.standard.set(
                data,
                forKey: notesKey
            )

        } catch {

            print(
                "Failed to save notes: \(error)"
            )
        }
    }

    // MARK: - Load Notes

    private func loadNotes() {

        guard let data =
                UserDefaults.standard.data(
                    forKey: notesKey
                )
        else {

            notes = []

            return
        }

        do {

            let decoder =
                JSONDecoder()

            notes =
                try decoder.decode(
                    [Note].self,
                    from: data
                )

            // Make sure notes are immediately
            // available in newest-first order.

            notes.sort {
                $0.date > $1.date
            }

        } catch {

            print(
                "Failed to load notes: \(error)"
            )

            notes = []
        }
    }
}
