# iosxdripreader

Project in development phase 

xdrip/xbridge reader for iOS devices


To compile :
- install Flash Builder 4.7 with FLex SDK 4.15.0, AIR 22.0 beta en_US
- clone the repository, callit in folder iosxdripreader
- purchase license for distriqute bluetooth le ane at http://airnativeextensions.com/
- create a folder named ane under iosxdripreader
- downloade the zip package, extract, and copy the file com.distriqt.BluetoothLE.ane to the folder ane
- on the site of airnativeextensions.com, create an application key, application id = net.johandegraeve.iosxdripreader (you can use another application id if you want, but then change the name also in iosxdripreader-app.xml)
- create a folder named src/locale/en_US under iosxdripreader
- create a file in that folder named distriqt-applicationkey.properties
- edit distriqt-applicationkey.properties and add one line with "key=the-application-key-from-airnativeextensions.com"
- as explained here http://airnativeextensions.com/knowledgebase/tutorial/1#ios
- donwload the ios sdk (not sure yet which version to download)
- and add it in the flash builder project properties (also explained on  http://airnativeextensions.com/knowledgebase/tutorial/1#ios)
-   
