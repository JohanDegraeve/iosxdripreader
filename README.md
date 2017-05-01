# connects to xDrip and G5



xdrip/xbridge/G5 reader for iOS devices - 

* Initial and subsequent Calibration
* Additional calibration request alerts but not the 12-hour calibration request alert
* View latest calculated value on Home screen with "minutes ago" and diff with previous reading
* Always on notification (not really always but almost always) that allows to see the current value by just lifting up the phone (iOS 10).
* Upload to Nightscout
 * When the app is in the foreground, upload will always happen immediately after receiving a new value, also at app start, 
 * When the app is in the background, then the trigger to upload is a remote notification.
   * The app will subscribe (anonymously) to a service (QuickBlox) as soon as you launch it. As soon as the first bloodglucose reading is received, the app will receive a remote notification the minute after it's supposed to receive a new reading. This remote notification opens the app in the background, and allows it to do an upload to NightScout. The upload may have a delay of maximum 1,5 minute. The trigger is actually being sent by another app on a spare iphone on my desk which is always on. There's no guarantee that this app is always alive. ___There's no guarantee that upload to NightScout is successful.___
* set transmitter id



# To Install the app.

If you need a package for your device, sent my the UDID of your device in a mail please. (johan.degraeve@gmail.com).
To retrieve your UDID you must use iTunes (apps don't give you the right UDID). Here you can find an explanation how to find the UDID http://whatsmyudid.com/ . Follow the instructions "iTunes".
I'll update the latest release version with a release signed for your device.

Then

Installation is done via itunes on a pc or mac, 

* download the IPA file in the Releases
* Open iTunes, select File > Add to Library and add the application IPA file to iTunes (or drag and drop it onto the iTunes dock icon).
* Locate your new application in Apps. (see http://wwwimages.adobe.com/content/dam/Adobe/en/devnet/air/articles/packaging-air-apps-ios/fig_18.jpg)
* Connect your iOS device to your computer's USB port.
* In iTunes, select the attached device and make sure your application is selected to be synced on the device and then sync the device (see http://wwwimages.adobe.com/content/dam/Adobe/en/devnet/air/articles/packaging-air-apps-ios/fig_19.jpg)
* Locate the application on the device and run it. (See http://wwwimages.adobe.com/content/dam/Adobe/en/devnet/air/articles/packaging-air-apps-ios/fig_20.jpg and http://wwwimages.adobe.com/content/dam/Adobe/en/devnet/air/articles/packaging-air-apps-ios/fig_20.jpg)

# To compile (only if you want to develop):
- install Flash Builder 4.7 with FLex SDK 4.15.0, AIR 22.0 en_US
- an ios developer membership is required, full explanation : http://help.adobe.com/en_US/flex/mobileapps/WS064a3073e805330f6c6abf312e7545f65e-8000.html
- clone the repository, lets say folder iosxdripreader
- purchase license for distriqt Notifications, Dialog, Application, Message, NetworkInfo ane at http://airnativeextensions.com/
- create a folder named ane under iosxdripreader
- download the zip package, extract, and copy the file com.distriqt.BluetoothLE.ane to the folder ane
- on the site of airnativeextensions.com, create an application key, application id = net.johandegraeve.iosxdripreader (you can use another application id if you want, but then change the name also in iosxdripreader-app.xml)
- create a folder named src/distriqtkey under iosxdripreader
- create a new class in that package, DistriqtKey.as
- add a public static const distriqtKey:String = your key from distriqt
- as explained here http://airnativeextensions.com/knowledgebase/tutorial/1#ios
- donwload the ios sdk (there should be a zip corresponding to the latest ios version) and put it in a new folder under iosxdripreader
- and add it in the flash builder project properties (also explained on  http://airnativeextensions.com/knowledgebase/tutorial/1#ios)
- (explained : right click in project, properties, flex build path, native extensions, browse to the ane folder and add the new ane, then go to flex build packaging, ios, native extensions, add the file com.distriqt.BluetoothLE.ane as native extensions, check the "package" check box, also add the Apple iOS SDK that was downloaded
- in the same way as above, do this also for the Notifications, Dialog, Application, Message, NetworkInfo, AndroidSupport and core ane.
- it also uses my own ANE : https://github.com/JohanDegraeve/ANE-BackgroundFetch/tree/master/build
