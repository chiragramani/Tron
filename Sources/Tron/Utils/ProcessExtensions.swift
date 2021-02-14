//
//  ProcessExtensions.swift
//  
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation

extension Process {
    @discardableResult func launchBash(withCommand command: String, logger: TronLogging) -> String? {
        launchPath = "/bin/bash"
        arguments = ["--login", "-c", command]
        
        let pipe = Pipe()
        standardOutput = pipe
        
        // Silent errors by assigning a dummy pipe to the error output
        let errorPipe = Pipe()
        standardError = errorPipe
        
        let errorOutputHandle = errorPipe.fileHandleForReading
        errorOutputHandle.waitForDataInBackgroundAndNotify()
        
        let outputHandle = pipe.fileHandleForReading
        outputHandle.waitForDataInBackgroundAndNotify()
        
        outputHandle.readabilityHandler = { pipe in
            guard let currentOutput = String(data: pipe.availableData, encoding: .utf8) else {
                logger.logError("🔨 Error decoding data: \(pipe.availableData)")
                return
            }
            
            guard !currentOutput.isEmpty else {
                return
            }
            logger.logInfo(currentOutput)
        }
        
        errorOutputHandle.readabilityHandler = { pipe in
            guard let currentOutput = String(data: pipe.availableData, encoding: .utf8) else {
                logger.logError("🔨 Error decoding data: \(pipe.availableData)")
                return
            }
            
            guard !currentOutput.isEmpty else {
                return
            }
            logger.logInfo(currentOutput)
        }
        
        
        launch()
        
        pipe.fileHandleForReading.readDataToEndOfFile()
        
        waitUntilExit()
        
        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: outputData, encoding: .utf8)
    }
}
