//
//  TronFileManager.swift
//
//
//  Created by Chirag Ramani on 08/02/21.
//

import Foundation

protocol TronFileManaging {
    func copyFolders(to destinationURL: URL,
                     from sourceURL: URL) throws
    
    func removeItem(at: URL) throws
    
    func fileSizeDifferenceBetween(url1: URL, url2: URL) throws -> UInt64
}

struct TronFileManager: TronFileManaging {
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func copyFolders(to destinationURL: URL,
                     from sourceURL: URL) throws {
        try copyFiles(pathFromBundle: sourceURL.path,
                  pathDestDocs: destinationURL.path)
    }
    
    func fileSizeDifferenceBetween(url1: URL, url2: URL) throws -> UInt64 {
        let url1Size = try sizeOfFileURL(url1)
        let url2Size = try sizeOfFileURL(url2)
        return url1Size > url2Size ? url1Size - url2Size : url2Size - url1Size
    }
    
    func removeItem(at url: URL) throws {
       try fileManager.removeItem(at: url)
    }
    
    // MARK: Private
    
    private let fileManager: FileManager

    private func copyFiles(pathFromBundle : String, pathDestDocs: String) throws {
        let fileManagerIs = FileManager.default
        do {
            try fileManagerIs.copyItem(atPath: pathFromBundle,
                                       toPath: pathDestDocs)
        }
    }
    
    private func sizeOfFileURL(_ url: URL) throws -> UInt64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = attributes[FileAttributeKey.size] as! UInt64
        return fileSize
    }
}
