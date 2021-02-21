//
//  File.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation

final class TestFileManager: FileManager {
    
    override var temporaryDirectory: URL {
        return URL(string: "file://T/")!
    }
}

