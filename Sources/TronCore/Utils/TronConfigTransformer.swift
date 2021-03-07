//
//  File.swift
//  
//
//  Created by Chirag Ramani on 13/02/21.
//

import Foundation

enum TronConfigTransformerError: Error {
    case noDependenciesFound
    case invalidMinDeploymentTargetVersion
}

protocol TronConfigTransforming {
    func transform(_ config: TronConfig) throws -> TronValidatedConfig
}

struct TronValidatedConfig: Decodable {
    let packages: [SwiftPackage]
    let linkerArguments: LinkerArguments
    let targetOS: TargetOS
    let pods: [Pod]
    let minDeploymentTarget: String
    let shouldPerformDownloadSizeAnalysis: Bool
    let embedsSwiftRuntime: Bool
}

struct TronConfigTransformer: TronConfigTransforming {
    func transform(_ config: TronConfig) throws -> TronValidatedConfig {
        let packages = config.packages.filter { $0.isValid }
        let pods = config.pods.filter { $0.isValid }
        guard (packages.count + pods.count) > 0 else {
            throw TronConfigTransformerError.noDependenciesFound
        }
        guard let minDeploymentTargetVersion = config.minDeploymentTargetVersion else {
            throw TronConfigTransformerError.invalidMinDeploymentTargetVersion
        }
        return TronValidatedConfig(packages: packages,
                          linkerArguments: config.linkerArguments,
                          targetOS: config.targetOS,
                          pods: pods,
                          minDeploymentTarget: config.minDeploymentTarget,
                          shouldPerformDownloadSizeAnalysis: config.shouldPerformDownloadSizeAnalysis,
                          embedsSwiftRuntime: embedsSwiftRuntime(givenMajorVersion: minDeploymentTargetVersion.majorVersion,
                                                                 minorVersion: minDeploymentTargetVersion.minorVersion))
    }
    
    // MARK: Private
    
    private func embedsSwiftRuntime(givenMajorVersion majorVersion: Double, minorVersion: Double) -> Bool {
        if majorVersion > 12 || (majorVersion == 12 && minorVersion >= 2) {
            return false
        } else {
            return true
        }
    }
}

private extension SwiftPackage {
    var isValid: Bool {
        switch self {
        case .remote(let remote):
            return remote.productName.isNonEmpty
                && remote.exactVersion.isNonEmpty
                && remote.repositoryURL.isNonEmpty
        case .local(let local):
            return local.relativePath.isNonEmpty
                && local.productName.isNonEmpty
        }
    }
}

private extension String {
    var isNonEmpty: Bool {
        !isEmpty
    }
}

private extension Pod {
    var isValid: Bool {
        /// TODO: We have an opportunity to improve the validation here. isNonEmpty can be a good starter validation check, but we also need to make sure whether paths follow the bases regex and files are present at those locations also or not. 
        switch self {
        case .local(let localPod):
            return localPod.name.isNonEmpty && localPod.relativePath.isNonEmpty
        case .remote(let remotePod):
            return remotePod.exactVersion.isNonEmpty && remotePod.name.isNonEmpty
        }
        
    }
}

private extension TronConfig {
    var minDeploymentTargetVersion: (majorVersion: Double, minorVersion: Double)? {
        let components = minDeploymentTarget.components(separatedBy: ".")
        guard let majorVersion = components.first.map({ Double($0) }) ?? nil else { return nil }
        var minorVersion: Double = 0
        if components.count > 1,
           let secondComponent = Double(components[1]) {
            minorVersion = secondComponent
        }
        return (majorVersion, minorVersion)
    }
}

