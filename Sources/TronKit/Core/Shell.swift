//
//  Shell.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation

protocol Shell {
    func execute(_ command: String)
}

struct ShellImpl: Shell {
    static var isVerbose = false
    
    init(logger: TronLogging = TronLogger()) {
        self.logger = logger
    }
    
    func execute(_ command: String) {
        Process().launchBash(withCommand: command,
                             logger: logger,
                             isVerbose: ShellImpl.isVerbose)
    }
    
    // MARK: Private
    
    private let logger: TronLogging
}

struct ShellCommand {
    
    static func archiveProject(_ projectURL: URL,
                               isWorkSpace: Bool,
                               linkerArguments: LinkerArguments) -> String {
        let baseCommand = isWorkSpace ? archiveWorkspaceCommand : archiveCommand
        let archiveOverrideCommand = baseCommand
            .replacingOccurrences(of: ShellCommand.linkerArguments,
                                  with: linkerArguments.xcodeLinkerArguments)
        return "cd \(projectURL.path)/ && \(archiveOverrideCommand)"
    }
    
    static func exportIPA(_ projectURL: URL) -> String {
        "cd \(projectURL.path)/ && \(exportIPACommand)"
    }
    
    static func podinit(projectURL: URL) -> String {
        "cd \(projectURL.deletingLastPathComponent().path)/ && \(podInit)"
    }
    
    static func podInstall(projectURL: URL) -> String {
        "cd \(projectURL.deletingLastPathComponent().path)/ && \(podInstall)"
    }
    
    // MARK: Private
    
    private static let linkerArguments = "{linkerArguments}"
    
    private static let archiveCommand = "xcodebuild -project Template.xcodeproj -scheme Template -configuration Release clean archive -archivePath Template.xcarchive \(linkerArguments)"
    
    private static let archiveWorkspaceCommand = "xcodebuild -workspace Template.xcworkspace -scheme Template -configuration Release clean archive -archivePath Template.xcarchive \(linkerArguments)"
    
    private static let exportIPACommand = "xcodebuild -exportArchive -archivePath Template.xcarchive -exportPath . Template -exportOptionsPlist ExportOptions.plist"
    
    private static let podInit = "pod init"
    private static let podInstall = "pod install"
}

private extension LinkerArguments {
    var xcodeLinkerArguments: String {
        let codeSignIdentityArgument = "CODE_SIGN_IDENTITY=”\(codeSignIdentity)”"
        let codeSigningRequiredArgument = "CODE_SIGNING_REQUIRED=\(isCodeSigningRequired ? "YES": "NO")"
        let codeSigningAllowedArgument = "CODE_SIGNING_ALLOWED=\(isCodeSigningAllowed ? "YES": "NO")"
        let codeSignEntitlementsArgument = "CODE_SIGN_ENTITLEMENTS=”\(codeSignEntitlements)”"
        let architecturesArgument = "ARCHS=\(architecture)"
        return [codeSignIdentityArgument,
                codeSigningRequiredArgument,
                codeSigningAllowedArgument,
                codeSignEntitlementsArgument,
                architecturesArgument].joined(separator: " ")
    }
}
