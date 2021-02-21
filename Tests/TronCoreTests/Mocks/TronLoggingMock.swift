//
//  File.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation
@testable import TronCore

final class TronLoggingMock: TronLogging {
    
    var logInfoCallCount = 0
    var logSuccessCallCount = 0
    var logErrorCallCount = 0
    
    var logInfoHandler: ((String) -> ())!
    var logSuccessHandler: ((String) -> ())!
    var logErrorHandler: ((String) -> ())!
    
    func logInfo(_ message: String) {
        logInfoCallCount += 1
        logInfoHandler(message)
    }
    
    func logSuccess(_ message: String) {
        logSuccessCallCount += 1
        logSuccessHandler(message)
    }
    
    func logError(_ message: String) {
        logErrorCallCount += 1
        logErrorHandler(message)
    }
}
