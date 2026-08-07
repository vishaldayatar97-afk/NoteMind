//
//  ViewController.swift
//  NoteMind
//
//  Created by VishalD. on 07/08/26.
//

import UIKit

class HomeScreen: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let viewModel = NotesViewModel()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfNotes()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        let note = viewModel.note(at: indexPath.row)
        cell.textLabel?.text = note.title
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 90
        
    }

    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            viewModel.deleteNote(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
       
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? AddNoteViewController{
            
            destinationVC.delegate = self
        }
    }
}

//When user taps Save: the new note is received , it is added to the NotesViewModel , the table view refreshed so the new note appears.
extension HomeScreen: AddNoteDelegate{
    
    func didAddNote(_ note: Note) {
        
        viewModel.addNote(note)
        
        tableView.reloadData()
    }
}

