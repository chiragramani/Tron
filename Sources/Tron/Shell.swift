//
//  Shell.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation

struct Shell {
    func execute(_ command: String, logger: TronLogging) {
        Process().launchBash(withCommand: command, logger: logger)
    }
}

struct ShellCommand {
    
    private static let archiveCommand = "xcodebuild -project Template.xcodeproj -scheme Template -configuration Release clean archive -archivePath Template.xcarchive CODE_SIGN_IDENTITY=”” CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO CODE_SIGN_ENTITLEMENTS=”” ARCHS=arm64 iOSVersion=11.0"
    
    private static let exportIPACommand = "xcodebuild -exportArchive -archivePath Template.xcarchive -exportPath . Template -exportOptionsPlist ExportOptions.plist"
    
    static func archiveProject(_ projectURL: URL) -> String {
        "cd \(projectURL.path)/ && \(archiveCommand)"
    }
    
    static func exportIPA(_ projectURL: URL) -> String {
        "cd \(projectURL.path)/ && \(exportIPACommand)"
    }
}

