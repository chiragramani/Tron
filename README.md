
<p align="center">
 <img src="https://github.com/chiragramani/Tron/blob/main/tron.png?raw=true">
</p>

Tron is command-line Swift tool that helps with providing an approximate binary size contribution of a set of swift package(s) and cocoapod(s).

Update config.json that has information about the swift packages as well as cocoapods. 

Then run **swift run Tron tronSampleConfig.json**

## Why measuring contribution of a dependency is important?

Well, we are adding a new member(dependency) to our application that is going to help us with a lot of things. Since this also adds to the binary size and giving the fact that binary size is always related to download experience that users go through, its worth exploring its contribution. This analysis helps us in a lot of ways:
1. It gives an approximate idea of the app size increase. If the size increase is surprising, it again opens an opportunity to collaborate and explore if there is a way to either get a thinned version of the dependency or maybe explore other dependency for that matters etc.
2. It helps us to reason how the similar dependencies stand against each other with their respective contributions to binary size. 
3. Peter Reinhardt has authored an amazing [article](https://segment.com/blog/mobile-app-size-effect-on-downloads/) that talks about the "Effect of Mobile App Size on Downloads". Please refer to the article for more details about impact on installation rate etc. (Highly recommended).


## System Requirements

* Swift 5.3 or later
* Xcode 12.0 or later
* If measuring pods contribution, then cocoapods should be installed.

**Please note:**
* Before running the swift command, please open the xcode project in the Sources/Resources/iOS folder. Update the team and signing information. This is a must since a lot of this is dependent on creating an ipa successfully. 
* Post the above, please update the ExportOptions.plist with your teamID and other fields as per your use-case.

## Libraries used
[tuist/XcodeProj](https://github.com/tuist/XcodeProj) | [swift-argument-parser](https://github.com/apple/swift-argument-parser)

## Recommendations
* If you are interested in knowing the impact of every change as you make it, or if you are intrested in getting an accurate app size report on every diff or every release build, with a very  detailed module by module Binary analysis breakdown, [Emerge](https://www.emergetools.com) is worth exploring.

## Report any issues

If you run into any problems, please file a git issue. Please include:

* The OS version (e.g. macOS 10.15.6)
* The Swift version installed on your machine (from `swift --version`)
* The Xcode version
* The specific release version of this source code (you can use `git tag` to get a list of all the release versions or `git log` to get a specific commit sha)
* Any local changes on your machine
* Verbose logs printed in the console when the operations were executed

---
