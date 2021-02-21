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
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func templateFolderURL(targetOS: TargetOS) -> URL {
        let templateProjectPath = Bundle.module.path(forResource: Constants.template,
                                                     ofType: Constants.xcodeProj,
                                                     inDirectory: "\(targetOS.rawValue)/Template")
        return URL(fileURLWithPath: templateProjectPath!).deletingLastPathComponent()
    }
    
    lazy var templateDestinationDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString,
                                                                                                     isDirectory: true)
    
    lazy var templateWithDepsDestinationDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString,
                                                                                                             isDirectory: true)
    lazy var templateProjectURL = templateDestinationDirectoryURL.appendingPathComponent(Constants.templateXcodeProject)
    lazy var templateWithDepsProjectURL = templateWithDepsDestinationDirectoryURL.appendingPathComponent(Constants.templateXcodeProject)
    lazy var templateIPAURL = templateDestinationDirectoryURL.appendingPathComponent(Constants.templateIPA)
    lazy var templateWithDepsIPAURL = templateWithDepsDestinationDirectoryURL.appendingPathComponent(Constants.templateIPA)
    
    lazy var templateAppURL = templateDestinationDirectoryURL.appendingPathComponent(Constants.archiveAppPath,
                                                                                     isDirectory: true)
    lazy var templateWithDepsAppURL = templateWithDepsDestinationDirectoryURL.appendingPathComponent(Constants.archiveAppPath,
                                                                                                     isDirectory: true)
    
    lazy var templateFrameworksDirectoryURL = templateAppURL.appendingPathComponent(Constants.frameworks,
                                                                                    isDirectory: true)
    lazy var templatWithDepsFrameworksDirectoryURL = templateWithDepsAppURL.appendingPathComponent(Constants.frameworks,
                                                                                                   isDirectory: true)
    
    // MARK: Private
    
    private let fileManager: FileManager
    
    private enum Constants {
        static let template = "Template"
        static let xcodeProj = "xcodeproj"
        static let frameworks = "Frameworks"
        static let templateIPA = "Template.ipa"
        static let templateXcodeProject = "Template.xcodeproj"
        static let archiveAppPath = "Template.xcarchive/Products/Applications/Template.app"
    }
    
}
