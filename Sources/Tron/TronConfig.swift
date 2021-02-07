//
//  TronConfig.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation

enum TargetOS: String, Decodable {
    case iOS
}

struct TronConfig: Decodable {
    let packages: [SwiftPackage]
    let linkerArguments: String
    let targetOS: TargetOS
}
