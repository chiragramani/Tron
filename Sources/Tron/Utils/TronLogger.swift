//
//  TronLogger.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation

protocol TronLogging {
    func logInfo(_ message: String)
    func logSuccess(_ message: String)
    func logError(_ message: String)
}

struct TronLogger: TronLogging {
    func logInfo(_ message: String) {
        print("\(message)\n")
    }
    
    func logError(_ message: String) {
        print("‼️ \(message)\n")
    }
    
    func logSuccess(_ message: String) {
        print("✅ \(message)\n")
    }
}
