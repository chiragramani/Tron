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

enum SwiftPackageWriterError: Error {
    case couldNotAddPackages(packages: [SwiftPackage],
                             projectURL: URL,
                             systemError: Error)
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
        do {
            let templateProject = try XcodeProj(path: .init(projectURL.path))
            
            logger.logInfo("🚀 Adding packages...")
            try projectAssistant.addPackages(packages: packages,
                                              to: templateProject)
            
            logger.logInfo("🚀 Updating Project...")
            try projectAssistant.writeProject(templateProject,
                                               to: projectURL)
        } catch let error {
            throw SwiftPackageWriterError.couldNotAddPackages(packages: packages,
                                                              projectURL: projectURL,
                                                              systemError: error)
        }
    }
    
    // MARK: Private
    
    private let logger: TronLogging
    private let projectAssistant: TronProjectAssisting
}

extension SwiftPackageWriterError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .couldNotAddPackages(packages,
                                      projectURL,
                                      systemError):
            return "Could not add packages: \(packages) to project at location: \(projectURL.absoluteString) because of error: \(systemError.localizedDescription)"
        }
    }
}
