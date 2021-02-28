//
//  DependenciesImpactOnAppSizeMeasuringMock.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation
@testable import TronCore

final class DependenciesImpactOnAppSizeMeasuringMock: DependenciesImpactOnAppSizeMeasuring {
    
    var determineDepedenciesImpactOnAppSizeCallCount = 0
    var determineDepedenciesImpactOnAppSizeHandler: (() throws -> ())?
    
    func determineDepedenciesImpactOnAppSize(givenConfig config: TronValidatedConfig) throws {
        determineDepedenciesImpactOnAppSizeCallCount += 1
        try determineDepedenciesImpactOnAppSizeHandler?()
    }
    
}
