# Tron

Tron is library that gives the binary size contribution of a set of swift package(s) and cocoapods.

Update config.json that has information about the swift packages as well as cocoapods. 

Then run **swift run Tron sampleConfig.json**

**Please note:**
1. Currently, the above works only with Xcode 12.
2. Before running the swift command, please open the xcode project in the Sources/Resources/iOS folder. Update the team and signing information. This is a must since a lot of this is dependent on creating an ipa successfully. 
3. Post the above, please update the ExportOptions.plist with your teamID and other fields as per your use-case.
4. Cocoapods support is WIP.


