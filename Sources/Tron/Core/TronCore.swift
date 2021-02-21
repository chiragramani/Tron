//
//  TronCore.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation

struct TronCore {
    
    init(logger: TronLogging = TronLogger(),
         appSizeImpactMeasurer: DependenciesImpactOnAppSizeMeasuring = DependenciesImpactOnAppSizeMeasurer()) {
        self.logger = logger
        self.appSizeImpactMeasurer = appSizeImpactMeasurer
    }
    
    func start(with config: TronConfig) {
        do {
            let config = try TronConfigTransformer().transform(config)
            startCore(config)
        } catch TronConfigTransformerError.noDependenciesFound {
            logger.logError("No valid dependencies found.")
        } catch {
            logger.logError("Invalid config file.")
        }
    }
    
    
    // MARK: Private
    
    private let logger: TronLogging
    private let appSizeImpactMeasurer: DependenciesImpactOnAppSizeMeasuring
    
    private func startCore(_ config: TronConfig) {
        do {
            try appSizeImpactMeasurer.determineDepedenciesImpactOnAppSize(givenConfig: config)
            logger.logSuccess("All done 🎉")
        } catch let error {
            logger.logError("Error: \(error.localizedDescription)")
        }
    }
}



