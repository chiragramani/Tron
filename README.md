
<p align="center">
 <img src="https://github.com/chiragramani/Tron/blob/main/tron.png?raw=true">
</p>

Tron is command-line Swift tool that helps with providing an approximate binary size contribution of a set of swift package(s) and cocoapod(s).

Update config.json that has information about the swift packages as well as cocoapods. 

Then run **swift run Tron tronSampleConfig.json**

## Why measuring contribution of a dependency is important?

Well, we are adding a new member(dependency) to our applcation that is going to help us with a lot of things. Since this also adds to the binary size and giving the fact that binary size is always related to download experience that users go through, its worth exploring its contribution. This analysis helps us in a lot of ways:
1. It gives an approximate idea of the app size increase. If the size increase is surprising, it again opens an opportunity to collaborate and explore if there is a way to either get a thinned version of the dependency or maybe explore other dependency for that matters etc.
2. It helps us to reason how the similar dependencies stand against each other with their respective contributions to binary size. 
3. I really like this [article](https://segment.com/blog/mobile-app-size-effect-on-downloads/) that talks about the "Effect of Mobile App Size on Downloads".  

**Please note:**
1. Currently, the above works only with Xcode 12.
2. Before running the swift command, please open the xcode project in the Sources/Resources/iOS folder. Update the team and signing information. This is a must since a lot of this is dependent on creating an ipa successfully. 
3. Post the above, please update the ExportOptions.plist with your teamID and other fields as per your use-case.


## Requirements

- Xcode 12
- If measuring pods contribution, then cocoapods should be installed.
---
