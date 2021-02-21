//
//  SwiftPackage.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation

enum PackageError: Error {
    case unknownError
}

enum SwiftPackage {
    case remote(SwiftRemotePackage)
    case local(SwiftLocalPackage)
}

struct SwiftRemotePackage: Codable, CustomDebugStringConvertible {
    let productName: String
    let exactVersion: String
    let repositoryURL: String
    
    // MARK: CustomDebugStringConvertible
    
    var debugDescription: String {
        "\(productName) - \(repositoryURL) - \(exactVersion)"
    }
    
}

struct SwiftLocalPackage: Codable, CustomDebugStringConvertible {
    let productName: String
    let absolutePath: String
    
    // MARK: CustomDebugStringConvertible
    
    var debugDescription: String {
        "\(productName) - \(absolutePath)"
    }
}

extension SwiftPackage: Decodable {
    enum CodingKeys: String, CodingKey {
        case remote, local
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let remotePackage = try container.decodeIfPresent(SwiftRemotePackage.self, forKey: .remote) {
            self = .remote(remotePackage)
        } else if let localPackage = try container.decodeIfPresent(SwiftLocalPackage.self, forKey: .local){
            self = .local(localPackage)
        } else {
            throw PackageError.unknownError
        }
    }
}
