//
//  FrameworkDifferencesProviderTests.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation
import XCTest
@testable import TronKit

final class FrameworkDifferencesProviderTests: XCTestCase {
    
    private var sut: FrameworkDifferencesProvider!
    private let tronFileManager = TronFileManagingMock()
    
    override func setUp() {
        super.setUp()
        sut = FrameworkDifferencesProvider(tronFileManager: tronFileManager)
    }
    
    func test_differences_validSource_validDestination_differentFiles() {
        // given
        let fileA = File(name: "A.dylib",
                         fileSizeInBytes: 20,
                         formattedFileSize: "20 bytes")
        let fileB = File(name: "B.dylib",
                         fileSizeInBytes: 40,
                         formattedFileSize: "40 bytes")
        tronFileManager.formattedFileSizeRepresentationHandler = { _ in
            "40 bytes"
        }
        tronFileManager.filesInDirectoryHandler = { url in
            if url.lastPathComponent == "source" {
                return [fileA]
            } else {
                return [fileA, fileB]
            }
        }
        XCTAssertEqual(tronFileManager.filesInDirectoryCallCount, 0)
        
        // when
        let result = try! sut.differencesBetween(source: URL(fileURLWithPath: "source"),
                                                 destination: URL(fileURLWithPath: "destination"))
        
        // then
        XCTAssertEqual(tronFileManager.filesInDirectoryCallCount, 2)
        XCTAssertEqual(result.files.count, 1)
        XCTAssertEqual(result.netSizeContribution, 40)
        XCTAssertEqual(result.netSizeContributionFormatted, "40 bytes")
    }
    
    func test_differences_validSource_validDestination_sameFiles() {
        // given
        let fileA = File(name: "A.dylib",
                         fileSizeInBytes: 20,
                         formattedFileSize: "20 bytes")
        let fileB = File(name: "B.dylib",
                         fileSizeInBytes: 40,
                         formattedFileSize: "40 bytes")
        tronFileManager.formattedFileSizeRepresentationHandler = { _ in
            "0 bytes"
        }
        tronFileManager.filesInDirectoryHandler = { url in
            [fileA, fileB]
        }
        XCTAssertEqual(tronFileManager.filesInDirectoryCallCount, 0)
        
        // when
        let result = try! sut.differencesBetween(source: URL(fileURLWithPath: "source"),
                                                 destination: URL(fileURLWithPath: "destination"))
        
        // then
        XCTAssertEqual(tronFileManager.filesInDirectoryCallCount, 2)
        XCTAssertEqual(result.files.count, 0)
        XCTAssertEqual(result.netSizeContribution, 0)
        XCTAssertEqual(result.netSizeContributionFormatted, "0 bytes")
    }
    
    func test_differences_invalidSource_validDestination() {
        // given
        let fileA = File(name: "A.dylib",
                         fileSizeInBytes: 20,
                         formattedFileSize: "20 bytes")
        let fileB = File(name: "B.dylib",
                         fileSizeInBytes: 40,
                         formattedFileSize: "40 bytes")
        tronFileManager.filesInDirectoryHandler = { url in
            if url.lastPathComponent == "source" {
                throw FrameworkDifferencesProviderError.directoryNotFound
            } else {
                return [fileA, fileB]
            }
        }
        XCTAssertEqual(tronFileManager.filesInDirectoryCallCount, 0)
        
        // when
        XCTAssertThrowsError(try sut.differencesBetween(source: URL(fileURLWithPath: "source"),
                                                        destination: URL(fileURLWithPath: "destination"))) { (error) in
            // then
            XCTAssertEqual(error as? FrameworkDifferencesProviderError, FrameworkDifferencesProviderError.directoryNotFound)
            XCTAssertEqual(tronFileManager.filesInDirectoryCallCount, 1)
        }
    }
    
    func test_differences_validSource_invalidDestination() {
        // given
        let fileA = File(name: "A.dylib",
                         fileSizeInBytes: 20,
                         formattedFileSize: "20 bytes")
        tronFileManager.filesInDirectoryHandler = { url in
            if url.lastPathComponent == "destination" {
                throw FrameworkDifferencesProviderError.directoryNotFound
            } else {
                return [fileA]
            }
        }
        XCTAssertEqual(tronFileManager.filesInDirectoryCallCount, 0)
        
        // when
        XCTAssertThrowsError(try sut.differencesBetween(source: URL(fileURLWithPath: "source"),
                                                        destination: URL(fileURLWithPath: "destination"))) { (error) in
            // then
            XCTAssertEqual(error as? FrameworkDifferencesProviderError, FrameworkDifferencesProviderError.directoryNotFound)
            XCTAssertEqual(tronFileManager.filesInDirectoryCallCount, 2)
        }
    }
    
    // MARK: Private
    
    private enum FrameworkDifferencesProviderError: Error {
        case directoryNotFound
    }
    
}

