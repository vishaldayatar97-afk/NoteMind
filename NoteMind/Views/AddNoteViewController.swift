//
//  AddNoteViewController.swift
//  NoteMind
//
//  Created by VishalD. on 07/08/26.
//

import UIKit

protocol AddNoteDelegate: AnyObject {
    func didAddNote(_ note: Note)
}

class AddNoteViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    weak var delegate: AddNoteDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        
        //Gets the text entered in the title field and Prevents saving a note with an empty or all-space title.
        guard let title = titleTextField.text, !title.trimmingCharacters(in:.whitespaces).isEmpty else{
            return
        }
        
        //Gets the note content. If it's nil , it uses an empty string
        let content = contentTextView.text ?? ""
        
        let note = Note(title: title, content: content, date: Date())
        
        //Sends the new note back to the Home screen
        delegate?.didAddNote(note)
        navigationController?.popViewController(animated: true)
    }
    
}
