//
//  File.swift
//  
//
//  Created by Chirag Ramani on 22/02/21.
//

import Foundation
@testable import TronKit

final class TronFileManagingMock: TronFileManaging {
    
    var copyFoldersCallCount = 0
    var removeItemCallCount = 0
    var fileSizeDifferenceBetweenCallCount = 0
    var filesInDirectoryCallCount = 0
    var formattedFileSizeRepresentationCallCount = 0
    var sizeOfFolderCallCount = 0
    
    var fileSizeDifferenceBetweenHander: ((URL, URL) throws -> FileSizeDifference)!
    var filesInDirectoryHandler: ((URL) throws -> [File])!
    var formattedFileSizeRepresentationHandler: ((Int64) -> String)!
    var sizeOfFolderHandler: ((URL) throws -> Int64)!
    
    func copyFolders(to destinationURL: URL,
                     from sourceURL: URL) throws {
        copyFoldersCallCount += 1
    }
    
    func removeItem(at: URL) throws {
        removeItemCallCount += 1
    }
    
    func fileSizeDifferenceBetween(url1: URL, url2: URL) throws -> FileSizeDifference {
        fileSizeDifferenceBetweenCallCount += 1
        return try fileSizeDifferenceBetweenHander!(url1, url2)
    }
    
    func files(inDirectory directoryURL: URL) throws -> [File] {
        filesInDirectoryCallCount += 1
        return try filesInDirectoryHandler(directoryURL)
    }
    
    func formattedFileSizeRepresentation(forBytes bytes: Int64) -> String {
        formattedFileSizeRepresentationCallCount += 1
        return formattedFileSizeRepresentationHandler(bytes)
    }
    
    func sizeOfFolder(at url: URL) throws -> Int64 {
        sizeOfFolderCallCount += 1
        return try sizeOfFolderHandler(url)
    }
}
