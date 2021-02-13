//
//  Shell.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation

struct Shell {
    
    init(logger: TronLogging = TronLogger()) {
        self.logger = logger
    }
    
    func execute(_ command: String) {
        Process().launchBash(withCommand: command,
                             logger: logger)
    }
    
    // MARK: Private
    private let logger: TronLogging
}

struct ShellCommand {
    
    private static let archiveCommand = "xcodebuild -project Template.xcodeproj -scheme Template -configuration Release clean archive -archivePath Template.xcarchive CODE_SIGN_IDENTITY=”” CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO CODE_SIGN_ENTITLEMENTS=”” ARCHS=arm64 iOSVersion=11.0"
    
    private static let archiveWorkspaceCommand = "xcodebuild -workspace Template.xcworkspace -scheme Template -configuration Release clean archive -archivePath Template.xcarchive CODE_SIGN_IDENTITY=”” CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO CODE_SIGN_ENTITLEMENTS=”” ARCHS=arm64 iOSVersion=11.0"
    
    private static let exportIPACommand = "xcodebuild -exportArchive -archivePath Template.xcarchive -exportPath . Template -exportOptionsPlist ExportOptions.plist"
    
    private static let podInit = "/usr/local/bin/pod init"
    private static let podInstall = "/usr/local/bin/pod install"
    
    static func archiveProject(_ projectURL: URL, isWorkSpace: Bool) -> String {
        if isWorkSpace {
            return "cd \(projectURL.path)/ && \(archiveWorkspaceCommand)"
        } else {
            return "cd \(projectURL.path)/ && \(archiveCommand)"
        }
    }
    
    static func exportIPA(_ projectURL: URL) -> String {
        "cd \(projectURL.path)/ && \(exportIPACommand)"
    }
    
    static func podinit(projectURL: URL) -> String {
        "cd \(projectURL.path)/ && \(podInit)"
    }
    
    static func podInstall(projectURL: URL) -> String {
        "cd \(projectURL.path)/ && \(podInstall)"
    }
}

