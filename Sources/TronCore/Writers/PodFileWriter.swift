//
//  File.swift
//  
//
//  Created by Chirag Ramani on 13/02/21.
//

import Foundation

struct Pod: Decodable, CustomDebugStringConvertible {
    let name: String
    let version: String
    
    // MARK: CustomDebugStringConvertible
    
    var debugDescription: String {
        "\(name) - \(version)"
    }
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
    private let shell: Shell
    private let logger: TronLogging
    
    init(shell: Shell = ShellImpl(),
         logger: TronLogging = TronLogger()) {
        self.shell = shell
        self.logger = logger
    }
    
    func add(_ pods: [Pod],
             minDeploymentTarget: String,
             projectURL: URL,
             targetOS: TargetOS) throws {
        guard !pods.isEmpty else { return }
        logger.logInfo("🚀 Adding Pods: \(pods) ...")
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
