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
         projTargetVersionWriter: PBXProjTargetVersionWriting = PBXProjTargetVersionWriter(),
         frameworkDifferencesProvider: FrameworkDifferencesProviding = FrameworkDifferencesProvider()) {
        self.tronFileManager = tronFileManager
        self.shell = shell
        self.urlProvider = urlProvider
        self.logger = logger
        self.packageWriter = packageWriter
        self.podFileWriter = podFileWriter
        self.projTargetVersionWriter = projTargetVersionWriter
        self.frameworkDifferencesProvider = frameworkDifferencesProvider
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
            
            // Updating target version
            logger.logInfo("🚀 Configuring Minimum Deployment Target: \(config.targetOS) \(config.minDeploymentTarget)")
            try [urlProvider.templateProjectURL,
             urlProvider.templateWithDepsProjectURL].forEach {
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
            
            // Generating archives
            logger.logInfo("🚀 Generating Archives for install size analysis...")
            shell.execute(ShellCommand.archiveProject(urlProvider.templateDestinationDirectoryURL,
                                                      isWorkSpace: false,
                                                      linkerArguments: config.linkerArguments))
            shell.execute(ShellCommand.archiveProject(urlProvider.templateWithDepsDestinationDirectoryURL,
                                                      isWorkSpace: !config.pods.isEmpty,
                                                      linkerArguments: config.linkerArguments))
            
            // Generating ipas
            logger.logInfo("🚀 Generating IPAs for download size analysis...")
            shell.execute(ShellCommand.exportIPA(urlProvider.templateDestinationDirectoryURL))
            shell.execute(ShellCommand.exportIPA(urlProvider.templateWithDepsDestinationDirectoryURL))
           
            // Computing Size contribution
            logger.logInfo("🚀 Computing Size contribution...")
            
            let archiveSizeDifference = (try tronFileManager.sizeOfFolder(at: urlProvider.templateWithDepsAppURL)) - (try tronFileManager.sizeOfFolder(at: urlProvider.templateAppURL))
            
            let differences = try frameworkDifferencesProvider.differencesBetween(source: urlProvider.templateFrameworksDirectoryURL, destination: urlProvider.templatWithDepsFrameworksDirectoryURL)
           
            logger.logInfo("The following libswift dylibs are added post linking the dependencies:",
                           subMessages: differences.files.map { $0.debugDescription } )
            logger.logInfoOnNewLine("\tApproximate net contribution of the above libswift dylibs: \(differences.netSizeContribution) bytes ~= \(differences.netSizeContributionFormatted)")

            
            logger.logSuccess("Approximate install size contribution including added dylibs is: \(archiveSizeDifference) bytes = \(tronFileManager.formattedFileSizeRepresentation(forBytes: archiveSizeDifference))")
            let effectiveDiffernece = UInt64(archiveSizeDifference) - differences.netSizeContribution
            logger.logSuccess("Approximate install size contribution without considering libSwift dylibs(iOS 12 and above) is: \(effectiveDiffernece) bytes = \(tronFileManager.formattedFileSizeRepresentation(forBytes: Int64(effectiveDiffernece)))")
            
            let ipaSizeDifference = try tronFileManager.fileSizeDifferenceBetween(url1: urlProvider.templateIPAURL,
                                                                                          url2: urlProvider.templateWithDepsIPAURL)
            
            logger.logSuccess("Approximate download size contribution is: \(ipaSizeDifference.differenceInBytes) bytes = \(ipaSizeDifference.formattedDifference)")
            
            
            logger.logSuccess("All done 🎉")
        } catch let error {
            logger.logError("Error: \(error.localizedDescription)")
        }
        logger.logInfo("ℹ️  The temporary directories are the following:",
                       subMessages: ["Base project:  \(urlProvider.templateDestinationDirectoryURL.path)",
                       "Project/Workspace post adding dependencies:  \(urlProvider.templateWithDepsDestinationDirectoryURL.path)"],
                       footerInfo:
                       "Please have a look to explore the projects, their base setup, impact post adding the dependencies, their respective archives/IPAs etc.")
    }
    
    private let tronFileManager: TronFileManaging
    private let shell: Shell
    private let urlProvider: TronURLProviding
    private let logger: TronLogging
    private let packageWriter: SwiftPackageWriting
    private let podFileWriter: PodFileWriting
    private let projTargetVersionWriter: PBXProjTargetVersionWriting
    private let frameworkDifferencesProvider: FrameworkDifferencesProviding
}



