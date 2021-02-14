//
//  File.swift
//  
//
//  Created by Chirag Ramani on 13/02/21.
//

import Foundation

enum TronConfigTransformerError: Error {
    case noDependenciesFound
}

struct TronConfigTransformer {
    func transform(_ config: TronConfig) throws -> TronConfig {
        let packages = config.packages.filter { $0.isValid }
        let pods = config.pods.filter { $0.isValid }
        guard (packages.count + pods.count) > 0 else {
            throw TronConfigTransformerError.noDependenciesFound
        }
        return TronConfig(packages: packages,
                          linkerArguments: config.linkerArguments,
                          targetOS: config.targetOS,
                          pods: pods,
                          minDeploymentTarget: config.minDeploymentTarget)
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
            return local.absolutePath.isNonEmpty
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
        name.isNonEmpty && version.isNonEmpty
    }
}
