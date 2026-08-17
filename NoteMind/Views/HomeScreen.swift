//
//  ViewController.swift
//  NoteMind
//
//  Created by VishalD. on 07/08/26.
//
import UIKit

class HomeScreen: UIViewController,
                  UITableViewDataSource,
                  UITableViewDelegate,
                  UISearchBarDelegate,
                  NoteTableViewCellDelegate {

    // MARK: - View Model

    let viewModel = NotesViewModel()

    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var emptyStateView: UIView!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupSearchBar()
        setupSegmentControl()
        setupEmptyState()

        updateEmptyState()
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {
        super.viewWillAppear(animated)

        syncSegmentControl()
        tableView.reloadData()
        updateEmptyState()
    }

    // MARK: - Table View Setup

    private func setupTableView() {

        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight =
            UITableView.automaticDimension

        tableView.estimatedRowHeight = 88

        tableView.isHidden = false
    }

    // MARK: - Search Setup

    private func setupSearchBar() {

        searchBar.delegate = self

        searchBar.placeholder =
            "Search your notes..."

        searchBar.returnKeyType = .search
    }

    // MARK: - Segment Setup

    private func setupSegmentControl() {

        segmentControl.removeAllSegments()

        for (index, filter) in
            viewModel.filters.enumerated() {

            segmentControl.insertSegment(
                withTitle: filter,
                at: index,
                animated: false
            )
        }

        segmentControl.selectedSegmentIndex = 0

        segmentControl.addTarget(
            self,
            action: #selector(segmentChanged),
            for: .valueChanged
        )
    }

    // MARK: - Segment Changed

    @objc private func segmentChanged(
        _ sender: UISegmentedControl
    ) {

        guard sender.selectedSegmentIndex >= 0,
              sender.selectedSegmentIndex <
                viewModel.filters.count
        else {
            return
        }

        let selectedFilter =
            viewModel.filters[
                sender.selectedSegmentIndex
            ]

        viewModel.updateFilter(
            selectedFilter
        )

        tableView.reloadData()
        updateEmptyState()
    }

    // MARK: - Storyboard Segment Action

    @IBAction func segmentChnaged(
        _ sender: UISegmentedControl
    ) {

        // Call the same logic used by
        // the programmatic target.

        segmentChanged(sender)
    }

    // MARK: - Empty State Setup

    private func setupEmptyState() {

        emptyStateView.isHidden = true

        tableView.isHidden = false
    }

    // MARK: - Table View Data Source

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return viewModel.filteredNotes.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "NoteCell",
                for: indexPath
            ) as! NoteTableViewCell

        let note =
            viewModel.note(
                at: indexPath.row
            )

        cell.delegate = self

        cell.configure(
            with: note
        )

        return cell
    }

    // MARK: - Select Note

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        let selectedNote =
            viewModel.note(
                at: indexPath.row
            )

        performSegue(
            withIdentifier: "NoteDetailSegue",
            sender: selectedNote
        )

        tableView.deselectRow(
            at: indexPath,
            animated: true
        )
    }

    // MARK: - Delete Using Editing Style

    func tableView(
        _ tableView: UITableView,
        commit editingStyle:
        UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {

        guard editingStyle == .delete
        else {
            return
        }

        let note =
            viewModel.note(
                at: indexPath.row
            )

        confirmDelete(
            note: note
        )
    }

    // MARK: - Swipe Actions

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        // MARK: Delete

        let deleteAction =
            UIContextualAction(
                style: .destructive,
                title: "Delete"
            ) { [weak self] _, _, completion in

                guard let self = self else {
                    completion(false)
                    return
                }

                let note =
                    self.viewModel.note(
                        at: indexPath.row
                    )

                self.confirmDelete(
                    note: note,
                    completion: completion
                )
            }

        // MARK: Edit

        let editAction =
            UIContextualAction(
                style: .normal,
                title: "Edit"
            ) { [weak self] _, _, completion in

                guard let self = self else {
                    completion(false)
                    return
                }

                let note =
                    self.viewModel.note(
                        at: indexPath.row
                    )

                self.performSegue(
                    withIdentifier:
                        "EditNoteSegue",
                    sender: note
                )

                completion(true)
            }

        editAction.backgroundColor =
            .systemBlue

        let configuration =
            UISwipeActionsConfiguration(
                actions: [
                    deleteAction,
                    editAction
                ]
            )

        configuration.performsFirstActionWithFullSwipe =
            false

        return configuration
    }

    // MARK: - Confirm Delete

    private func confirmDelete(
        note: Note,
        completion:
        ((Bool) -> Void)? = nil
    ) {

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
            ) { _ in

                completion?(false)
            }

        let deleteAction =
            UIAlertAction(
                title: "Delete",
                style: .destructive
            ) { [weak self] _ in

                guard let self = self else {
                    completion?(false)
                    return
                }

                self.viewModel.deleteNote(
                    note
                )

                let generator =
                    UINotificationFeedbackGenerator()

                generator.notificationOccurred(
                    .warning
                )

                self.tableView.reloadData()

                self.updateEmptyState()

                completion?(true)
            }

        alert.addAction(cancelAction)
        alert.addAction(deleteAction)

        present(
            alert,
            animated: true
        )
    }

    // MARK: - Segue

    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {

        // MARK: Add Note

        if let destinationVC =
            segue.destination
                as? AddNoteViewController {

            // Pass the currently selected category
            // when creating a note from a category.

            if let category =
                viewModel.currentCategory {

                destinationVC.categoryOverride =
                    category

            } else {

                destinationVC.categoryOverride =
                    nil
            }

            destinationVC.delegate =
                self
        }

        // MARK: Edit Note

        else if let destinationVC =
                    segue.destination
                        as? EditNoteViewController {

            destinationVC.note =
                sender as? Note

            destinationVC.delegate =
                self
        }

        // MARK: Note Detail

        else if let destinationVC =
                    segue.destination
                        as? NoteDetailViewController {

            destinationVC.note =
                sender as? Note

            destinationVC.delegate =
                self
        }

        // MARK: AI Summary

        else if let destinationVC =
                    segue.destination
                        as? AISummaryViewController {

            destinationVC.note =
                sender as? Note
        }
    }

    // MARK: - Sync Segment

    private func syncSegmentControl() {

        guard let index =
                viewModel.filters.firstIndex(
                    of: viewModel.currentFilter
                )
        else {
            return
        }

        segmentControl.selectedSegmentIndex =
            index
    }

    // MARK: - Reload UI

    private func reloadNotes() {

        tableView.reloadData()
        updateEmptyState()
        syncSegmentControl()
    }
}

