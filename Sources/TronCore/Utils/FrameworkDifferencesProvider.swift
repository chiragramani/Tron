//
//  FrameworkDifferencesProvider.swift
//  
//
//  Created by Chirag Ramani on 21/02/21.
//

import Foundation

protocol FrameworkDifferencesProviding {
    func differencesBetween(source: URL,
                            destination: URL) throws -> FrameworkDifferences
}

struct FrameworkDifferences {
    let files: [File]
    let netSizeContribution: UInt64
    let netSizeContributionFormatted: String
}

struct FrameworkDifferencesProvider: FrameworkDifferencesProviding {
    
    init(tronFileManager: TronFileManaging = TronFileManager()) {
        self.tronFileManager = tronFileManager
    }
    
    func differencesBetween(source: URL, destination: URL) throws -> FrameworkDifferences {
        let filesInSource = try tronFileManager.files(inDirectory: source)
        let filesInDestination = try tronFileManager.files(inDirectory: destination)
        let difference = filesInSource.difference(from: filesInDestination)
        let netSizeContribution = difference.reduce(0, { $0 + $1.fileSizeInBytes })
        return FrameworkDifferences(files: difference,
                                    netSizeContribution: UInt64(netSizeContribution),
                                    netSizeContributionFormatted: tronFileManager.formattedFileSizeRepresentation(forBytes: netSizeContribution))
    }
    
    // MARK: Private
    
    private let tronFileManager: TronFileManaging
}

extension Array where Element: Hashable {
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}
