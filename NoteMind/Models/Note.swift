//
//  Note.swift
//  NoteMind
//
//  Created by VishalD. on 07/08/26.
//

import Foundation

struct Note : Identifiable , Codable{
    var id = UUID()
    var title : String
    var content : String
    var date : Date
}
