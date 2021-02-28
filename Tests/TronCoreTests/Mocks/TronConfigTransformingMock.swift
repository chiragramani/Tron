//
//  TronConfigTransformingMock.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation
@testable import TronCore

final class TronConfigTransformingMock: TronConfigTransforming {
    
    var transformCallCount = 0
    var transformHandler: ((TronConfig) throws -> TronValidatedConfig)!
    
    func transform(_ config: TronConfig) throws -> TronValidatedConfig {
        transformCallCount += 1
        return try transformHandler(config)
    }
}
