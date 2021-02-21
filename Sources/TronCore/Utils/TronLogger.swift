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
        print("\(message)")
    }
    
    func logError(_ message: String) {
        print("‼️ \(message)")
    }
    
    func logSuccess(_ message: String) {
        print("✅ \(message)")
    }
}

extension TronLogging {
    
    func logInfoOnNewLine(_ message: String) {
        print("\n\(message)")
    }
    
    func logInfo(_ message: String,
                 subMessages: [String],
                 footerInfo: String? = nil) {
        logInfo(message)
        for (index, value) in subMessages.enumerated() {
            logInfo("\t\(index + 1).  \(value)")
        }
        if let footerInfo = footerInfo {
            logInfo(footerInfo)
        }
    }
    func logInfoOnNewLine(_ message: String,
                 subMessages: [String],
                 footerInfo: String? = nil) {
        logInfoOnNewLine(message)
        for (index, value) in subMessages.enumerated() {
            logInfo("\t\(index + 1).  \(value)")
        }
        if let footerInfo = footerInfo {
            logInfo(footerInfo)
        }
    }
}
