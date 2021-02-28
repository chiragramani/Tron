
<p align="center">
 <img src="https://github.com/chiragramani/Tron/blob/main/tron.png?raw=true">
</p>

Tron is a simple command-line Swift tool that provides an approximate download and installation size contribution of a set of Swift package(s) and Cocoapod(s).

## Why measuring contribution of a dependency is important?

Well, we are adding a new member(dependency) to our application that is going to help us with a lot of things. Since this also adds to the binary size and given the fact that binary size is always related to the [download/install experience](https://github.com/chiragramani/Tron/blob/main/Download-Install-Size.md) that users go through, it's worth exploring its contribution. This analysis helps us in a lot of ways:
1. It gives an approximate idea of the app size increase. If the size increase is surprising, it again opens an opportunity to collaborate and explore if there is a way to either get a thinned version of the dependency or maybe explore other dependencies for that matter, etc.
2. It helps us to reason how similar dependencies stand against each other with their respective contributions to binary size.
3. Peter Reinhardt has authored an amazing article that talks about the "Effect of Mobile App Size on Downloads". Please refer to the [article](https://www.google.com/search?client=safari&rls=en&q=Effect+of+Mobile+App+Size+on+Downloads&ie=UTF-8&oe=UTF-8) for more details about the impact on installation rate etc.

## Installation

```
$ git clone https://github.com/chiragramani/Tron
$ cd Tron
$ swift build -c release
$ cd .build/release
$ swift run Tron <path_to_tron_config_json_file> // follow the steps mentioned under "Run" below.
```

## Run

1. Update tronSampleConfig.json that has information about the swift packages as well as the pods.
2. Then run ```**swift run Tron <path_to_tron_config_json_file>```

<img width="1529" alt="Screenshot 2021-03-01 at 3 59 56 AM" src="https://user-images.githubusercontent.com/11925399/109435880-b51dee80-7a42-11eb-8cea-b9ce2d1f63de.png">


## System Requirements

* Swift 5.3 or later
* Xcode 12.0 or later
* If measuring pods contribution, then cocoapods should be installed.

* If measuring impact on the download size,
    * Before running the swift command, please open the xcode project in the Sources/Resources/iOS folder. Update the team and signing information. This is a must since a lot of this is dependent on creating an ipa successfully.
    * Post the above, please update the ExportOptions.plist with your teamID and other fields as per your use-case.

## FAQs

### Why do we have to mention minimum deployment target version in the config file ? (ABI Stability)
Swift became ABI stable with the release of Swift 5.0🎉. So if the deployment target is macOS 10.14.4, iOS 12.2, tvOS 12.2, watchOS 5.2 and above - then applications no longer need to be distributed with the Swift runtime libraries hence reducing download size. But if you want to support earlier versions, then Swift runtime would be bundled with your app binary. For earlier versions, it becomes important to understand the libswift dynamic libraries that would be introduced and their respective contribution(s) when exploring a particular dependency. For more info on ABI Stability, please refer to this great swift.org post - [ABI Stability and More](https://swift.org/blog/abi-stability-and-more/).

For example:
* When adding Swift Package Kingfisher@6.0.0 for minimum deployment target iOS 11.3 - the following libswift dylibs are added: 
![Screenshot 2021-03-01 at 3 08 46 AM](https://user-images.githubusercontent.com/11925399/109434838-1fcc2b80-7a3d-11eb-93ca-898a41dfac78.jpg)
As we can see, 9 libswift dynamic libraries are introduced but none of them are added when the deployment target is iOS 12.2 or above. 

Please note: your application might be adding either all or a few of the above dylibs already even before the dependency is being added, so please consider the existing state. E.g. if you are importing CoreLocation already in your application- then libswiftCoreLocation.dylib will not be a new addition, and hence its contribution of ~=730 KB can be respectively reduced.

## Methodology

The methodology is highly inspired by [Google Cocoapods-size](https://github.com/google/cocoapods-size)and does the following:
1. Archive a baseline app as ARM64 with no bitcode.
2. Add the required dependencies.
3. Archive a baseline app as ARM64 with no bitcode.
4. Compute the difference and report the respective contribution.
The size reported by Testflight is very much close (within a range of 3%) to the result calculated by following the above approach.

## Libraries used
[tuist/XcodeProj](https://github.com/tuist/XcodeProj) | [swift-argument-parser](https://github.com/apple/swift-argument-parser)

## Recommendations
* [How Uber Deals with Large iOS App Size](https://eng.uber.com/how-uber-deals-with-large-ios-app-size/) The App Size Problem faced by Uber and the amazing engineering journey that resulted in some really cool code size savings.
* If you are interested in knowing the impact of every change as you make it, or if you are intrested in getting an accurate app size report on every diff or every release build, with a very  detailed module by module Binary analysis breakdown, [Emerge](https://www.emergetools.com) is worth exploring. [How 7 iOS Apps Could Save You 500MB of Storage](https://medium.com/swlh/how-7-ios-apps-could-save-you-500mb-of-storage-a828782c973e)

## Report any issues

If you run into any problems, please file a git issue. Please include:

* The OS version (e.g. macOS 10.15.6)
* The Swift version installed on your machine (from `swift --version`)
* The Xcode version
* The specific release version of this source code (you can use `git tag` to get a list of all the release versions or `git log` to get a specific commit sha)
* Any local changes on your machine
* Verbose logs printed in the console when the operations were executed

## License
Tron is licensed under MIT. See [LICENSE](https://github.com/chiragramani/Tron/blob/main/LICENSE) for more information.
```
MIT License

Copyright (c) 2021 Chirag Ramani

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
---
