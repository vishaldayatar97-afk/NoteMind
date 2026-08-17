//
//  EditNoteDelegate.swift
//  NoteMind
//
//  Created by VishalD. on 16/08/26.
//

import Foundation

protocol EditNoteDelegate: AnyObject {
    func didUpdateNote(_ note: Note)
}
