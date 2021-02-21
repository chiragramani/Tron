//
//  TronConfigInputCommand.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation
import ArgumentParser

public struct TronConfigInputCommand: ParsableCommand {
    
    public init() { }
    
    @Argument(help: "Path to the Tron Config File - please refer to SampleConfig.json for reference",
              transform: URL.init(fileURLWithPath:))
    private var tronConfigFilePath: URL
    
    private var config: TronConfig!
    
    @Flag(name: .shortAndLong)
    var verbose = false
    
    public mutating func validate() throws {
        guard FileManager.default.fileExists(atPath: tronConfigFilePath.path) else {
            throw ValidationError("File does not exist at \(tronConfigFilePath.path)")
        }
        let data = try Data(contentsOf: tronConfigFilePath)
        config = try JSONDecoder().decode(TronConfig.self, from: data)
        
    }
    
    public func run() throws {
        ShellImpl.isVerbose = verbose
        TronCore().start(with: config)
    }
}
