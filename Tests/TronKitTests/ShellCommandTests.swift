//
//  ShellCommandTests.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation
import XCTest
@testable import TronKit

final class ShellCommandTests: XCTestCase {
    
    func test_exportIPA() {
        // given
        let url = URL(string: "file://some/path")!
        
        // when
        let result = ShellCommand.exportIPA(url)
        
        // then
        XCTAssertEqual(result,
                       "cd /path/ && xcodebuild -exportArchive -archivePath Template.xcarchive -exportPath . Template -exportOptionsPlist ExportOptions.plist")
    }
    
    func test_podinit() {
        // given
        let url = URL(string: "file://some/project/path")!
        
        // when
        let result = ShellCommand.podinit(projectURL: url)
        
        // then
        XCTAssertEqual(result, "cd /project/ && pod init")
    }
    
    func test_podInstall() {
        // given
        let url = URL(string: "file://some/project/path")!
        
        // when
        let result = ShellCommand.podInstall(projectURL: url)
        
        // then
        XCTAssertEqual(result, "cd /project/ && pod install")
    }
    
    func test_archiveProject_notAWorkspace() {
        // given
        let url = URL(string: "file://some/project/path")!
        
        // when
        let result = ShellCommand.archiveProject(url,
                                                 isWorkSpace: false,
                                                 linkerArguments: linkerArguments)
        
        // then
        XCTAssertEqual(result,
                       "cd /project/path/ && xcodebuild -project Template.xcodeproj -scheme Template -configuration Release clean archive -archivePath Template.xcarchive CODE_SIGN_IDENTITY=”codeSignIdentity” CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO CODE_SIGN_ENTITLEMENTS=”codeSignEntitlements” ARCHS=arm64")
    }
    
    func test_archiveProject_workspace() {
        // given
        let url = URL(string: "file://some/project/path")!
        
        // when
        let result = ShellCommand.archiveProject(url,
                                                 isWorkSpace: true,
                                                 linkerArguments: linkerArguments)
        
        // then
        XCTAssertEqual(result,
                       "cd /project/path/ && xcodebuild -workspace Template.xcworkspace -scheme Template -configuration Release clean archive -archivePath Template.xcarchive CODE_SIGN_IDENTITY=”codeSignIdentity” CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO CODE_SIGN_ENTITLEMENTS=”codeSignEntitlements” ARCHS=arm64")
    }
    
    private let linkerArguments = LinkerArguments(codeSignIdentity: "codeSignIdentity",
                                                  isCodeSigningRequired: false,
                                                  isCodeSigningAllowed: false,
                                                  codeSignEntitlements: "codeSignEntitlements",
                                                  architecture: "arm64")
}
