//
//  File.swift
//  
//
//  Created by Chirag Ramani on 13/02/21.
//

import Foundation

struct Pod: Decodable {
    let name: String
    let version: String
}

protocol PodFileWriting {
    func add(_ pods: [Pod],
             version: String,
             projectURL: URL) throws
}

struct PodFileWriter: PodFileWriting {
    private let platform = "platform :ios, 'version'"
    private let targetStart = "target 'Template' do"
    private let targetEnd = "end"
    private let shell: Shell = Shell()
    
    func add(_ pods: [Pod],
             version: String,
             projectURL: URL) throws {
        guard !pods.isEmpty else { return }
        // 1. Pod init.
        shell.execute(ShellCommand.podinit(projectURL: projectURL.absoluteURL))
        
        // 2. Update the podfile.
        let fileStringContent = podFileContentsFor(pods,
                                                   version: version)
        
        let fileURL = projectURL.appendingPathComponent("Podfile")

        try fileStringContent.write(to: fileURL,
                                    atomically: false,
                                    encoding: .utf8)
        
        // 3. pod install.
        shell.execute(ShellCommand.podInstall(projectURL: projectURL))
    }
    
    private func podFileContentsFor(_ pods: [Pod],
                                    version: String) -> String {
        var podsString = ""
        pods.forEach { (pod) in
            podsString.append("pod '\(pod.name)', '\(pod.version)'\n")
        }
        return [
            platform.replacingOccurrences(of: "version", with: version),
            targetStart,
            podsString,
            targetEnd
        ].joined(separator: "\n")
    }
}
