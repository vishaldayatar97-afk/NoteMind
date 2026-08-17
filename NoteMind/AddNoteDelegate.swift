//
//  AddNoteDelegate.swift
//  NoteMind
//
//  Created by VishalD. on 16/08/26.
//

import Foundation

protocol AddNoteDelegate: AnyObject {
    func didAddNote(_ note: Note)
}
