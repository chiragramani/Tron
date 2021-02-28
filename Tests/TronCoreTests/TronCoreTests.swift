//
//  File.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation
import XCTest
@testable import TronCore

final class TronCoreTests: XCTestCase {
    private let tronLogger = TronLoggingMock()
    private var sut: TronCore!
    private let tronConfigTransformer = TronConfigTransformingMock()
    private let dependenciesImpactOnAppSizeMeasurer = DependenciesImpactOnAppSizeMeasuringMock()
    
    override func setUp() {
        super.setUp()
        sut = TronCore(logger: tronLogger,
                       tronConfigTransformer: tronConfigTransformer,
                       appSizeImpactMeasurer: dependenciesImpactOnAppSizeMeasurer)
    }
    
    func test_start_validConfig() {
        // given
        tronConfigTransformer.transformHandler = { _ in self.validatedConfig }
        dependenciesImpactOnAppSizeMeasurer.determineDepedenciesImpactOnAppSizeHandler = { }
        tronLogger.logSuccessHandler = { XCTAssertEqual($0, "All done 🎉") }
        XCTAssertEqual(tronLogger.logSuccessCallCount, 0)
        XCTAssertEqual(tronConfigTransformer.transformCallCount, 0)
        XCTAssertEqual(dependenciesImpactOnAppSizeMeasurer.determineDepedenciesImpactOnAppSizeCallCount, 0)
        
        // when
        sut.start(with: config)
        
        // then
        XCTAssertEqual(tronLogger.logSuccessCallCount, 1)
        XCTAssertEqual(tronConfigTransformer.transformCallCount, 1)
        XCTAssertEqual(dependenciesImpactOnAppSizeMeasurer.determineDepedenciesImpactOnAppSizeCallCount, 1)
    }
    
    func test_start_noDependencies() {
        // given
        tronConfigTransformer.transformHandler = { _ in
            throw TronConfigTransformerError.noDependenciesFound
        }
        tronLogger.logErrorHandler = { XCTAssertEqual($0, "No valid dependencies found.") }
        XCTAssertEqual(tronLogger.logErrorCallCount, 0)
        XCTAssertEqual(tronConfigTransformer.transformCallCount, 0)
        
        // when
        sut.start(with: config)
        
        // then
        XCTAssertEqual(tronLogger.logErrorCallCount, 1)
        XCTAssertEqual(tronConfigTransformer.transformCallCount, 1)
    }
    
    func test_start_otherError() {
        // given
        tronConfigTransformer.transformHandler = { _ in
            throw TestError.other
        }
        tronLogger.logErrorHandler = { XCTAssertEqual($0, "Invalid config file.") }
        XCTAssertEqual(tronLogger.logErrorCallCount, 0)
        XCTAssertEqual(tronConfigTransformer.transformCallCount, 0)
        
        // when
        sut.start(with: config)
        
        // then
        XCTAssertEqual(tronLogger.logErrorCallCount, 1)
        XCTAssertEqual(tronConfigTransformer.transformCallCount, 1)
    }
    
    func test_start_appSizeAnalysisError() {
        // given
        tronConfigTransformer.transformHandler = { _ in self.validatedConfig }
        dependenciesImpactOnAppSizeMeasurer.determineDepedenciesImpactOnAppSizeHandler = {
            throw TestError.other
        }
        tronLogger.logErrorHandler = { XCTAssertEqual($0,
                                                      "Error: \(TestError.other.localizedDescription)") }
        XCTAssertEqual(tronLogger.logErrorCallCount, 0)
        XCTAssertEqual(tronConfigTransformer.transformCallCount, 0)
        XCTAssertEqual(dependenciesImpactOnAppSizeMeasurer.determineDepedenciesImpactOnAppSizeCallCount, 0)
        
        // when
        sut.start(with: config)
        
        // then
        XCTAssertEqual(tronLogger.logErrorCallCount, 1)
        XCTAssertEqual(tronConfigTransformer.transformCallCount, 1)
        XCTAssertEqual(dependenciesImpactOnAppSizeMeasurer.determineDepedenciesImpactOnAppSizeCallCount, 1)
    }
    
    private let validatedConfig = TronValidatedConfig(packages: [],
                                                      linkerArguments: .init(codeSignIdentity: "",
                                                                             isCodeSigningRequired: false,
                                                                             isCodeSigningAllowed: false,
                                                                             codeSignEntitlements: "",
                                                                             architecture: ""),
                                                      targetOS: .iOS,
                                                      pods: [],
                                                      minDeploymentTarget: "14.3",
                                                      shouldPerformDownloadSizeAnalysis: false,
                                                      embedsSwiftRuntime: false)
    
    private let config = TronConfig(packages: [],
                                    linkerArguments: .init(codeSignIdentity: "",
                                                           isCodeSigningRequired: false,
                                                           isCodeSigningAllowed: false,
                                                           codeSignEntitlements: "",
                                                           architecture: ""),
                                    targetOS: .iOS,
                                    pods: [],
                                    minDeploymentTarget: "14.3",
                                    shouldPerformDownloadSizeAnalysis: false)
}
