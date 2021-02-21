//
//  File.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation

enum TestError: Error, LocalizedError {
    case other
    
    var errorDescription: String? {
        return "The operation couldn’t be completed."
    }
}
