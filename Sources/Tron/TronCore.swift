//
//  TronCore.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import XcodeProj
import Foundation

final class TronCore {
    
    init(projectAssistant: TronProjectAssisting = TronProjectAssistant(),
         tronFileManager: TronFileManaging = TronFileManager(),
         shell: Shell = Shell(),
         urlProvider: TronURLProviding = TronURLProvider(),
         logger: TronLogging = TronLogger()) {
        self.projectAssistant = projectAssistant
        self.tronFileManager = tronFileManager
        self.shell = shell
        self.urlProvider = urlProvider
        self.logger = logger
    }
    
    func start(with config: TronConfig) {
        logger.logInfo("🚀 Processing template...")
        
        logger.logInfo("🚀 Copying templates to temp directories for analysis...")
        
        // 2. Copy it in two different directories - one for default and the other for adding a swift package.
        try! tronFileManager.copyFolders(to: urlProvider.templateDestinationDirectoryURL,
                                         from: urlProvider.templateFolderURL(targetOS: config.targetOS))
        
        try! tronFileManager.copyFolders(to: urlProvider.templateWithDepsDestinationDirectoryURL,
                                         from: urlProvider.templateFolderURL(targetOS: config.targetOS))
        
        logger.logInfo("Template Project Directory URL: \(urlProvider.templateDestinationDirectoryURL.absoluteString)")
        logger.logInfo("Template With Dependencies Project Directory URL: \(urlProvider.templateWithDepsDestinationDirectoryURL.absoluteString)")
        
        
        let templateProject = try! XcodeProj(path: .init(urlProvider.templateWithDepsProjectURL.path))
        
        logger.logInfo("🚀 Adding packages...")
        try! projectAssistant.addPackages(packages: config.packages,
                                          to: templateProject)
        
        logger.logInfo("🚀 Updating Project...")
        try! projectAssistant.writeProject(templateProject,
                                           to: urlProvider.templateWithDepsProjectURL)
        
        
        // Generating first archive
        logger.logInfo("🚀 Generating Template Archive...")
        shell.execute(ShellCommand.archiveProject(urlProvider.templateDestinationDirectoryURL),
                      logger: logger)
        
        logger.logInfo("🚀 Generating Template Archive IPA...")
        shell.execute(ShellCommand.exportIPA(urlProvider.templateDestinationDirectoryURL),
                      logger: logger)
        
        
        // Generating Second archive
        logger.logInfo("🚀 Generating Template with Alamofire Archive...")
        shell.execute(ShellCommand.archiveProject(urlProvider.templateWithDepsDestinationDirectoryURL),
                                                  logger: logger)
        
        logger.logInfo("🚀 Generating Template with Alamofire Archive IPA...")
        shell.execute(ShellCommand.exportIPA(urlProvider.templateWithDepsDestinationDirectoryURL),
                      logger: logger)
        
        // Computing Size contribution
        logger.logInfo("🚀 Computing Size contribution...")
        
        let ipaSizeDifferenceInBytes = try! tronFileManager.fileSizeDifferenceBetween(url1: urlProvider.templateIPAURL,
                                                                                      url2: urlProvider.templateWithDepsIPAURL)
        let formattedDifference = byteCountFormatter.string(fromByteCount: Int64(ipaSizeDifferenceInBytes))
        
        logger.logSuccess("Approximate contribution is: \(ipaSizeDifferenceInBytes) bytes = \(formattedDifference)")
        
        logger.logInfo("🚀 Performing Cleanup...")
        try? tronFileManager.removeItem(at: urlProvider.templateDestinationDirectoryURL)
        try? tronFileManager.removeItem(at: urlProvider.templateWithDepsDestinationDirectoryURL)
        
        logger.logSuccess("All done 🎉")
    }
    
    
    
    // MARK: Private
    
    private let projectAssistant: TronProjectAssisting
    private let tronFileManager: TronFileManaging
    private let shell: Shell
    private let urlProvider: TronURLProviding
    private let logger: TronLogging
    
    private lazy var byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        return formatter
    }()
}



