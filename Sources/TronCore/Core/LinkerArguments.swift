//
//  LinkerArguments.swift
//  
//
//  Created by Chirag Ramani on 14/02/21.
//

import Foundation

struct LinkerArguments: Decodable {
    let codeSignIdentity: String
    let isCodeSigningRequired: Bool
    let isCodeSigningAllowed: Bool
    let codeSignEntitlements: String
    let architecture: String
}
