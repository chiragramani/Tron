//
//  File.swift
//  
//
//  Created by Chirag Ramani on 13/02/21.
//

import Foundation
import XcodeProj

protocol SwiftPackageWriting {
    func add(packages: [SwiftPackage],
           to projectURL: URL) throws
}

struct SwiftPackageWriter: SwiftPackageWriting {
    
    init(logger: TronLogging = TronLogger(),
         projectAssistant: TronProjectAssisting = TronProjectAssistant()) {
        self.logger = logger
        self.projectAssistant = projectAssistant
    }
    
    func add(packages: [SwiftPackage],
           to projectURL: URL) throws {
        guard !packages.isEmpty else { return }
        
        let templateProject = try XcodeProj(path: .init(projectURL.path))
        
        logger.logInfo("🚀 Adding packages...")
        try! projectAssistant.addPackages(packages: packages,
                                          to: templateProject)
        
        logger.logInfo("🚀 Updating Project...")
        try! projectAssistant.writeProject(templateProject,
                                           to: projectURL)
    }
    
    // MARK: Private
    
    private let logger: TronLogging
    private let projectAssistant: TronProjectAssisting
}
