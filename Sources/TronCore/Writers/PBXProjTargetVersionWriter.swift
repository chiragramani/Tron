//
//  PBXProjTargetVersionWriter.swift
//  
//
//  Created by Chirag Ramani on 21/02/21.
//

import Foundation
import XcodeProj

protocol PBXProjTargetVersionWriting {
    func configure(projectAtURL projectURL: URL,
                   for targetOS: TargetOS,
                   targetVersion: String) throws
}

enum PBXProjTargetVersionWriterError: Error {
    case couldNotSetTargetVersion(projectURL: URL,
                                  systemError: Error)
}

final class PBXProjTargetVersionWriter: PBXProjTargetVersionWriting {
    
    init(projectAssistant: TronProjectAssisting = TronProjectAssistant()) {
        self.projectAssistant = projectAssistant
    }
    
    func configure(projectAtURL projectURL: URL,
                   for targetOS: TargetOS,
                   targetVersion: String) throws {
        do {
            let templateProject = try XcodeProj(path: .init(projectURL.path))
            let key = targetOS.deploymentTargetBuildSettingKey
            for conf in templateProject.pbxproj.buildConfigurations where conf.buildSettings[key] != nil {
                conf.buildSettings[key] = targetVersion
            }
            try projectAssistant.writeProject(templateProject,
                                               to: projectURL)
        } catch let error {
            throw PBXProjTargetVersionWriterError.couldNotSetTargetVersion(projectURL: projectURL,
                                                                           systemError: error)
        }
        
    }
    
    // MARK: Private
    
    private let projectAssistant: TronProjectAssisting
}

private extension TargetOS {
    var deploymentTargetBuildSettingKey: String {
        switch self {
        case .iOS:
            return "IPHONEOS_DEPLOYMENT_TARGET"
        }
    }
}

extension PBXProjTargetVersionWriterError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .couldNotSetTargetVersion(projectURL,
                                      systemError):
            return "Could not set minimum depoyment target version for project at url location: \(projectURL.absoluteString) because of error: \(systemError.localizedDescription)"
        }
    }
}

