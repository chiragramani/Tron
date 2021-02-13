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
             minDeploymentTarget: String,
             projectURL: URL,
             targetOS: TargetOS) throws
}

struct PodFileWriter: PodFileWriting {
    private let platform = "platform :platformOS, 'version'"
    private let targetStart = "target 'Template' do"
    private let targetEnd = "end"
    private let shell: Shell = Shell()
    
    func add(_ pods: [Pod],
             minDeploymentTarget: String,
             projectURL: URL,
             targetOS: TargetOS) throws {
        guard !pods.isEmpty else { return }
        // 1. Pod init.
        shell.execute(ShellCommand.podinit(projectURL: projectURL.absoluteURL))
        
        // 2. Update the podfile.
        let fileStringContent = podFileContentsFor(pods,
                                                   minDeploymentTarget: minDeploymentTarget,
                                                   targetOS: targetOS)
        
        let fileURL = URL(fileURLWithPath: projectURL
                            .deletingLastPathComponent().path)
            .appendingPathComponent("Podfile")
        
        try fileStringContent.write(to: fileURL,
                                    atomically: false,
                                    encoding: .utf8)
        
        // 3. pod install.
        shell.execute(ShellCommand.podInstall(projectURL: projectURL))
    }
    
    private func podFileContentsFor(_ pods: [Pod],
                                    minDeploymentTarget: String,
                                    targetOS: TargetOS) -> String {
        var podsString = ""
        pods.forEach { (pod) in
            podsString.append("pod '\(pod.name)', '\(pod.version)'\n")
        }
        let platformOverride = platform
            .replacingOccurrences(of: "version", with: minDeploymentTarget)
            .replacingOccurrences(of: "platformOS", with: targetOS.podPlatformValue)
        return [
            platformOverride,
            targetStart,
            podsString,
            targetEnd
        ].joined(separator: "\n")
    }
}

private extension TargetOS {
    var podPlatformValue: String {
        switch self {
        case .iOS:
            return "ios"
        }
    }
}
