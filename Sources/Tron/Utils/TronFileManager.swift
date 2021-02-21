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
    
    func fileSizeDifferenceBetween(url1: URL,
                                   url2: URL) throws -> FileSizeDifference
    
    func files(inDirectory directoryURL: URL) throws -> [File]
}

enum TronFileManagerError: Error {
    case couldNotCopyFolder(sourceURL: URL,
                            destinationURL: URL,
                            systemError: Error)
    case couldNotComputeFileSizeDifference(url1: URL, url2: URL,
                                           systemError: Error)
    case couldNotRemoveFile(url: URL,
                            systemError: Error)
}

struct File {
    let name: String
    let fileSizeInBytes: Int64
    let formattedFileSize: String
}

struct FileSizeDifference {
    let url1: URL
    let url2: URL
    let differenceInBytes: UInt64
    let formattedDifference: String
}

struct TronFileManager: TronFileManaging {
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func copyFolders(to destinationURL: URL,
                     from sourceURL: URL) throws {
        do {
            try copyFiles(pathFromBundle: sourceURL.path,
                          pathDestDocs: destinationURL.path)
        } catch let error {
            throw TronFileManagerError.couldNotCopyFolder(sourceURL: sourceURL,
                                                          destinationURL: destinationURL,
                                                          systemError: error)
        }
        
    }
    
    func fileSizeDifferenceBetween(url1: URL, url2: URL) throws -> FileSizeDifference {
        do {
            let url1Size = try sizeOfFileURL(url1)
            let url2Size = try sizeOfFileURL(url2)
            let difference = url1Size > url2Size ? url1Size - url2Size : url2Size - url1Size
            return .init(url1: url1,
                         url2: url2,
                         differenceInBytes: difference,
                         formattedDifference: byteCountFormatter.string(fromByteCount: Int64(difference)))
        }
        catch let error {
            throw TronFileManagerError.couldNotComputeFileSizeDifference(url1: url1,
                                                                         url2: url2,
                                                                         systemError: error)
        }
    }
    
    func removeItem(at url: URL) throws {
        do {
            try fileManager.removeItem(at: url)
        } catch let error {
            throw TronFileManagerError.couldNotRemoveFile(url: url,
                                                          systemError: error)
        }
    }
    
    func files(inDirectory directoryURL: URL) throws -> [File]  {
        let urls = try FileManager.default.contentsOfDirectory(at: directoryURL,
                                                               includingPropertiesForKeys: [.fileSizeKey])
        return try urls.map { url in
            let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as! Int64
            return File(name: url.lastPathComponent,
                        fileSizeInBytes: fileSize,
                        formattedFileSize: byteCountFormatter.string(fromByteCount: fileSize))
        }
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
    
    private let byteCountFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = .useAll
        return formatter
    }()
}


extension TronFileManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .couldNotComputeFileSizeDifference(url1, url2, systemError):
            return "Could Not Compute File Size Difference for files at urls: \n 1.\(url1),\n 2. \(url2).\nInternal error description: \(systemError.localizedDescription)"
        case let .couldNotCopyFolder(sourceURL, destinationURL, systemError):
            return "Could Not Copy Folders from\n 1.sourceURL: \(sourceURL),\n 2.Destination URL - \(destinationURL).\nInternal error description: \(systemError.localizedDescription)"
        case let .couldNotRemoveFile(url, systemError):
            return "Could Not Remove File\n 1.url: \(url)\n \nInternal error description: \(systemError.localizedDescription)"
        }
    }
    
}
