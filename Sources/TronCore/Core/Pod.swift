//
//  File.swift
//  
//
//  Created by Chirag Ramani on 07/03/21.
//

import Foundation

enum PodError: Error {
    case unknownError
}

enum Pod: CustomDebugStringConvertible {
    
    case remote(RemotePod)
    case local(LocalPod)
    
    // MARK: CustomDebugStringConvertible
    
    var debugDescription: String {
        switch self {
        case .local(let localPod):
            return localPod.debugDescription
        case .remote(let remotePod):
            return remotePod.debugDescription
        }
    }
}

struct RemotePod: Codable, CustomDebugStringConvertible {
    let name: String
    let exactVersion: String
    
    // MARK: CustomDebugStringConvertible
    
    var debugDescription: String {
        "\(name) - \(exactVersion)"
    }
    
}

struct LocalPod: Codable, CustomDebugStringConvertible {
    let name: String
    let relativePath: String
    
    // MARK: CustomDebugStringConvertible
    
    var debugDescription: String {
        "\(name) - \(relativePath)"
    }
}

extension Pod: Decodable {
    enum CodingKeys: String, CodingKey {
        case remote, local
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let remotePackage = try container.decodeIfPresent(RemotePod.self, forKey: .remote) {
            self = .remote(remotePackage)
        } else if let localPackage = try container.decodeIfPresent(LocalPod.self, forKey: .local){
            self = .local(localPackage)
        } else {
            throw PodError.unknownError
        }
    }
}

