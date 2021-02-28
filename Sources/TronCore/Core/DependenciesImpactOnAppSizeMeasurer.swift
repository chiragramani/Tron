//
//  DependenciesImpactOnAppSizeMeasurer.swift
//  
//
//  Created by Chirag Ramani on 21/02/21.
//

import Foundation

protocol DependenciesImpactOnAppSizeMeasuring {
    func determineDepedenciesImpactOnAppSize(givenConfig config: TronConfig) throws
}

struct DependenciesImpactOnAppSizeMeasurer: DependenciesImpactOnAppSizeMeasuring {
    
    init(tronFileManager: TronFileManaging = TronFileManager(),
         shell: Shell = ShellImpl(),
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
    
    func determineDepedenciesImpactOnAppSize(givenConfig config: TronConfig) throws {
        try setupTemplatesForSizeAnalysis(config)
        defer { logGeneratedProjectsInfo() }
        try addDependencies(config)
        try generateProducts(config)
        analyseGeneratedProducts(config)
    }
    
    // MARK: Private
    
    private let tronFileManager: TronFileManaging
    private let shell: Shell
    private let urlProvider: TronURLProviding
    private let logger: TronLogging
    private let packageWriter: SwiftPackageWriting
    private let podFileWriter: PodFileWriting
    private let projTargetVersionWriter: PBXProjTargetVersionWriting
    private let frameworkDifferencesProvider: FrameworkDifferencesProviding
    
    private func setupTemplatesForSizeAnalysis(_ config: TronConfig) throws {
        logger.logInfo("🚀 Copying template to temp directories for analysis...")
        
        // Copy it in two different directories - one for default and the other for adding dependencies.
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
    }
    
    private func addDependencies(_ config: TronConfig) throws {
        try packageWriter.add(packages: config.packages,
                               to: urlProvider.templateWithDepsProjectURL)
        
        try podFileWriter.add(config.pods,
                               minDeploymentTarget: config.minDeploymentTarget,
                               projectURL: urlProvider.templateWithDepsProjectURL,
                               targetOS: config.targetOS)
    }
    
    private func generateProducts(_ config: TronConfig) throws {
        // Generating archives
        logger.logInfo("🚀 Generating Archives for install size analysis...")
        shell.execute(ShellCommand.archiveProject(urlProvider.templateDestinationDirectoryURL,
                                                  isWorkSpace: false,
                                                  linkerArguments: config.linkerArguments))
        shell.execute(ShellCommand.archiveProject(urlProvider.templateWithDepsDestinationDirectoryURL,
                                                  isWorkSpace: !config.pods.isEmpty,
                                                  linkerArguments: config.linkerArguments))
        
        // Generating ipas
        if config.shouldPerformDownloadSizeAnalysis {
            logger.logInfo("🚀 Generating IPAs for download size analysis...")
            shell.execute(ShellCommand.exportIPA(urlProvider.templateDestinationDirectoryURL))
            shell.execute(ShellCommand.exportIPA(urlProvider.templateWithDepsDestinationDirectoryURL))
        }
    }
    
    private func frameworkDifferences(_ config: TronConfig) throws -> FrameworkDifferences? {
        guard let majorVersion = config.majorVersion, majorVersion < 12 else { return nil }
        let differences = try frameworkDifferencesProvider.differencesBetween(source: urlProvider.templateFrameworksDirectoryURL, destination: urlProvider.templatWithDepsFrameworksDirectoryURL)
       
        logger.logInfo("The following libswift dylibs are added post linking the dependencies:",
                       subMessages: differences.files.map { $0.debugDescription } )
        logger.logInfoOnNewLine("\tApproximate net contribution of the above libswift dylibs: \(differences.netSizeContribution) bytes ~= \(differences.netSizeContributionFormatted)")
        return differences
    }
    
    private func analyseGeneratedProducts(_ config: TronConfig) {
        performInstallSizeAnalysis(config)
        if config.shouldPerformDownloadSizeAnalysis {
            performDownloadSizeAnalysis()
        }
    }
    
    private func logGeneratedProjectsInfo() {
        logger.logInfoOnNewLine("ℹ️  The temporary directories are the following:",
                       subMessages: ["Base project:  \(urlProvider.templateDestinationDirectoryURL.path)",
                       "Project/Workspace post adding dependencies:  \(urlProvider.templateWithDepsDestinationDirectoryURL.path)"],
                       footerInfo:
                       "If interested, please explore the above projects to know more about their base setup, impact post adding the dependencies, their respective products - archives/IPAs etc.")
    }
    
    private func performDownloadSizeAnalysis() {
        do {
            logger.logInfoOnNewLine("🚀 Performing Download Size analysis...")
            let ipaSizeDifference = try tronFileManager.fileSizeDifferenceBetween(url1: urlProvider.templateIPAURL,
                                                                                          url2: urlProvider.templateWithDepsIPAURL)
            
            logger.logSuccess("Approximate download size contribution is: \(ipaSizeDifference.differenceInBytes) bytes ~= \(ipaSizeDifference.formattedDifference)")
        } catch let error {
            logger.logError(error.localizedDescription)
        }
    }
    
    private func performInstallSizeAnalysis(_ config: TronConfig) {
        do {
            logger.logInfoOnNewLine("🚀 Performing Install Size analysis...")
            
            let archiveSizeDifference = (try tronFileManager.sizeOfFolder(at: urlProvider.templateWithDepsAppURL)) - (try tronFileManager.sizeOfFolder(at: urlProvider.templateAppURL))
            
            if let frameworkDifferences = try frameworkDifferences(config) {
                logger.logSuccess("Approximate install size contribution including added dylibs is: \(archiveSizeDifference) bytes ~= \(tronFileManager.formattedFileSizeRepresentation(forBytes: archiveSizeDifference))")
                let effectiveDifference = UInt64(archiveSizeDifference) - frameworkDifferences.netSizeContribution
                logger.logSuccess("Approximate install size contribution without considering libSwift dylibs(iOS 12 and above) is: \(effectiveDifference) bytes ~= \(tronFileManager.formattedFileSizeRepresentation(forBytes: Int64(effectiveDifference)))")
            } else {
                logger.logSuccess("Approximate install size contribution is: \(archiveSizeDifference) bytes ~= \(tronFileManager.formattedFileSizeRepresentation(forBytes: archiveSizeDifference))")
            }
        } catch let error {
            logger.logError(error.localizedDescription)
        }
    }
}

private extension TronConfig {
    var majorVersion: Double? {
        minDeploymentTarget.components(separatedBy: ".").first.map { Double($0) } ?? nil
    }
}
