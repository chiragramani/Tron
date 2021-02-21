//
//  TronCore.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation

final class TronCore {
    
    init(tronFileManager: TronFileManaging = TronFileManager(),
         shell: Shell = Shell(),
         urlProvider: TronURLProviding = TronURLProvider(),
         logger: TronLogging = TronLogger(),
         packageWriter: SwiftPackageWriting = SwiftPackageWriter(),
         podFileWriter: PodFileWriting = PodFileWriter(),
         projTargetVersionWriter: PBXProjTargetVersionWriting = PBXProjTargetVersionWriter()) {
        self.tronFileManager = tronFileManager
        self.shell = shell
        self.urlProvider = urlProvider
        self.logger = logger
        self.packageWriter = packageWriter
        self.podFileWriter = podFileWriter
        self.projTargetVersionWriter = projTargetVersionWriter
    }
    
    func start(with config: TronConfig) {
        do {
            let config = try TronConfigTransformer().transform(config)
            startCore(config)
        } catch TronConfigTransformerError.noDependenciesFound {
            logger.logError("No valid dependencies found.")
        } catch {
            logger.logError("Invalid config file.")
        }
    }
    
    
    
    // MARK: Private
    
    private func startCore(_ config: TronConfig) {
        do {
            logger.logInfo("🚀 Processing template...")
            
            logger.logInfo("🚀 Copying templates to temp directories for analysis...")
            
            // Copy it in two different directories - one for default and the other for adding a swift package.
            try tronFileManager.copyFolders(to: urlProvider.templateDestinationDirectoryURL,
                                             from: urlProvider.templateFolderURL(targetOS: config.targetOS))
            
            try tronFileManager.copyFolders(to: urlProvider.templateWithDepsDestinationDirectoryURL,
                                             from: urlProvider.templateFolderURL(targetOS: config.targetOS))
            
            logger.logInfo("Template Project Directory URL: \(urlProvider.templateDestinationDirectoryURL.absoluteString)")
            logger.logInfo("Template With Dependencies Project Directory URL: \(urlProvider.templateWithDepsDestinationDirectoryURL.absoluteString)")
            
            // Updating target version
            try [urlProvider.templateProjectURL,
             urlProvider.templateWithDepsProjectURL].forEach {
                logger.logInfo("🚀 Configuring Minimum Deployment Target")
                try projTargetVersionWriter.configure(projectAtURL: $0,
                                                  for: config.targetOS,
                                                  targetVersion: config.minDeploymentTarget)
             }
            
            
            
            try packageWriter.add(packages: config.packages,
                                   to: urlProvider.templateWithDepsProjectURL)
            
            try podFileWriter.add(config.pods,
                                   minDeploymentTarget: config.minDeploymentTarget,
                                   projectURL: urlProvider.templateWithDepsProjectURL,
                                   targetOS: config.targetOS)
            
            // Generating first archive
            logger.logInfo("🚀 Generating Template Archive...")
            shell.execute(ShellCommand.archiveProject(urlProvider.templateDestinationDirectoryURL,
                                                      isWorkSpace: false,
                                                      linkerArguments: config.linkerArguments))
            
            logger.logInfo("🚀 Generating Template Archive IPA...")
            shell.execute(ShellCommand.exportIPA(urlProvider.templateDestinationDirectoryURL))
            
            
            // Generating Second archive
            logger.logInfo("🚀 Generating Template with Dependencies added...")
            shell.execute(ShellCommand.archiveProject(urlProvider.templateWithDepsDestinationDirectoryURL,
                                                      isWorkSpace: !config.pods.isEmpty,
                                                      linkerArguments: config.linkerArguments))
            
            logger.logInfo("🚀 Generating Template with Dependencies IPA...")
            shell.execute(ShellCommand.exportIPA(urlProvider.templateWithDepsDestinationDirectoryURL))
            
            // Computing Size contribution
            logger.logInfo("🚀 Computing Size contribution...")
            
            let ipaSizeDifference = try tronFileManager.fileSizeDifferenceBetween(url1: urlProvider.templateIPAURL,
                                                                                          url2: urlProvider.templateWithDepsIPAURL)
            
            logger.logSuccess("Approximate contribution is: \(ipaSizeDifference.differenceInBytes) bytes = \(ipaSizeDifference.formattedDifference)")
            
            logger.logInfo("🚀 The temporary directories are the following:\n1. Base project:  \(urlProvider.templateDestinationDirectoryURL)\n2. Project/Workspace post adding dependencies:  \(urlProvider.templateWithDepsDestinationDirectoryURL)\nPlease have a look to explore the projects, their base setup, impact post adding the dependencies, their respective archives/IPAs etc.")
            
            logger.logSuccess("All done 🎉")
        } catch let error {
            logger.logError("Error: \(error.localizedDescription)")
        }
    }
    
    private let tronFileManager: TronFileManaging
    private let shell: Shell
    private let urlProvider: TronURLProviding
    private let logger: TronLogging
    private let packageWriter: SwiftPackageWriting
    private let podFileWriter: PodFileWriting
    private let projTargetVersionWriter: PBXProjTargetVersionWriting
}



