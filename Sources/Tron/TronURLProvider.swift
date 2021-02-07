//
//  TronURLProvider.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation

protocol TronURLProviding {
    func templateFolderURL(targetOS: TargetOS) -> URL
    var templateDestinationDirectoryURL: URL { get }
    var templateWithDepsDestinationDirectoryURL: URL { get }
    var templateWithDepsProjectURL: URL { get }
    var templateIPAURL: URL { get }
    var templateWithDepsIPAURL: URL { get }
}


final class TronURLProvider: TronURLProviding {
    
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func templateFolderURL(targetOS: TargetOS) -> URL {
        
        let templateProjectPath = Bundle.module.path(forResource: "Template",
                                                     ofType: "xcodeproj",
                                                     inDirectory: "\(targetOS.rawValue)/Template")
        return URL(fileURLWithPath: templateProjectPath!).deletingLastPathComponent()
    }
    
    lazy var templateDestinationDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString,
                                                                                               isDirectory: true)
    
    lazy var templateWithDepsDestinationDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString,
                                                                                                       isDirectory: true)
    
    lazy var templateWithDepsProjectURL = templateWithDepsDestinationDirectoryURL.appendingPathComponent("Template.xcodeproj")
    lazy var templateIPAURL = templateDestinationDirectoryURL.appendingPathComponent("Template.ipa")
    lazy var templateWithDepsIPAURL = templateWithDepsDestinationDirectoryURL.appendingPathComponent("Template.ipa")
    
}
