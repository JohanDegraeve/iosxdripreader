# iosxdripreader

Project in development phase 

xdrip/xbridge reader for iOS devices


To compile :
- install Flash Builder 4.7 with FLex SDK 4.15.0, AIR 22.0 beta en_US
- an ios developer membership is required, full explanation : http://help.adobe.com/en_US/flex/mobileapps/WS064a3073e805330f6c6abf312e7545f65e-8000.html
- clone the repository, lets say folder iosxdripreader
- purchase license for distriqt bluetooth le ane at http://airnativeextensions.com/
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
- in the same way as above, do this also for the Notifications, Dialog, core ane, this ane requires in addition the core ane which is available on github, it's all on the site of distriqt.