// MARK: - Add Note Delegate

extension HomeScreen: AddNoteDelegate {

    func didAddNote(
        _ note: Note
    ) {

        viewModel.addNote(note)

        // Keep the user in the category
        // they were currently viewing.

        reloadNotes()
    }
}

// MARK: - Edit & Detail Delegates

extension HomeScreen:
    EditNoteDelegate,
    NoteDetailDelegate {

    // IMPORTANT:
    // One method satisfies both protocols.

    func didUpdateNote(
        _ note: Note
    ) {

        viewModel.updateNote(note)

        reloadNotes()
    }

    func didDeleteNote(
        _ note: Note
    ) {

        viewModel.deleteNote(note)

        reloadNotes()
    }
}

// MARK: - Search

extension HomeScreen {

    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {

        viewModel.updateSearchText(
            searchText
        )

        tableView.reloadData()
        updateEmptyState()
    }

    func searchBarSearchButtonClicked(
        _ searchBar: UISearchBar
    ) {

        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(
        _ searchBar: UISearchBar
    ) {

        searchBar.text = ""

        viewModel.updateSearchText("")

        tableView.reloadData()
        updateEmptyState()
    }
}

// MARK: - Empty State

extension HomeScreen {

    private func updateEmptyState() {

        let isEmpty =
            viewModel.filteredNotes.isEmpty

        tableView.isHidden = false

        emptyStateView.isHidden =
            !isEmpty

        guard isEmpty else {
            return
        }

        let titleLabel =
            emptyStateView.viewWithTag(100)
                as? UILabel

        let messageLabel =
            emptyStateView.viewWithTag(101)
                as? UILabel

        let button =
            emptyStateView.viewWithTag(102)
                as? UIButton

        // MARK: Search Empty

        let currentSearch =
            viewModel.currentSearchText
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        if !currentSearch.isEmpty {

            titleLabel?.text =
                "No Notes Found"

            messageLabel?.text =
                "Try searching with a different keyword."

            button?.isHidden = true

            return
        }

        // MARK: Favourite Empty

        if viewModel.showingFavouriteOnly {

            titleLabel?.text =
                "No Favourite Notes"

            messageLabel?.text =
                "Mark important notes with a star and they'll appear here."

            button?.isHidden = true

            return
        }

        // MARK: Category Empty

        if let category =
            viewModel.currentCategory {

            titleLabel?.text =
                "No \(category) Notes"

            messageLabel?.text =
                "There are no notes in this category yet."

            button?.isHidden = false

            return
        }

        // MARK: All Notes Empty

        titleLabel?.text =
            "No Notes Yet"

        messageLabel?.text =
            "Create your first note and start organizing your thoughts."

        button?.isHidden = false
    }

    // MARK: - Create Note

    @IBAction func createNoteFromEmptyState(
        _ sender: UIButton
    ) {

        performSegue(
            withIdentifier: "AddNoteSegue",
            sender: nil
        )
    }
}

// MARK: - Favourite Cell Delegate

extension HomeScreen {

    func didTapFavouriteButton(
        in cell: NoteTableViewCell
    ) {

        guard let indexPath =
                tableView.indexPath(
                    for: cell
                )
        else {
            return
        }

        var note =
            viewModel.note(
                at: indexPath.row
            )

        note.isFavourite.toggle()

        viewModel.updateNote(note)

        let generator =
            UIImpactFeedbackGenerator(
                style: .light
            )

        generator.prepare()
        generator.impactOccurred()

        tableView.reloadData()

        updateEmptyState()
    }
}
