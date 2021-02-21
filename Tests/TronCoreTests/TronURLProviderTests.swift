//
//  File.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation
import XCTest
@testable import TronCore

final class TronURLProviderTests: XCTestCase {
    private var sut: TronURLProvider!
    private let uuidGenerator = UUIDGeneratingMock()
    private let fileManager = TestFileManager()
    
    override func setUp() {
        super.setUp()
        sut = TronURLProvider(fileManager: fileManager,
                              uuidGenerator: uuidGenerator)
    }
    
    func test_templateDestinationDirectoryURL() {
        uuidGenerator.uuid = "uuid1"
        XCTAssertEqual(sut.templateDestinationDirectoryURL,
                       URL(string: "file://T/uuid1/"))
    }
    
    func test_templateWithDepsDestinationDirectoryURL() {
        uuidGenerator.uuid = "uuid2"
        XCTAssertEqual(sut.templateWithDepsDestinationDirectoryURL,
                       URL(string: "file://T/uuid2/"))
    }
    
    func test_templateProjectURL() {
        uuidGenerator.uuid = "uuid1"
        XCTAssertEqual(sut.templateProjectURL,
                       URL(string: "file://T/uuid1/Template.xcodeproj"))
    }
    
    func test_templateWithDepsProjectURL() {
        uuidGenerator.uuid = "uuid2"
        XCTAssertEqual(sut.templateWithDepsProjectURL,
                       URL(string: "file://T/uuid2/Template.xcodeproj"))
    }
    
    func test_templateIPAURL() {
        uuidGenerator.uuid = "uuid1"
        XCTAssertEqual(sut.templateIPAURL,
                       URL(string: "file://T/uuid1/Template.ipa"))
    }
    
    func test_templateWithDepsIPAURL() {
        uuidGenerator.uuid = "uuid2"
        XCTAssertEqual(sut.templateWithDepsIPAURL,
                       URL(string: "file://T/uuid2/Template.ipa"))
    }
    
    func test_templateAppURL() {
        uuidGenerator.uuid = "uuid1"
        XCTAssertEqual(sut.templateAppURL,
                       URL(string: "file://T/uuid1/Template.xcarchive/Products/Applications/Template.app/"))
    }
    
    func test_templateWithDepsAppURL() {
        uuidGenerator.uuid = "uuid2"
        XCTAssertEqual(sut.templateWithDepsAppURL,
                       URL(string: "file://T/uuid2/Template.xcarchive/Products/Applications/Template.app/"))
    }
    
    func test_templateFrameworksDirectoryURL() {
        uuidGenerator.uuid = "uuid1"
        XCTAssertEqual(sut.templateFrameworksDirectoryURL,
                       URL(string: "file://T/uuid1/Template.xcarchive/Products/Applications/Template.app/Frameworks/"))
    }
    
    func test_templatWithDepsFrameworksDirectoryURL() {
        uuidGenerator.uuid = "uuid2"
        XCTAssertEqual(sut.templatWithDepsFrameworksDirectoryURL,
                       URL(string: "file://T/uuid2/Template.xcarchive/Products/Applications/Template.app/Frameworks/"))
    }
}
