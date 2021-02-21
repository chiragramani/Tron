//
//  File.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation

protocol UUIDGenerating {
    func generateUUID() -> String
}

struct UUIDGenerator: UUIDGenerating {
    
    func generateUUID() -> String {
        UUID().uuidString
    }
}
