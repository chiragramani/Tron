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
    var templateProjectURL: URL { get }
    var templateWithDepsProjectURL: URL { get }
    var templateIPAURL: URL { get }
    var templateWithDepsIPAURL: URL { get }
    var templateAppURL: URL { get }
    var templateWithDepsAppURL: URL { get }
    var templateFrameworksDirectoryURL: URL { get }
    var templatWithDepsFrameworksDirectoryURL: URL { get }
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
    lazy var templateProjectURL = templateDestinationDirectoryURL.appendingPathComponent("Template.xcodeproj")
    lazy var templateWithDepsProjectURL = templateWithDepsDestinationDirectoryURL.appendingPathComponent("Template.xcodeproj")
    lazy var templateIPAURL = templateDestinationDirectoryURL.appendingPathComponent("Template.ipa")
    lazy var templateWithDepsIPAURL = templateWithDepsDestinationDirectoryURL.appendingPathComponent("Template.ipa")
    
    lazy var templateAppURL = templateDestinationDirectoryURL.appendingPathComponent("Template.xcarchive/Products/Applications/Template.app",
                                                                                     isDirectory: true)
    lazy var templateWithDepsAppURL = templateWithDepsDestinationDirectoryURL.appendingPathComponent("Template.xcarchive/Products/Applications/Template.app",
                                                                                                     isDirectory: true)
    
    lazy var templateFrameworksDirectoryURL = templateAppURL.appendingPathComponent("Frameworks",
                                                                                    isDirectory: true)
    lazy var templatWithDepsFrameworksDirectoryURL = templateWithDepsAppURL.appendingPathComponent("Frameworks",
                                                                                                   isDirectory: true)
    
}
