//
//  NotesViewModel.swift
//  NoteMind
//
//  Created by VishalD. on 07/08/26.
//

import Foundation

class NotesViewModel {

    private(set) var notes: [Note] = []
    
    init(){
        loadNotes()
    }
    private(set) var notesKey = "saved_notes"

    func numberOfNotes() -> Int {
        return notes.count
    }

    func note(at index: Int) -> Note {
        return notes[index]
    }

    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
    }
    
    private func saveNotes(){
        do{
            let data = try JSONEncoder().encode(notes)
            UserDefaults.standard.set(data, forKey: notesKey)
        }catch{
            print("Failed to save notes.",error)
        }
    }
    
    private func loadNotes(){
        
        guard let data = UserDefaults.standard.data(forKey: notesKey) else {
            notes = [
                Note(title: "Meeting", content: "Discuss Project", date: Date()),
                Note(title: "Call", content: "Call client", date: Date()),
                Note(title: "Task", content: "Complete report", date: Date()),
            ]
            return
        }
        do{
            notes = try JSONDecoder().decode([Note].self, from: data)
        } catch {
            print("Faliure in loading notes.", error)
        }
    }
    
    func deleteNote(at index: Int){
        notes.remove(at: index)
        saveNotes()
    }
}
