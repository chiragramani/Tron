//
//  TronPackageWriter.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation
import XcodeProj

protocol TronProjectAssisting {
    func addPackages(packages: [SwiftPackage],
                     to project: XcodeProj) throws
    func writeProject(_ project: XcodeProj,
                      to location: URL) throws
}

struct TronProjectAssistant: TronProjectAssisting {
    
    init(logger: TronLogging = TronLogger()) {
        self.logger = logger
    }
    
    func addPackages(packages: [SwiftPackage],
                     to project: XcodeProj) throws {
        let pbjProject = project.pbxproj.projects[0]
        try packages.forEach { (package) in
            switch package {
            case .local(let localPackage):
                logger.logInfo("\tAdding Local Package: \(localPackage) ...")
                _ = try pbjProject.addLocalSwiftPackage(path: .init(localPackage.relativePath),
                                                        productName: localPackage.productName,
                                                        targetName:"Template")
            case .remote(let remotePackage):
                logger.logInfo("\tAdding Remote Package: \(remotePackage) ...")
                _ = try pbjProject.addSwiftPackage(repositoryURL: remotePackage.repositoryURL,
                                                   productName: remotePackage.productName,
                                                   versionRequirement: .exact(remotePackage.exactVersion),
                                                   targetName: "Template")
            }
        }
    }
    
    func writeProject(_ project: XcodeProj,
                      to location: URL) throws {
        try project.write(path: .init(location.path))
    }
    
    // MARK: Private
    
    private let logger: TronLogging

}
