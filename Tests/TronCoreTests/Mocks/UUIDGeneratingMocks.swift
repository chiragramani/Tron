//
//  File.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation
@testable import TronCore

final class UUIDGeneratingMock: UUIDGenerating {
    
    var generateUUIDCallCount = 0
    var uuid = "uuid"
    
    func generateUUID() -> String {
        uuid
    }
}
