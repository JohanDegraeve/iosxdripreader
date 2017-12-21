[33mcommit 7712e2afc1d23764ef274ce835d8b6cb71e53f03[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 20 18:38:55 2017 +0100

    check if G5 gives filtered data = 2096896 then give warning to user that battery is dead, and don't create new reading

[33mcommit 52f709d0c99aa065fbd7fdc392ef994db2bb3d4d[m
Merge: 79de64d ab78086
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 20 18:06:36 2017 +0100

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 79de64d660434d788b12a579629b83623b8ae1e9[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 20 09:45:57 2017 +0100

    added alert type and other useful info in trace file

[33mcommit 7a7d582cce4dc4f29a8424c1bb8140b3de745edd[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 20 09:19:10 2017 +0100

    blucon : if sensorstatus = expired, can not be used anymore - aligned with xdripplus commit 1ec8aae25efc266e0aade338c822a6578c6008af

[33mcommit ab78086cf7ac14da75a05627cdf7cc7ed5a2e1c3[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 18 10:24:58 2017 +0100

    Update README.md

[33mcommit dcdb61878f505b67f9b5105618821ab3acb21c4c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 18 10:18:49 2017 +0100

    Update README.md

[33mcommit d86da392a1b0e2c804c6a9a00be448cf9a2a3de7[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 18 10:18:14 2017 +0100

    Update README.md

[33mcommit f1d779c1ddc6f907c3621d232fb48ab2434524c2[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 18 10:16:59 2017 +0100

    Update README.md

[33mcommit fdca50bf42701e14f6f7a6305cce72c8cecba5f9[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 18 09:14:01 2017 +0100

    version increase 1.1.31

[33mcommit 43f892571f1ef06f32f80fa995232167a93f6107[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 17 21:40:32 2017 +0100

    polish for texttospeech low and high

[33mcommit bfd0d3ebd3b4d2768119a2b6180ee41e5dde9537[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 17 16:42:58 2017 +0100

    Text to speech : high and low also translated - this includes Italian, French, Dutch and Polish

[33mcommit 081f1082ff33431340024cf8ddba9fc0191d9d65[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 16 14:10:51 2017 +0100

    improved explanation on transmitter id for blukon

[33mcommit b62bc7ddb145b86df18bee0193688b2b1e310506[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 16 00:25:47 2017 +0100

    store 90 days of bgreadings in database, and in modellocator read only readings of last day

[33mcommit 6ed6e1bc9c70380604db231022ae8e4deb028e23[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 15 23:36:26 2017 +0100

    text to speech in Italian

[33mcommit 02177f9abd7509ece09535692bbac8dc8774d3b4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 15 22:58:46 2017 +0100

    reduce max days of bg readings stored from 5 to 1 day - improves start up speed

[33mcommit f7bf8501b87110ab81a474ac3a92909f5491a1c9[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 15 00:05:26 2017 +0100

    version increase 1.1.30

[33mcommit 986bca23255996af30cf007606d5eea929a95ca4[m
Merge: e2f04b9 bd7696b
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 15 00:03:19 2017 +0100

    Merge branch 'bluconcombinescanandreconnect'

[33mcommit e2f04b9c4816504d4d615d9720b93073c47f65b1[m
Merge: 09037d5 baa3bbf
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 15 00:03:09 2017 +0100

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit bd7696b8e6e5f58854b1b5b75cf0f818e03e54cd[m
Merge: f6a7c63 4576bd7
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Dec 14 23:52:03 2017 +0100

    Merge branch 'bluconcombinescanandreconnect' of https://github.com/JohanDegraeve/iosxdripreader into bluconcombinescanandreconnect

[33mcommit f6a7c633fb469018ff4f057a49412314b2ece29c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Dec 14 00:20:42 2017 +0100

    additional fix bluetooth reconnect blucon

[33mcommit eef47b3cfbdd1135896796b64941da2de3019456[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 10 15:56:40 2017 +0100

    if blukon, ignore awaitingConnect and waitingForPeripheralCharacteristicsDiscovered

[33mcommit 27404c81cfa89167930dccc468847b59fb6c675e[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 3 20:12:16 2017 +0100

    startrescan after disconnect

[33mcommit 6b7944a3c4e2d5ab88329f463d356627b1f572a5[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 6 23:23:36 2017 +0100

    additional fix

[33mcommit ce55580f9fe9692131e8b52f32ef58db329fdaf0[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 4 21:33:10 2017 +0100

    correction in start rescan for blukon

[33mcommit fc0725a8e2b77e1a8ad6e9edee5db2bd5ea5a46e[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 3 20:12:16 2017 +0100

    startrescan after disconnect

[33mcommit baa3bbff972d0ed8c8389cb4f51c0181aa940a27[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Dec 12 09:44:37 2017 +0100

    Update README.md

[33mcommit 09037d529f53865a06a0ce94bfe6e9ec1fac2cfd[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 11 21:25:56 2017 +0100

    version incraese 1.1.29

[33mcommit 3bdf80d1c4c16a38398f68aae929e9515f185dae[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 11 21:13:36 2017 +0100

    version incraese 1.1.28

[33mcommit 3fc20ad12adf7bfda30b8dbafde85af2a85c7663[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 11 20:56:47 2017 +0100

    version increase 1.1.27

[33mcommit 880d7913334909c4249f23422f893edf7008ac70[m
Merge: 3ee0bd0 5d5405b
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 11 20:49:32 2017 +0100

    Merge branch 'testupgrade'

[33mcommit 3ee0bd0aa5ab8de7f3783240d9c0744bc651a2ae[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 11 13:04:38 2017 +0100

    moved beta-reports entitlement by default to comment, needs to be add for release to prod

[33mcommit a331e64b3ffe5e0d4be8d19c68ae79e315bba7fe[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 11 12:41:37 2017 +0100

    version increase 1.1.25

[33mcommit c77423fcb302b593c9b0ee56a46de2bf295fdfd4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 11 09:23:59 2017 +0100

    type in alarmservice, causes crash when checking battery low alert

[33mcommit 4314b2f19560577b98920160c43ae53f040f7217[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 10 21:36:10 2017 +0100

    changes for release to TestFlight - appstore

[33mcommit 4576bd78e63debdc23412be3aae9229e1281728b[m
Merge: 9334b0c 8a1e2ec
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 10 19:40:01 2017 +0100

    Merge branch 'bluconcombinescanandreconnect' of https://github.com/JohanDegraeve/iosxdripreader into bluconcombinescanandreconnect

[33mcommit 9334b0c61f923fe9f66c2cddeac5b51f93a66342[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 10 15:56:40 2017 +0100

    if blukon, ignore awaitingConnect and waitingForPeripheralCharacteristicsDiscovered

[33mcommit 9aebeba6f1f67d6cbffcde3eabe0116aca675eb9[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 6 23:23:36 2017 +0100

    additional fix

[33mcommit 44d0e7556acd9ace6313e568715bb925c81a1a52[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 4 21:33:10 2017 +0100

    correction in start rescan for blukon

[33mcommit 31644d551761d5754c6a947707ddfb970c824f1d[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 3 20:12:16 2017 +0100

    startrescan after disconnect

[33mcommit dd79e6b4b8ed4868e618d0af9a7e8956134cfae0[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 10 15:35:47 2017 +0100

    check phone muted at app start up and at regular intervals, also when no bluetoothconnectivity. Now Lukas can go to cinema without disturbing everybody with a noisy missed reading alert

[33mcommit 57adbdc158a8c75aa87e5b61002fe08f1a93030a[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 9 22:48:40 2017 +0100

    changed informational text related to low battery alert - also blukon low battery alert enabled

[33mcommit 5d5405b5e97863d42a9ef7e8d5ea30da00e81a7c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Dec 7 23:50:46 2017 +0100

    finalize upgrade feature

[33mcommit de0915f3b3fea5b886e1163a3c8e1c4ef1480f3d[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 9 21:30:26 2017 +0100

    adding latest bg value in alert notification

[33mcommit 741b3e42633671f8ebdb52883f517843252a71c3[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 9 21:03:33 2017 +0100

    small code improvement AlarmService

[33mcommit 8a1e2ec812973e8eb987bed169cfdd71396f125f[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 6 23:23:36 2017 +0100

    additional fix

[33mcommit 3ef4c5c95421dcbc5abea247fcf105a0ed731df4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 4 21:33:10 2017 +0100

    correction in start rescan for blukon

[33mcommit 738f658561fd61b4d5c13cf3523315c58504c52c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 3 20:12:16 2017 +0100

    startrescan after disconnect

[33mcommit ed83c11873cfc233a89eddbaad756694d15eaf3c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 8 00:03:45 2017 +0100

    changed aps-environment development, for production release (appstore) it would need to be changed to production

[33mcommit d32070bf315112d1d44b42736292ad0a2165f4c5[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 6 14:00:10 2017 +0100

    added ITSAppUsesNonExceptEncryption for release to appstore, just to test

[33mcommit ad77bc4035709bc262f74f60200d65bc0b0a1b29[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Dec 5 23:58:40 2017 +0100

    updateservice, fix in trace

[33mcommit e858b0ee2f3f0f22b57b41b7d0b4e4317a789fdb[m
Merge: 55d44d3 857b9ff
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 4 22:37:02 2017 +0100

    Merge pull request #23 from JohanDegraeve/statusbar-fix
    
    Statusbar fix

[33mcommit 55d44d33b5b9bb93efa0be46a94bab2d92e43930[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 4 21:23:11 2017 +0100

    readded remote-notification uibackgroundmode, because apple keeps rejecting saying that it's configured on the mobileprovision file, although it is not

[33mcommit 857b9ff8b8ad3d4b4da7f39487ce590ba2c3adcd[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Dec 4 11:27:17 2017 +0000

    Removed Application ANE

[33mcommit 9232b94a97635c558bddb7209b0126cda4414a17[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Dec 4 05:53:59 2017 +0000

    Statusbar fix, launch screen images fix + support for iPhone X

[33mcommit cd4282741ebc19c5fdd746456374047982de6c9c[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Dec 4 05:46:35 2017 +0000

    .

[33mcommit 9c6420c11408082f33c7116f792e17c1e5d70cb4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 3 21:41:01 2017 +0100

    removed warning that internet should be always on for the missed reading alert, because it's not correct anymore

[33mcommit e998f154cede815334a08d1bc086d5041ff432df[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 3 21:36:40 2017 +0100

    fix blukon battery level, 5% was not correctly assigned to setting

[33mcommit 938a85dcd4e2dcfe0955dbb62c0f87e43742b135[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 3 20:12:37 2017 +0100

    version increase 1.1.19

[33mcommit 1e028fab5e4b9c6d29430a8013ccda7df58547cb[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 2 23:08:39 2017 +0100

    polish for speak bg reading

[33mcommit dd8f345bf3e5feb9e7b4e66c9fab89828920815b[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 2 21:30:22 2017 +0100

    changed email ddress into xdrip@proximus.be

[33mcommit febdae8d4a59b377f285f1b40b2dce3d9cc97bb9[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 2 21:02:17 2017 +0100

    fix for blukon in isSensorReady

[33mcommit 1d7fa65402e82ec706523c98a779164eeca4acfe[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 2 20:31:40 2017 +0100

    alarm plays when app in foreground, was needed after previous commit to play notification sounds via playsound

[33mcommit 9cf576abdaf6895363babceab3c30564cc7471ff[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 2 12:06:52 2017 +0100

    numeric keyboard for changing speak reading interval

[33mcommit 4d622d9057231814534ecef7bf562f09f8c16be4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 2 11:55:23 2017 +0100

    mod in text about speak bg readings

[33mcommit 30a9f243f1c6f804ae0d69a2504fa93e4a3639f2[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 1 23:52:46 2017 +0100

    revamp missed reading alert, using deepsleepservice timer now

[33mcommit fde9fa9553ed55c80de85a3b0ad2b294aacdc1e8[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 1 13:49:13 2017 +0100

    removed tracing in DeepSleepService.as, creates to many logs when debugging.

[33mcommit 460bd5f74ca7af6d52e5aebe9ddcd3ab9a9fa7b1[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 1 13:47:48 2017 +0100

    removed everyting related to quickblox subscription and push notification, not needed anymore

[33mcommit e05df2a5ac1acb3837bd2d1b808a353f69f19d2a[m
Merge: e089786 3cccc42
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 1 00:06:55 2017 +0100

    Merge branch 'dexcomg5connect'

[33mcommit e089786530f6a92ab01f6bbd619222e2cff735b3[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 1 00:05:11 2017 +0100

    version increase 1.1.18

[33mcommit cc20661c269187a5a0e6f706b2014bb4b35a13d5[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 1 00:03:28 2017 +0100

    check if app is in back or foreground via ANE. Removed distriqt ANE

[33mcommit 8a099aa64efb32b98a083f7086707a766ff7f053[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Nov 29 00:01:24 2017 +0100

    alert sounds through playsound ane

[33mcommit c88d4854d82e03cebd5ff9f9755af1c6c9c60eab[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 28 00:19:05 2017 +0100

    play all alerts through background ane

[33mcommit 3cccc42c79744da83ea7efeb5f268793cf180770[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Nov 27 23:14:51 2017 +0100

    dexcom g5, after disconnect restart scanning in stead of try reconnect

[33mcommit 637474600f4456c98ddf8b09046765ce595957e2[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Nov 27 14:03:49 2017 +0100

    fix blukon, isSensorReady should always return true

[33mcommit b8fcf7043b67d9702c7b25b42da2824f7e8a3258[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Nov 27 13:51:08 2017 +0100

    new splash screens

[33mcommit 4ed0082b78ff10f168cd602ceee4f672229a0369[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 25 23:14:03 2017 +0100

    version increase and add NSBluetoothPeripheralUsageDescription required for App Store submit

[33mcommit 6b4027e28add07d93f640002b1b274b2e60a6142[m
Merge: 15d4b35 de37ece
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 25 17:38:47 2017 +0100

    Merge branch 'speech'

[33mcommit 15d4b35f5c03ece90d108a097d0ff21fe6239f4a[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 25 16:42:50 2017 +0100

    version increase

[33mcommit de37ece4d21861c7eb8e447fa50a4ee352f724cd[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 25 14:45:50 2017 +0000

    Added Russian translation

[33mcommit 980bf16cc2132a9abe52a9ae1eb586ab80b5b09d[m
Merge: 0dab18f b2c1717
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 25 14:24:30 2017 +0000

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 0dab18f1f48e5d13d08935e36c5278187e3bb350[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 25 14:24:24 2017 +0000

    updates

[33mcommit b2c1717505509eb4f139c6539dc9f17ee0fbdfd7[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Nov 24 23:42:01 2017 +0100

    fix in Dutch translations

[33mcommit 31e9f083349752d83dc43a59f4830aec2fb02178[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Nov 24 23:41:48 2017 +0100

    remove aps related info in entitlements, also not needed anymore

[33mcommit 8a6d844b3ddb6b1e9de3f444dc48e1269f06957b[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Nov 24 23:29:58 2017 +0100

    add NSHealthShareUsageDescription key in plist

[33mcommit 6f38405f6d480ba4bb383bf1f4565c8c65aa55a9[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Nov 24 23:15:34 2017 +0100

    removed UIBackgroundModes fetch and remote-notifications from plist key/value pairs. This is not used anymore

[33mcommit 49310f832b4ca30ee1f53a0fa093c4da6d33f937[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Nov 24 21:59:48 2017 +0100

    Update README.md

[33mcommit 45cdb6bb400f0ed93f0a31d77b7de3fa985886f0[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Nov 24 21:41:18 2017 +0100

    new icon and splash screen. Flex splash screen removed

[33mcommit 045084f2d1531e1a344170f2f130ab5ed3382b3e[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 23 22:40:04 2017 +0100

    fix phonemuted alert

[33mcommit 092b73dcbe1b46acc069f2cd69f1d3da20749c5e[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 23 22:39:37 2017 +0100

    version increase 1.1.15

[33mcommit 05446f8430558b8cb59bb3d3701f2b8b79e4bcd2[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 23 22:03:13 2017 +0100

    French translations for text to speech related text

[33mcommit bdbe9ae430b4a86046c92c37e2358055d8657b71[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 23 20:12:35 2017 +0100

    deepsleeptimer, keeps the app active, should improve stability Bluetooth and NS upload

[33mcommit 4099c77986d15ba64df2d2694f34aadfa7064528[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 23 00:27:09 2017 +0100

    flag to check if production, if production then don't do checkupdate

[33mcommit 72947420ec9b183ff38aa9f98a49dd3f02710739[m
Merge: 347a205 e288c3b
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 21 23:44:44 2017 +0100

    solved mergeconflict

[33mcommit 347a2057ecef421e9989eb44e6090362095fc8a0[m
Merge: 4eb9315 0d9148a
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 21 23:15:08 2017 +0100

    resolve merge conflict

[33mcommit e288c3bd3b35c024a144d11807d369a9dc4081f1[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Tue Nov 21 13:42:05 2017 +0000

    Code cleanup

[33mcommit 5b9a3af2c76e7b76f5a459b58bfdf3be27701b9b[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Tue Nov 21 01:46:41 2017 +0000

    Merged settings from speech branch

[33mcommit 0d9148a51b701e7b3ce52241c9930fdde7d58159[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Tue Nov 21 01:31:45 2017 +0000

    Removed german for now. Waiting for translation.

[33mcommit 2bc36f49aef181606a2a354bd2c1fa2ffc6fbdc7[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Tue Nov 21 01:25:40 2017 +0000

    French locale for speech

[33mcommit 4757429fce33a65d6c98f8b8c09b352946d17ddb[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Tue Nov 21 01:25:10 2017 +0000

    Code cleanup, added compatibility with alarms and locales for french and
    dutch

[33mcommit deb91d98f0b2f31bab666c7850a70812185a3ba3[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Tue Nov 21 01:24:16 2017 +0000

    Added compatibility with text to speech

[33mcommit 1ce0c5bee01ab40fcafa8a5e7357bc295f8d87d4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 21 00:30:51 2017 +0100

    Dutch text for bg readings

[33mcommit 1f073439601b82af0047b78e54c0b451b7af35f6[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 17:50:01 2017 +0000

    small improvement in translation

[33mcommit 4db92320cde3776378dacd4a9aed9bc33ff38f2f[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 17:44:09 2017 +0000

    improved instructions for speech

[33mcommit 9854d312930c7fe2fc4f9443e46250ffb486462c[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 16:44:55 2017 +0000

    Code optimization. It now uses locales and fallbacks.

[33mcommit c2611d278bdc67d0a9b6618fe18cff20648fabc0[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 16:44:14 2017 +0000

    Added locales for differents languages for the speak readings feature

[33mcommit 99f2756eb14274ebf9f8663b2c31fa4ac428fb01[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 15:15:28 2017 +0000

    Tiny optimization

[33mcommit b0bdfaf209e3056385483fda45c6e51f885bbd96[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 14:50:10 2017 +0000

    Added localization for language codes and descriptions

[33mcommit fae8e75b4453733808875dafe28e71a428d1dd0a[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 14:49:36 2017 +0000

    Code cleanup and optimization. More scalability for future languages

[33mcommit 409526784c41e412d1e9981f13dc0bb927e6651f[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 03:15:49 2017 +0000

    Add instructions popup for speech and merged previous changes from the
    app-update-notification branch

[33mcommit bebeca621f0d4546728e630bff7da5c06586449a[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 03:14:54 2017 +0000

    Add feature to speak readings in different languages

[33mcommit 9c6c8fa8c95618747d586aea11b11a64a972b1e0[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 03:14:24 2017 +0000

    Fix bug for speech instructions popup settings

[33mcommit 7ad240cdbed12f1eba1862d79fdc2de631af9ef8[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 03:13:41 2017 +0000

    Localization for speech instructions popup

[33mcommit 12030977d3e7940f3b1324f339ae6e59c4cf2de4[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 00:49:27 2017 +0000

    added localization for language settings

[33mcommit 9c24ca92acf608f7956b9d32d3ade0b8ea28a967[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Mon Nov 20 00:49:05 2017 +0000

    added settings for language selection

[33mcommit 09b34ba6ee020760bf7778d3c843f2d95d84b5e0[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sun Nov 19 23:06:28 2017 +0000

    Merged localizations, settingsview and coomonsettings from the app
    update branch and added settings for speech language

[33mcommit 204297a98448d4c18ba1aadadd69d5a42fd25f9d[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sun Nov 19 22:59:36 2017 +0000

    Add setting for speech instructions

[33mcommit 2df4d8ed54bd37e2fe8b81b3f7e04dab159b5612[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sun Nov 19 22:56:47 2017 +0000

    Removed deep sleep timer

[33mcommit f304ac5b2005bd28e1aac237620c483f216d218d[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sun Nov 19 20:26:35 2017 +0000

    Code cleanup, added settings for app update feature.

[33mcommit 0dbc0b67b31099e9b7a82b4cc1d8831fdf97a294[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sun Nov 19 14:33:04 2017 +0000

    Added settings for the user to select what it wants to be spoken

[33mcommit 8b794293a2f7c2ec8f362c0ff816ec512ccfd9a8[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sun Nov 19 06:52:03 2017 +0000

    Don't play silence audio if app is in foreground

[33mcommit edeff42bc1d5dc953ac39db022faa78b5a6f1294[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sun Nov 19 06:47:32 2017 +0000

    Prevent deep sleep in iOS. Code cleanup. Add audio file of 1ms of
    silence.

[33mcommit 39a2d1e8f9d86858f4cf7c6354a61ee3b31da3fc[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 17:09:38 2017 +0000

    Code refractor

[33mcommit 5eb905083cb3c27464adcc5818b3088afe72f8a8[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 17:09:16 2017 +0000

    Add constant for GITHUB API URL

[33mcommit 21e7546044ec66035f34b1b4d2dc2df97528ee71[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 15:28:38 2017 +0000

    ?

[33mcommit 8c6e31aaeb8ffa2b5b3543ddf4458eab8571cf99[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 15:17:44 2017 +0000

    started to add functionality to only check updates once a day and ignore
    updates that the user has selected

[33mcommit 7a8f0a216918c9ef931ed456cc71f9257dc242cc[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 13:30:15 2017 +0000

    fix popup message

[33mcommit dac9890c06eb500607d01be462900ea6a66f3cea[m
Merge: b985f91 bf7cdae
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 13:24:10 2017 +0000

    Merge branch 'speech' of https://github.com/JohanDegraeve/iosxdripreader into speech

[33mcommit 743d62786513d34ec9c9a15d6bba3115c4145ff4[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 13:19:34 2017 +0000

    app update stuff

[33mcommit dd74dd080d71649fa4ddf9d3ce90bcfe04015887[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 13:18:50 2017 +0000

    switched to alert popup when update is available

[33mcommit e09f252c03f77cde1512c1f49563e04d48783851[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 13:17:57 2017 +0000

    create localizable strings for update popup

[33mcommit bf7cdae7c75439c4375ab8ad178eae1d62fec1d6[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 18 13:00:37 2017 +0100

    added call to BackgroundFetch.setAvAudioSessionCategory depending on speak reading status. Phone silent mode will be overriden if readings need to be spoken.

[33mcommit 4e0168a60da0f0f7234255e999e9cd8f21532cbb[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 03:45:17 2017 +0000

    Alpha version of application update

[33mcommit 26a75b0ddf7207027b6953113564f4b3f1fb79b7[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 03:28:13 2017 +0000

    Fix const declaration for app update notification

[33mcommit ee5bfb9fbe6b1e7d254aea999066816e47cbd863[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 03:19:54 2017 +0000

    Add const for update identifier

[33mcommit 11e7c885154ae1db41a682e058a02105835d26f0[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Sat Nov 18 01:47:19 2017 +0000

    Function cersionAIsSmallerThanB as public so it can be reused by
    UpdateService

[33mcommit cd9ef1aaafd1a1711cdf1d5e706d6cf5556c2a32[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Fri Nov 17 23:58:01 2017 +0000

    Start UpdateService on boot

[33mcommit 69b47e9f9946b4b770ebc9680c504e1fcd8e5ec3[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 18 00:41:29 2017 +0100

    improvement text to speech

[33mcommit b985f91144077d3b1e880ea4631e996d9d0e1c5a[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Fri Nov 17 23:27:22 2017 +0000

    Change to Air 25 SDK

[33mcommit 9f12d5ea77e09c90600c7b345e15072776e32abb[m
Merge: 7633a21 0272b42
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Fri Nov 17 23:20:10 2017 +0000

    Merge branch 'speech' of https://github.com/JohanDegraeve/iosxdripreader into speech

[33mcommit 7633a21ebac85b65125b5d2f3e107078017a8ed0[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Fri Nov 17 16:51:10 2017 +0000

    .

[33mcommit 0272b426152b85f3805dd46653a2a14b9f805a5b[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 16 23:34:59 2017 +0100

    textto speech with own ANE

[33mcommit 55a9c3da6f37822c515791641aa0191848a2aef5[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 16 22:36:25 2017 +0100

    re-added trace in homeview init

[33mcommit 939a272ad7f5d90bb8668e590c7d1d879efe6c72[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 16 22:26:08 2017 +0100

    some changes

[33mcommit 4eb9315c0c8ab8af83bbb493ceb4cb805cb3f22e[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 16 21:13:27 2017 +0100

    stop using old bgreadings for calibration, this is important for blukon

[33mcommit ae5acfb7e1e60f705339921aac2987025409f90e[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Nov 15 17:59:36 2017 +0100

    blukon : notification/dialog for patch read error

[33mcommit b29cf17c71d926537a67d41d689555f001b6a560[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Wed Nov 15 12:46:20 2017 +0000

    alpha 2

[33mcommit 7859391b47e9814b41c736f3b1238d3be5f6bee8[m
Author: Miguel Kennedy <miguel.kennedy@caloriejunkies.com>
Date:   Wed Nov 15 12:32:46 2017 +0000

    alpha 1

[33mcommit d986f12664a0f1039d07255d7289961311ae8c1f[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 14 22:25:06 2017 +0100

    enable isSensorReady for blucon

[33mcommit bb024c97ae27daf7dd3ed5930c71f761c2452312[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Nov 13 23:54:49 2017 +0100

    version increase 1.1.15

[33mcommit 251184f88a6bb60c84679347b7b7870bb80e936f[m
Merge: 4980926 9f54559
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Nov 13 23:45:38 2017 +0100

    Merge pull request #21 from miguelkennedy/visualnscalibrations
    
    Visualization for calibrations in Nightscout

[33mcommit 9f545594bb3e135435c3eea8d7f373a30503ebb7[m
Author: Miguel Kennedy <cala@hushrecordz.com>
Date:   Sun Nov 12 22:08:07 2017 +0000

    Visualization for calibrations in Nightscout

[33mcommit 498092603a2976703dd7af803c85e8998da5e573[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 12 21:12:54 2017 +0100

    version increase

[33mcommit 02fe2f2fde25ed0351c6cdffbca43e784cf45a69[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 29 22:44:35 2017 +0100

    blukon historical data

[33mcommit cbde18f527b3556088e055a95b3934b334df9c3c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 11 15:17:57 2017 +0100

    upload calibrations to nightscout

[33mcommit a56a0a7ac58b6701a0b8fdf0e2900b9f65a5641a[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Nov 8 23:13:50 2017 +0100

    round filtered and unfiltered values to int

[33mcommit 01ee772d9e99b0c3197d00610e1892dcdff50a3c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 7 23:23:42 2017 +0100

    no battery alert for blucon, bluereader and limitter, because values not tested

[33mcommit 122e18b4d9fa015bab5b0be38f2ddd916dbf9c67[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 7 22:40:00 2017 +0100

    minor fix for nightscout upload

[33mcommit 3c895e204acb097f488cdd8dabae2b05ceedb207[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 5 17:29:19 2017 +0100

    version increase 1.1.13

[33mcommit 0ae874515429c93b25cd1a10c7cc2f112901320c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 5 15:20:31 2017 +0100

    - get ANE version via API and write in trace file
    - trace file send to xdrip@proximus.be iso johan.degraeve@gmail.com
    - removed warning about no sounds when app is in foreground because this is fixed
    - added Dinantronics as allowed name for xdrip device

[33mcommit ae0e3326f5e72e22950c96c0f73e4b45012f6501[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 5 11:44:14 2017 +0100

    fix version check + version increase 1.1.12

[33mcommit c121dd1801cdd49e28094c7635529aa3dd5db61c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 5 11:26:47 2017 +0100

    version increase 1.1.11

[33mcommit 56a39edd26fc7f4f064e1065830270e982465a07[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 5 11:25:49 2017 +0100

    dexcomshare service upload, again stability improvement

[33mcommit e4509f017742286aa453400c9149f8e02b277658[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 4 22:38:44 2017 +0100

    version increase 1.1.10

[33mcommit 14a6821bbb3a97c5ae069fa3965f8d4b6f4a24ca[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 4 22:38:23 2017 +0100

    version retrieved from plist

[33mcommit a4edc8175c4bc3f7be22d40855a162b6436b3c5d[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 4 17:22:27 2017 +0100

    delta in notification screen

[33mcommit 6609299fe08f751eb4010cf05da741a474eada63[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 4 15:53:43 2017 +0100

    Dexcomshareservice, if json parsing error then re-login

[33mcommit cf2aa88be27756eafc5184b489f36cb94eff298b[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Nov 3 18:41:32 2017 +0100

    version increase 1.1.9

[33mcommit 7377d8f06ff6f636ca2a17ab58cab87019f9cf5d[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 2 23:21:27 2017 +0100

    dexcomshare service, check on DOCTYPE

[33mcommit b3686765727f28b27f6cbaff8bc2cae5e01ac5fd[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 2 22:37:00 2017 +0100

    version increase 1.1.8

[33mcommit daf57ab9e4631d281d0f36a6d9efe23fffa797ae[m
Merge: 269e472 301bc1e
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 2 22:21:14 2017 +0100

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 269e4722a7c1fef9c0a3de707ae5ede5900f1dad[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Nov 1 21:05:37 2017 +0100

    improve dexcomshare

[33mcommit a55dd7d8b0e72038235b249f31588308ab7f79fa[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 28 23:57:13 2017 +0200

    alert sounds also when app is in foreground

[33mcommit 301bc1eb03075af48204a05b7984daeb52a9da53[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 28 22:44:35 2017 +0200

    Update README.md

[33mcommit a0703db1da7119c166a6117f4cd821829c968ed1[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 28 22:29:29 2017 +0200

    small improvement blukon communication, not sure if this will improve general stability

[33mcommit 02507e3015901f340e0b3429215318609ff27ba9[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 28 22:15:16 2017 +0200

    Update README.md

[33mcommit 1ed8d5de8b523c706b12996d78ff04dedaf95728[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 28 20:51:44 2017 +0200

    Update README.md

[33mcommit bfe1983174e2cbd4e4bf0add61d68d6e556e0d0e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 28 19:35:47 2017 +0200

    Update README.md

[33mcommit c78818c26f911258f9fb0e65242e2060887ada31[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 28 19:14:21 2017 +0200

    Update README.md

[33mcommit 8bbc6002bee79cb2e35e4395943252f3ef5e7497[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Oct 27 18:53:48 2017 +0200

    version increase 1.1.7

[33mcommit fa4800767fb178a8af8a9bf7af028a0afba0f094[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Oct 27 18:50:36 2017 +0200

    improvement G5 bluetooth stability

[33mcommit d6a7ac01bc7e06715f2ee3c7d112a5c98aed101b[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Oct 25 00:12:50 2017 +0200

    version increase 1.1.6

[33mcommit 11a08de60d8cceb06a934fd23e01d8de40b7cb46[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Oct 25 00:06:15 2017 +0200

    ..

[33mcommit 92f59581dfcc5c464e9947cf80779c726c2ebeaa[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Oct 25 00:04:21 2017 +0200

    fix for blukon

[33mcommit 51771f2edfcde04d031799e30e8b0c24222957e4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Oct 24 23:39:33 2017 +0200

    remaining bug in createandloadurlrequest, after removing foreground parameter

[33mcommit d00834a656db32b6782c1ee27041ddee1aef2712[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Oct 24 22:30:27 2017 +0200

    resolve merge conflict

[33mcommit d62f189053dded4a4ce265101aeb9f596f51db8b[m
Merge: 0fe8db2 0645e88
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Oct 24 22:25:58 2017 +0200

    .;

[33mcommit 0645e888b726236a21ee3bec334f2cb499f81d7b[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Oct 24 22:21:21 2017 +0200

    k

[33mcommit 0fe8db221ae454d3a8882ab33333f0155abb7509[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Oct 23 23:07:27 2017 +0200

    version increase 1.1.5

[33mcommit ebdf3bcddeb4ceab256401113d9879b6976e27d0[m
Merge: e5b0668 932a021
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Oct 23 23:06:20 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 7cd0826cf44414c4631ef53c9d872cf70c033e61[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Oct 23 23:05:44 2017 +0200

    fix : when modifying alerttype name, also name in alerts where this alerttype is used must be changed

[33mcommit 932a0216de1a71c70eed0add512e4bbac4ec1498[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Oct 23 22:04:35 2017 +0200

    Update README.md

[33mcommit e5b0668ff55c26b9ae72b7528c13b1fa466e769c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Oct 23 21:21:31 2017 +0200

    future missed reading alert planned at least 6 minutes in the future

[33mcommit 8e281219fd1a8bfe770ef5e8efdb4ed4ccdcb144[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 22 23:08:36 2017 +0200

    fix for display double arrow up or down

[33mcommit fce480a83b66faaf2ca9a85d1383e01fd0b87362[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 22 22:24:17 2017 +0200

    added BluKon in readme

[33mcommit 3356bf4cb52b0725439b80fd70fbce4a4971cdca[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 22 17:43:36 2017 +0200

    fix in trace, logging timestamp of last calibration was wrong

[33mcommit 483010fa43d556cc2abd4be3dec6f09b2791d8ca[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 22 17:03:28 2017 +0200

    dexcomshare service, process error code MonitoredReceiverNotAssigned

[33mcommit e7411f090162c3bfa3d65d0dbfa667ab764036c4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 22 16:31:41 2017 +0200

    info screen about blukon is now about blukon and not G5

[33mcommit e02af8899b523dc3285cd1dea4a3dffebeaa2291[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 22 16:14:11 2017 +0200

    explanation about blukon transmitter id added in dialogs

[33mcommit 14084cc7f920dc43953214d15b9321f49dbaf76d[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 22 15:57:53 2017 +0200

    removed warning that blukon is in test

[33mcommit 119a13dbb55e19125a229ad920c4b4410d28fd05[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 22 15:27:37 2017 +0200

    bluereader reconnect, same approach as blucon

[33mcommit 85442d1cc95be7ec13b6ea0e8a960f02d160dcaa[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 21 23:43:43 2017 +0200

    version increase

[33mcommit e303d88e623845d8f30f6ced34bc64714eca171f[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 21 23:41:46 2017 +0200

    pre play sounds when selecting new sound for alert type

[33mcommit c1c5c166ae40bf5ea592d833dec526471377bf7a[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 21 23:41:17 2017 +0200

    fix related to commit in ANE-BackgroundFetch, commit 6225ceff952a4fa3ebf02338296580d21fb0003d

[33mcommit 7b26870e39a797c33a3fd546f7d276bae3ce7984[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Oct 19 22:34:39 2017 +0200

    shorter format for new sounds

[33mcommit 69d1918144c54a7bcd872fab81e7f01e6ac92a7c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Oct 19 21:50:15 2017 +0200

    version increase

[33mcommit 092e55ca1811de2f1e474df86023b838578a4534[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Oct 19 21:46:05 2017 +0200

    sounds created by Lukas Meinardus

[33mcommit 3de938e8470e77767374f3469ed7a221c236a461[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Oct 19 21:03:48 2017 +0200

    upgrade FLEX SDK to 27

[33mcommit fa217ff8d752f8a010cf33ff2911a46bbcb3933c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 14 21:09:21 2017 +0200

    version increase

[33mcommit c3449108e4638b7b83b18eb1df6b5d787ec2ba62[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 14 21:05:46 2017 +0200

    blukon pairing : notification if device not paired and app in background

[33mcommit 9882db236ba7e6759daa34ec0b5d57314526560c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 14 18:17:43 2017 +0200

    reconnect for blukon

[33mcommit 1fa2c9d2f3880234cf756a1069dc7f26d8b80204[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Oct 13 14:08:20 2017 +0200

    additional trace info

[33mcommit 624c4b46911170b9bc495f253a079ae191240a21[m
Merge: b5c0776 908500f
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Oct 12 21:49:46 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit b5c077698e1503070825169dc4700b45751ac151[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Oct 12 21:49:29 2017 +0200

    code cleanup

[33mcommit bd5568f57c3db2fc1c7ff7bdda52635c75fa460d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Oct 12 21:15:04 2017 +0200

    fix in snoozing alarms

[33mcommit 4735af470b397ec025de0b1ba574754a38f6beb1[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Oct 12 21:14:48 2017 +0200

    more tracing in dexcomshareservice

[33mcommit 908500f0f0f950888541fba026a681338b43d4bb[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Oct 10 21:56:56 2017 +0200

    Update README.md

[33mcommit 40a93eae7204eb0fb500ed2c225dd27d75e92d6c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 8 23:39:23 2017 +0200

    warning if in G4 protocol unknown packet type received, with option to send e-mail

[33mcommit c22720a31e278f700996a591cde01c97a6e85a8c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 7 10:52:25 2017 +0200

    version increase 1.1.1

[33mcommit fac9da61b9ded0bf45d4089060cb3c7033b1c676[m
Merge: ff646be 101345e
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 7 10:46:32 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit ff646be5d87e753074ec3218ad47b573c3cbdb28[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 7 10:45:07 2017 +0200

    fix for us url, immediate check of username/passwrod

[33mcommit 101345ea51e9862fdf7202f6b53e5708dc39a2aa[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Oct 6 08:49:44 2017 +0200

    add info about what to enable in app

[33mcommit a72849238b88aa07d71cbb7faf180f963fd453e7[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Oct 6 08:46:31 2017 +0200

    remove calibration request notification when user calibrates without clicking the notification

[33mcommit bb7c6fc0768d9fcb23c0dd4a72ef8ef8791dce8e[m
Merge: 95989af e280120
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Oct 5 22:40:47 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 95989af982340385d3be4e15b38649c363877bb2[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Oct 5 22:39:04 2017 +0200

    select bloodglucose unit during startup

[33mcommit 0d8865dcd7bbf3dea0a623873972dbec6ae37f28[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Oct 4 23:04:49 2017 +0200

    remove calibration request notification when calibration is done

[33mcommit e2801209e20207c794525b0e4a0e1fa8c06764a2[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Oct 3 22:43:57 2017 +0200

    added feature upload to Dexcom share in readme

[33mcommit ae049b0b01e14dc43f43abd202936256f8bfe019[m
Merge: 9a5bfa9 2b30aa0
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Oct 3 22:11:50 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 9a5bfa9b54371c84390521e59f62e2e63e337896[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Oct 3 22:10:51 2017 +0200

    fix in check low and high value vs each other, in case of mmol

[33mcommit 989abeb0604a32765245ed590768b50f1dda9950[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Oct 3 12:08:58 2017 +0200

    for fsl devices, no wait period after sensor start

[33mcommit 678b998d93491fa32a662a88d7d73b233a2fdf32[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Oct 2 23:58:42 2017 +0200

    improvement dexcomshare, additional error cases

[33mcommit 9c9dc372f97cceef1b7ed6e7b101e42049a5f7a3[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Oct 2 23:57:42 2017 +0200

    nightscoutservice : removed all calls to completionhandler, not necessary anymore

[33mcommit 6068f19913479ce52f1d6ce4299e5228f7bd896e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 1 17:21:13 2017 +0200

    bluereader uuid ? and attempt blukon reconnect

[33mcommit 5b99cad03a964d9113826c86499149008b4dfe9b[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 1 17:19:18 2017 +0200

    version increase

[33mcommit 9f8a85afe5db98bc38c9af69b1c4869034b6a7c2[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 30 11:09:25 2017 +0200

    Dexcom share settings

[33mcommit ba9bfb19bc59dacb87149216fb9fae289a417f4f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Sep 27 23:53:56 2017 +0200

    first working version Dexcom Share

[33mcommit 279e6d6f9bece3d0c118f0f21ddf10b0d0ac4fc2[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 24 15:40:14 2017 +0200

    added bluetooth tracing

[33mcommit 977ced62e44113401c32db16f4ecf3793af8c532[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Sep 18 22:34:28 2017 +0200

    fix in tracing

[33mcommit 2b30aa05de195f579e650fa13c7a6647ac36d0ef[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Sep 25 22:57:12 2017 +0200

    link to method to get UDID

[33mcommit ac3ebae1555d4ab8d2792e9fd4c3496647e400a5[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Sep 21 20:24:21 2017 +0200

    Update README.md

[33mcommit 78c84747a218bfad35dd96bc225efa64ea21bf32[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Sep 18 23:39:21 2017 +0200

    Update on installation procedure

[33mcommit 2c8e5b466a1bda065d6c23781afa3cfe2d809d81[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 17 21:14:20 2017 +0200

    replaced all blucon by blukon

[33mcommit d4f023126ceb480cac4151b2ab7f0e4c0d84a58d[m
Merge: 10a80f9 37573bd
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 17 20:44:22 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 10a80f9d6d99b0dacd5df16c57af2668a7b91c1b[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 17 19:50:59 2017 +0200

    dexcom share first draft

[33mcommit f633394295d7419a35ae96eca9c42b0e28b92320[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 17 19:45:55 2017 +0200

    prepration for dexcom share

[33mcommit 555f9011b525f2dd1643ce2fd9bcc0e0fcaac781[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Sep 15 00:03:42 2017 +0200

    license info needs to be accepted before being able to continue

[33mcommit 37573bd6aa1b415edb1c920f57239aa4949b9d21[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 16 15:58:17 2017 +0200

    how to install with iTunes 12.7

[33mcommit e72cd32af0334581f0acd7a1e296820a2ba348a7[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Sep 14 22:56:35 2017 +0200

    Delete DefaultIcon-License.txt

[33mcommit 86e082d14fd30f93e1c9fe93304ed8031ee48a1f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Sep 14 22:55:23 2017 +0200

    Create License

[33mcommit 11efd260d3c86e67209904c7ae5e420c36e3e818[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Sep 12 21:35:12 2017 +0200

    fix in calculating and showing sensorAge for FSL

[33mcommit 7f2f9f4d129f2d7e860ff1ff87cf84858e488712[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Sep 11 23:16:23 2017 +0200

    blucon aligned with xdripplus commit db6f0e16052bb94cd43e0c3a431e578f4acaf8e9

[33mcommit 521521cfd8fb1756fe6b18bd5bc7e09f294df107[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Sep 11 23:15:21 2017 +0200

    Trace file shows info about device when opened initially

[33mcommit 297e99504be08f60b9ddd1f75cd05df7c1ece7b4[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 10 17:48:59 2017 +0200

    method to get device name in BluetoothDevice.as

[33mcommit 613e63a817687346a69af3a73238464182ec77d9[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 9 23:41:03 2017 +0200

    aligned with xdripplus, commit 4e35d1d181d73f096c978ce4ad1920a96e8a278c

[33mcommit d16096f27ff8575df88b22003d2f6b88ada2bf1d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 9 22:47:39 2017 +0200

    quickblox registration disabled, not necessary anymore

[33mcommit daa87be2702fe9042259e81f54016ca663a958e9[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 9 22:36:52 2017 +0200

    improved tracing
    - year, month and day added in timestamp
    - when milliseconds less than 100, add 0, if less than 10, add two zeroes
    - also ANE modified to give year, month and day

[33mcommit 8c17b1f4cb87c2e009fa2e86314ed215df7f2d99[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 9 22:14:17 2017 +0200

    code improvement

[33mcommit 1c8423de9b43bfdd9c37e8f356d7c50748a5ef55[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 9 18:39:44 2017 +0200

    adapted limitter multiplication factor as in xdripplus

[33mcommit 1fd20594a80410461bb6eff8ab80725b1d78b340[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 9 18:39:24 2017 +0200

    version increase

[33mcommit 904e3d1330c8d40c57059b226f5f08a6d7e5f832[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 9 12:42:35 2017 +0200

    fix blucon, blockNumberForNowGlucoseData in hex should be one character not two, ie there was one 0 to much

[33mcommit 63214569e68a922b85b49749ed1aae11218d0432[m
Merge: d5a29b5 91794b9
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Sep 7 23:59:39 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit d5a29b577e10973ff9bab6fec66a2057e60fc8b6[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Sep 7 23:52:58 2017 +0200

    blucon aligned with xdripplus commit 05c51872b19c643eb5146e5c5d86844d03d4baf4

[33mcommit b8d2037cd9c94fe20115c89a629a103a6f90f2c3[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Sep 7 22:52:05 2017 +0200

    removed popup with licenseinfo

[33mcommit 3420e767320a9e990513920d296e0201f9f3ba64[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Sep 7 22:40:05 2017 +0200

    changed message about possible delay in nightscout upload because it's not applicable anymore

[33mcommit d2f2dd2a5033b0857aa8071a512d23a277dcd470[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Sep 7 22:38:50 2017 +0200

    code improvement, simple dialog

[33mcommit 86b0b3980d64ed26b3ada6315131e1f22f99c6cf[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Sep 5 22:43:00 2017 +0200

    change in request blucon transmitter id

[33mcommit ac0104bd0c84e105632da501bde5c5aaa1b32cb4[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Sep 5 21:49:54 2017 +0200

    renamed blucon commands to make comparison with xdripplus easier

[33mcommit 31da1488ae556d72a564ab77ec15d415734621e4[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Sep 5 09:14:31 2017 +0200

    reset Blucon battery level when changing transmitter type

[33mcommit 71f721febe617129185f958fdd2fc680f448a0de[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Sep 1 23:30:10 2017 +0200

    device connection complete for blucon and bluereader dispatched when device connected

[33mcommit ee746c6e7b44e58f10671284f2a95e3e0569e992[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Sep 1 23:26:51 2017 +0200

    remove unused traces

[33mcommit 91794b9902ea30452902e64fa507a45bd154ab14[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Aug 31 23:20:42 2017 +0200

    Update README.md

[33mcommit 900a8cc72a48afbdbaca6d2f11659628e8e81f7d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Aug 31 23:06:59 2017 +0200

    blucon battery level and sensor age (not yet known) in status screen

[33mcommit 6400c15ae5c4e55b123bc7967cafcde4cae573bb[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Aug 31 22:22:02 2017 +0200

    code cleanup

[33mcommit 8503899b9405e2a159f7bfbea527e29f00500c5f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Aug 31 00:00:37 2017 +0200

    modified tracing

[33mcommit 02789bc65378d4b678ca43810ceb39635b0d0783[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Aug 29 20:41:58 2017 +0200

    fix in logging

[33mcommit 9f6a5aa465a481f607e5985bb7c06e15c7d004b4[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Aug 29 09:14:45 2017 +0200

    blucon draft 3, calculations move from c to actionscript, created TransmitterService

[33mcommit 847d7203a137ef14e13ed7f549b693c21ca47177[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Aug 28 00:02:13 2017 +0200

    improvement ns upload + support bluereader

[33mcommit 923d0495511f777c5a263feb7466794429e3358c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Aug 25 00:42:28 2017 +0200

    changed assignment of blucon state and added tracing

[33mcommit a5e63d2cacd3d2221d25a576e7e0550e4dd8aaa0[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Aug 24 23:32:16 2017 +0200

    improvement for G5, check on lastreading done right before reading is ready

[33mcommit f46d8e7be862f7d8713912e4fc384604d4634d26[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 23 23:57:15 2017 +0200

    blucon draft 2

[33mcommit 6a2ededfd1fe9028b64cbf4cabab9cbc652c8982[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 23 21:32:42 2017 +0200

    changed logging and name of forgetbluetoothdevice

[33mcommit a01e46602fc2bd0606feabcfa8d7767ed0a0dc40[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Aug 22 23:29:18 2017 +0200

    device type selection : g4, g5, bluereader, blucon, limitter

[33mcommit f806001b2151a6dc417c7cf6743ecbc4b32d1e20[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Aug 18 23:27:28 2017 +0200

    bluereader, wait 4,5 minutes before treating new packet

[33mcommit a807b2f1841929eeb15737b469b37fdb12d113e5[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Aug 18 22:55:36 2017 +0200

    changing management of device type, needs further updates

[33mcommit e7438542cc0b0b76f90e9d1e29e44dc4a6a3e33c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Aug 18 21:32:50 2017 +0200

    bluereader, ignoring new readings if previous was less than 20 minutes ago, aligned with xdripplus

[33mcommit 15bedf290105697a8531b0484434e6715cf68bc5[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Aug 18 00:53:02 2017 +0200

    bluereader temp commit

[33mcommit 80006003de49bb96144665ca3326a85ecfedf207[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Aug 14 22:31:58 2017 +0200

    related to commit 0110dfb551b5b696cc440f9366212312be714af9

[33mcommit 64511500eb7db759cedf36a667339793d985c676[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Aug 13 23:08:25 2017 +0200

    code improvement notification service, always on notification

[33mcommit 47582ca37adb7c3fd58afb16db8363f77786144c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Aug 13 22:53:21 2017 +0200

    code improvement

[33mcommit 0110dfb551b5b696cc440f9366212312be714af9[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Aug 13 22:50:12 2017 +0200

    homeview not setting isDexcomG5 now

[33mcommit dfa0c9361656077b3b98f1cf7740766600b317e9[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 12 21:35:39 2017 +0200

    version increase 1.0.2

[33mcommit 7454404a3a689e6a523dcbdf378ff15fccc877dd[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 12 18:16:03 2017 +0200

    print peripheral device name if unrecognized

[33mcommit 9442499b76a56288c4ede78bd7450c5e539848c3[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 12 17:53:00 2017 +0200

    in HomeView, when initial scan stops, remove eventlistener for STOPPED_SCANNING, because only interested in this event when initial scan is done

[33mcommit 0d437879326d5818581525355e1cf9f9d3c4511f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 12 17:47:32 2017 +0200

    for xdrip : bluetoothbutton color change removed because it didn't work to modify a button icon

[33mcommit b6667d22b089d0dd21eb449c9bb8e9592ccd3b63[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 12 12:06:27 2017 +0200

    ce5354cc776aa4b9ac029bb871f6aa1212c28176 had a few minor errors

[33mcommit d4ccfe8da3746f808a75cb6832262aa3813c7db3[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 12 11:54:16 2017 +0200

    FIX ! finally found why low alert snooze didn't work

[33mcommit ce5354cc776aa4b9ac029bb871f6aa1212c28176[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 12 11:49:05 2017 +0200

    more tracing in alarmservice

[33mcommit 80a8cac5ce2baa2bcbeb5951232b538f65f2a725[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Aug 11 10:54:12 2017 +0200

    code clean up

[33mcommit f394bd57dba0c8ce95e4c06c4fe3ef8cfe985a09[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Aug 11 00:43:15 2017 +0200

    fix : during sensor warm up, values where shown as value 0, converted to 40 mgdl

[33mcommit 9b02213115d4ea70df931cebe167cc9f526d187d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Aug 11 00:07:28 2017 +0200

    delete blood glucose readings form database : didn't work actually, database must opened in update mode

[33mcommit d8fec2e850955bf595974540d5650ae78342fd4c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Aug 10 23:59:35 2017 +0200

    don't set missedreadingalert if sensor is not started

[33mcommit 6408248f5a3346ff10b440201aef8afd93bceea8[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 9 22:34:38 2017 +0200

    when initialscanning start for xdrip, keep application always on

[33mcommit a4bae50c228b30a9dd2d183d8c48949c7021a4be[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 9 15:57:10 2017 +0200

    version increase 1.0.1

[33mcommit 5e6d13352a00aab3c1bd8edca7326ba92c4d97d0[m
Merge: 440f0e5 332e12d
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 9 15:54:47 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 440f0e58687175840eff2897a3996ffdf624dcaf[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 9 15:17:13 2017 +0200

    increased initial scan time from 15 to 320 seconds, important for xbridge & limitter & bluereader (these last two are not yet fully tested)

[33mcommit 424a4cb787076234ae1e133d83aec833cd9a2fdb[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 9 08:47:01 2017 +0200

    graph not connected dots, with colors as in xdripplus

[33mcommit 826a07c7827b855b48253b3f9d5c36db5105bdb6[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 9 08:46:14 2017 +0200

    when changing high or low mark in settings, check if high > low

[33mcommit 332e12d7a7a6ec792be6e9f1c34e161ed4cde5eb[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Aug 8 08:13:47 2017 +0200

    Update README.md

[33mcommit 1852a42d0c786e2c59e16e9b7477777328578e82[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Aug 7 23:25:07 2017 +0200

    version increase to 1.0.0

[33mcommit 9748939ed6b4cf2b8f99e8f2109a9cd5cfce83ca[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Aug 7 23:23:47 2017 +0200

    improved calibration :
    - if user receives notification for initial calibration and then opens the app without clicking the notification, then also the dialog for calibration will be opened
    - user gets now 2 minutes to open the notification

[33mcommit d05cf96188717255fc8920a2f266f0b48ff34bc7[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Aug 6 22:35:50 2017 +0200

    Result from call to Nightscout not logged anymore in trace file, because this contains bg values. It is still visible by connecting iphone to mac, and use cfgutil, grep for iosxdripreadertrace

[33mcommit 8fc5c6f4ed391d991f5788c5748c0ffe846edd2d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Aug 6 21:50:26 2017 +0200

    delete blood glucose readings form database : needs to be done synchronous because if done asynchronous there's a risk that other thread is trying to insert the new reading synchronously, resulting in database locks, errors, crashes, missed reading alerts, bad sleep ... the good thing is that missed reading alert seems to work well

[33mcommit 3bc9468d93d20fe40ba8f929c70552c729896a7f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 5 23:51:22 2017 +0200

    delete blood glucose readings from database older than 5 days, each time a new reading is received

[33mcommit db6bd94441ee0bcb6fad075c811458a967b6174e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 5 23:09:08 2017 +0200

    fix healthkitservice, null pointer exception

[33mcommit 5efa08376c6b9809750ad8ad5a39f64c9050a490[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 5 22:55:39 2017 +0200

    code clean up

[33mcommit 1dcdba60a33f1a4abf164092e0acc3af3c17f52c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 5 22:05:14 2017 +0200

    code change : removed HM10Attributes and moved variables to BlueToothService.as

[33mcommit 9cc52201871100414491a69b9277f987c67e93a5[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 5 21:48:11 2017 +0200

    improvement missed reading alert

[33mcommit f9a1eb9d6aee16c45eca1aafe78c6bb6579675a8[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 5 15:08:35 2017 +0200

    missed reading : add 30 seconds to planned fire date and time, because sometimes the alert seems to fire even though there is a reading, probably because fire alert time is to close to bgreading time

[33mcommit fae15a8538edffc08c03d972fc248adefe2ae919[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 5 15:06:47 2017 +0200

    changed logging in AlarmService

[33mcommit 7cdddf76fad848ddcb66ff37f979acc776ccadbf[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Aug 3 12:31:50 2017 +0200

    version increase 0.0.57

[33mcommit 647fe576ee64025778b5b9d2dcaaaef306702050[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Aug 3 12:30:19 2017 +0200

    more logging for missed reading alert

[33mcommit 97925dfe91d1eeecd9ca9e2742d14e80ade50c66[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 2 23:20:40 2017 +0200

    reset battery info when changing transmitter id or transmitter type

[33mcommit 98fdf68d514b21029cb98ecbd3b5198022dd22a2[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 2 22:57:09 2017 +0200

    better status formatting in homeview, voltageA, voltageB and resistance

[33mcommit 3873f0043722e182e6946336fddbbbfb0611f9d6[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 2 22:51:00 2017 +0200

    code cleanup

[33mcommit 0f055781dd1885cda7586161551d2b4162953883[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 2 22:45:25 2017 +0200

    removed BackGroundFetchServiceEvent.LOG_INFO, not used anymore, was for logging to database, detailed tracing is now available via e-mail

[33mcommit 36b015e7e5672e15aee8216e603c0a34ebfe95e0[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 2 22:37:54 2017 +0200

    code cleanup

[33mcommit d13adc2ad4011ad936838fc8e9516c27b5f8f45f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 2 22:17:37 2017 +0200

    fix in logging

[33mcommit d8e7bcdbdf5c85a32f5077d37d547d401f5bbf25[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 2 22:14:47 2017 +0200

    if reading's calculatedvalue = 0, then don't show in graph, only applicable for newly started sensor

[33mcommit a1283a16254b6ce51e9704f948e45e58ccdd4643[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 2 22:02:46 2017 +0200

    fix for xdrip, reconnect

[33mcommit a95e53833fe7dbcf321360dd4ca1052ec221ccf3[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Aug 1 22:54:10 2017 +0200

    version increase

[33mcommit 662748188a5a4f56377ca656f63107777f9e8357[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Aug 1 22:52:26 2017 +0200

    fix in list of alert periods, in some cases value was converted to mmol where it shouldn't - also additional fix related to keyboard type

[33mcommit 20282336dd88421bb927fddc22f56e87eabff0d2[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Jul 31 23:54:00 2017 +0200

    when number is requested, shows numeric keyboard

[33mcommit 2215e44b6d476239dedc39e3518ed2b9af762d8b[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 30 23:09:31 2017 +0200

    fix related to commit 3e0260929f4ebca252d5fc1a482b08152ef375e2

[33mcommit e6ebf5ed08948b3b43c5acd95c41cba1d68e1f65[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 30 22:53:02 2017 +0200

    don't try to upload to nightscout if there's no network available

[33mcommit 73f561347d1fee8e8077daeea374dbef373a9a4d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 30 21:54:40 2017 +0200

    changed device not paired message, explain that app can be kept open by long pressing the home screen

[33mcommit a4a593e3fde94df66fedff952b65cea273952bdf[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 30 15:29:10 2017 +0200

    removed G5 status because it seems not meaningvul, voltagea, voltageb and resitance status give more info about battery

[33mcommit 3e0260929f4ebca252d5fc1a482b08152ef375e2[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 30 15:11:31 2017 +0200

    moved healthkit on/off to settings

[33mcommit 218c86d898a8e0f6ddb9238b0c99a0377617bbe5[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 29 23:56:36 2017 +0200

    version increase and fix in checkApplicationVersion

[33mcommit c6941a455231e6ce46d4752fa772d2d572c0f0b6[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Jul 28 23:54:29 2017 +0200

    changed the NSHealthUpdateUsageDescription

[33mcommit e7a862ac74fdb0f7c66ac5719c15bb5a9ee27d79[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 27 23:16:17 2017 +0200

    support healthkit

[33mcommit 2963186433f21a88e2fa128c028b4be4e337d63f[m
Merge: 47ecfa6 3b153a9
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Jul 26 22:13:55 2017 +0200

    Merge branch 'master' into healthkit

[33mcommit 3b153a9bcafa1180add371f19350306a75cc8a74[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Jul 25 23:22:19 2017 +0200

    Added link how to resign an app.

[33mcommit cebe873fb3e4486c7e44ea1802efb4dbabff8614[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Jul 25 22:50:22 2017 +0200

    the app does not always stay on anymore by default. To keep the app always on, long click on the screen till the phone vibrates.

[33mcommit 1d577e6b6c22ba624b55a02f2c018d602e55cb08[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Jul 25 00:37:14 2017 +0200

    3 options for the big part in home view : chart 6 hour, hart 24 hour, or current value in big fontsize. By clicking on it, it goes from one to the other

[33mcommit b417e9ecec8a85008e9f9388bf9efdc64e7ada10[m
Merge: ac55443 771c40e
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 23 16:06:37 2017 +0200

    merge blucon changes

[33mcommit 771c40e6898a7ef1b73378f83c6877368154175d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 23 11:19:08 2017 +0200

    added sleep command and call to processBLUCONTransmitterData

[33mcommit f6f2446e76a31dbf8d21ae77dca0599eaa1085ed[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 23 00:03:13 2017 +0200

    ported getNotificationUpdatesForCharacteristic, not tested, need now objective-c implementation for blockNumberForNowGlucoseData

[33mcommit 47ecfa61bde0ffd2ec62da01a8c16dc2ea1c9227[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 22 20:48:34 2017 +0200

    healthkit first attempt

[33mcommit ec183420f5ee3ee4f12b8108efd147efbc68482a[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 22 14:32:37 2017 +0200

    blucon ..

[33mcommit ac554434e10c3b263bdabed42d39b88650c85533[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 20 17:31:25 2017 +0200

    version increase 53

[33mcommit 9d9334592ade2874bff38662b2ed8b86f8b792bb[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 20 17:27:19 2017 +0200

    fix necessary after blucon changes

[33mcommit 471bf5c9bf80d909fe90fea71c49ecd6e5bf72d3[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 20 17:03:50 2017 +0200

    switched back from BluCon to G5, to test for BluCon, revert these changes, bluecode transmitter id = 5 digit code

[33mcommit 34ec2050aa06e7749fd56ba04fa675b7b5d07401[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 20 13:24:47 2017 +0200

    using correct udid for subscribing to characteristic desiredReceiveCharacteristicUUID

[33mcommit 038495f7559b102c3b44f6bd87ff9cc1972b0c17[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 20 12:53:07 2017 +0200

    fix check device type , blucon

[33mcommit 0f78aee1fb16c6ea1b7c38b838541523a323489e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 20 11:21:21 2017 +0200

    whenever check for isdexcomg5 also check for isblucon

[33mcommit da92c659bdddcc2e482a3fbc422b212e9548f6a0[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 20 08:31:14 2017 +0200

    scanning for blucon, (was scanning for G5)

[33mcommit ff8ba58d93606482ce32ce63ac7b834458f12882[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Jul 19 22:16:44 2017 +0200

    blucon, immediately startscanning after app launch

[33mcommit 9fc84199e00e1b3b90247750478319264752e3bc[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Jul 19 21:50:20 2017 +0200

    ..

[33mcommit 1480a4cfdb373d484d4d027f336af5413faa4652[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Jul 19 00:58:51 2017 +0200

    bluecon v1

[33mcommit a0ba6af75a1d086f84f8fbdfcd63ea6ee0364082[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Jul 18 10:15:03 2017 +0200

    improvement in chart, during sensor not active, don't add the reading, also fix in bgreading getlatestbysize, there was an exception during calibration, apparently didn't cause any problem

[33mcommit bf1d3730eb1c2cc0eea8341a494b4fd98f756f6d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Jul 17 23:05:22 2017 +0200

    click on chart to view 24-hours

[33mcommit 20ed0a0edcadfc0f2d7fa51a6bd69afbb3e33050[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 16 22:29:01 2017 +0200

    fix issue #7

[33mcommit 7705c2823d7e9f247bc19c75913630a211241332[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 16 20:32:31 2017 +0200

    removed everything related to additional calibration request (functionality was already disabled some time ago)

[33mcommit e847dcd5cd47f92f1125eda0deb0e4bb16279753[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 16 17:05:16 2017 +0200

    when changing calibration alert settings, immediately call checkCalibrationRequestAlert

[33mcommit 547115cbc5598052176fef7cbfa2d7c43c66ab9d[m
Merge: 4fdefdf f7a6fd4
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 15 23:42:53 2017 +0200

    changes to readme.md

[33mcommit 4fdefdf93639ce2bae845d4363447d9e912d3d66[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 15 23:39:05 2017 +0200

    version increase

[33mcommit 9a4f4cd3a58bd4a618db9d97a9255ab260c2a372[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 15 23:37:58 2017 +0200

    in start scanning via menu, set timer of 15 seconds, and if expiry, show message that scan failed. This was a functionality existing previously but it got disabled.

[33mcommit 542cf0b0e54fd715e23874261109633752a8b8d0[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 15 23:35:25 2017 +0200

    clean up in BluetoothService.as

[33mcommit f7a6fd499716ef95e03b754ac22d74ab6def0a97[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 15 00:26:45 2017 +0200

    Update README.md

[33mcommit 6b65e183d18f34009d015dfc8b7fc7ab83b6bf78[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 15 00:05:45 2017 +0200

    added note that it may be necessary to remove transmitter from list of paired devices in bluetooth settings

[33mcommit 94512016dfbf071fa01258b465ebab5abb6c31df[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Jul 14 23:27:09 2017 +0200

    improved missied reading alert

[33mcommit d9da3f201e6fbad3cb92e6b15b516f4771b62aaa[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Jul 14 21:47:22 2017 +0200

    pickerview closed when clicked

[33mcommit aeb511e6c603f9ca1649f15d85e0f34b0fc1dea6[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Jul 12 23:59:32 2017 +0200

    plan missed reading alert as soon as app starts up and also when missed reading alert setting is chaged

[33mcommit 849837d88f3860e45787a90a42d2d5052898f2b1[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 13 17:10:39 2017 +0200

    app to foreground different treatment, iosxdripreader.mxml now dispatches an event, backgroundfetchservice and sync listen to that event

[33mcommit eb58ebb974920d3f093c4b71eda8e6d72f6c9a0f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Jul 12 17:58:03 2017 +0200

    chart support mmol and automatic selection of max in chart (300 or 400 for mgdl)

[33mcommit b9242eb0f6ec05a02f61769a44f0e4eba8eb3b78[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Jul 12 08:43:00 2017 +0200

    fix for bluetooth connection failure, issue #6

[33mcommit bf442efdfccb73feab65ac830e0639ed366d7469[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Jul 7 23:02:00 2017 +0200

    when selecting G5 first setup, change low battery level default alert to 300 (it was 210 assuming xdrip with G4) would be used

[33mcommit 260733989ac3d3de633a21bedf3975bf69b1858a[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Jul 7 23:01:22 2017 +0200

    no low battery alert level check if no info received yet

[33mcommit b651c304d011660273b96eb508852080fc765d72[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 6 21:59:41 2017 +0200

    First version chart, 6 hours are shown

[33mcommit 5cd106dffe7d420678ad666a98e90cf72476b3ce[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 2 23:28:03 2017 +0200

    charts v1

[33mcommit 1d96709f10811cbf8ca8dbefa73d8908e13296e2[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Jul 4 00:02:35 2017 +0200

    version check should also support versions lower than 0.0.46

[33mcommit 7754c9c2a03cd3570c3ac359adcbe8e1df30cddb[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Jul 3 23:33:47 2017 +0200

    lastAlarmCheckTimeStamp initialized during initial startup, otherwise it never checked alarms as long as there was no bluetooth connection made

[33mcommit 595d2441b547a3a3bbc1b13e81032dd2b449ca2e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 2 23:39:35 2017 +0200

    snoozing for very high alert was missing

[33mcommit 555854e51b9dd5ffe4ac268199d825b2b0cfb130[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 2 23:15:46 2017 +0200

    fix for silent alert and alert with default ios sound

[33mcommit c342bc5df50883a942706734b8a0982bcff15da3[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 2 00:15:34 2017 +0200

    very high and very low alert

[33mcommit 04e7a064e61fcd0eb20e9e2834e6834553189551[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 1 22:55:18 2017 +0200

    solve merge conflict

[33mcommit ba1348f92203a57b03feb6d92fe5c54a8bc29e38[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 1 22:48:23 2017 +0200

    solve merge conflict

[33mcommit ba1fb3f6870a5e4cfc5546218a2b2732fab7e38e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 1 22:45:08 2017 +0200

    fix merge conflict

[33mcommit 09c3dd22a972896d26d95f3e85c34c28ced76574[m
Merge: b723abd 5d82a71
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 1 22:37:23 2017 +0200

    fix merge conflict

[33mcommit 5d82a7118dccdf1e2afe5e508a85caa569b5550d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 1 22:05:21 2017 +0200

    now using Apache Flex 4.16.0 AIR25.0

[33mcommit 72d91924d3e9ce94b50d86333ea14f657bfeed62[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 1 22:04:08 2017 +0200

    when clicking calibration request notification, now the app opens with dialog which allows calibration, and in action sheet an option to snooze

[33mcommit 3de3600cb8c27313d024ff0a4236e50f84f0e057[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 1 21:31:19 2017 +0200

    Increased hight of chapter titles in settings

[33mcommit b723abdd2679c94ef9a1f1a98311e89ee03a2c01[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Jun 30 23:44:56 2017 +0200

    removed additional calibration request

[33mcommit d8a5cc5f5c6675bdd0850bf6333b55d2cdaf59cf[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 29 00:24:06 2017 +0200

    improvement alarm snoozing

[33mcommit d6646faab80af6b0db0bd3403e230a14f62737de[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 29 00:24:06 2017 +0200

    adding version in settings
    
    improvement alarm snoozing

[33mcommit 6870fb81890090c477f954b40f32c0d8e8af0854[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jun 25 17:19:50 2017 +0200

    code rearrengement, checkAlarms split up in several functions, per type of alert

[33mcommit b7de29d22fcdbb2e520495ab9b5a182a9439e615[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jun 24 12:56:17 2017 +0200

    text for calibration request changed to 'calibration needed'. iOS doesn't take a title and a text, just a text

[33mcommit 806b1ff4305f3e836e110cabce45e1fdcc171e2b[m
Merge: 74807a7 ed51369
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Jun 23 23:33:30 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 74807a7028dc9799b4f9497b23a75e1d707bdd24[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Jun 23 23:33:21 2017 +0200

    calibration alert and fix for silent/non-vibrating alert which is not really silent, actually previous release i forgot to add the changes

[33mcommit ed5136967a69152d1bda010729fb1d38d7dbc93b[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 22 23:07:02 2017 +0200

    Update README.md

[33mcommit 434c9ed6ab7550a2f7b5c513901d34a972d1492c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Jun 19 20:50:07 2017 +0200

    important Nightscout upload improvement, upload will happen immediately after receiving a reading

[33mcommit a326872b78f0ad81794e42d64eeb98d0a338e149[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Jun 19 20:05:56 2017 +0200

    removed unused function and added logging for peripheral_characteristic_subscribeErrorHandler

[33mcommit 0813f12062f298c693d7b6920e7c0b85f123563e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 15 00:25:47 2017 +0200

    - maximum 3 seconds wait for nightscoutupload, if longer then completionhandler with nodata is called.
    This to handle situations where for instance NightScout is down or slow and the upload takes too long (before the timer was 25 seconds). My impression is that in such case iOS is not happy and the next day(s) it does not wake up the app when remote notifications are received, because iOS assumes there's too much battery  consumption.
    - xdrip/xbridge : after bluetooth disconnect, wait 10 seconds before restart scanning, as is the case for G5. This could have been solved in another way because there's not really a need to wait 10 seconds (as for G5)
    
    - needs ANE-Backgroundfetch version 0.0.42

[33mcommit c2fb1dd290811e2b4319644895d482455522e48e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jun 10 11:12:18 2017 +0200

    low battery level alert

[33mcommit 4007d496b26cbdecbff4bc1a786657bfd73fce16[m
Merge: 23996ac f6b3613
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Jun 6 21:45:16 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 23996ac210ded6bb8c6af92795c9173f5deb5fb2[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Jun 6 21:37:25 2017 +0200

    g4 battery level small adaptations

[33mcommit f8c385d79d4054b05e5fc6e4883763fd7cdf1c57[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Jun 5 22:47:37 2017 +0200

    fix tracing

[33mcommit 2edb9ae74bd59f4314d94f30bb7d3a2c714baa57[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Jun 5 22:47:24 2017 +0200

    Status in homescreen shows voltagea, voltageb, resistance

[33mcommit f0e222e1809498131098e42ce2e168fc3bb7cdf2[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Jun 5 17:04:27 2017 +0200

    change to trace trying to fix problem that sometimes log to file stops, not completely solved

[33mcommit f6b36130bd7de692358b38629970d64969c26f1b[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Jun 5 00:18:36 2017 +0200

    Update README.md

[33mcommit 2a9dd7a6c3b01fc51bb062187a1c47a90635fe4e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Jun 5 00:05:35 2017 +0200

    phone muted alert, some other fixes

[33mcommit d0116b93627c9323a2c0fb7e0f8dcf4fccc695a8[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 1 22:37:23 2017 +0200

    temp commit, for alarm phone muted

[33mcommit 04fdadcc0a412132d021601cdc78c132d137bc7b[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed May 31 17:46:55 2017 +0200

    if no readings for more than 15 minutes, then no more high or low alert

[33mcommit 94f91a7c6ee36d1003ec393f54df83f9f4c0181d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue May 30 21:54:18 2017 +0200

    version increase

[33mcommit 21658cf91a76be451101eca7f12bf4f4c79dc673[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue May 30 00:22:27 2017 +0200

    important fix for nightscout upload

[33mcommit 3dce080964920e8e537f8674e2de0f7c2c087f13[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun May 28 23:57:35 2017 +0200

    when opening missed reading alerts in settings, warning is given to explalin that internet should be always on

[33mcommit 32a2f84ad37d3591590b97416da2fb0ff4278f42[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun May 28 23:42:03 2017 +0200

    fix, type error in reading bgreadings from database during startup, this caused wrong valueslope immediate after launch of the app

[33mcommit 0d19a9420555f56ba21f65d6c00c5befd30902b4[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun May 28 23:33:05 2017 +0200

    fix, in snooze missed reading, re-fire alertType only if it existed, this may not be the case for instance if the app stopped

[33mcommit 81327282b7a3ef0f2d47410cb3cd4a7bce2a6733[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun May 28 23:31:35 2017 +0200

    removed timerservice, not needed because missedreading is checked via remote notification

[33mcommit f6d16f30a9ffe891276e264ce2e878a3b536a9cc[m
Merge: 156dc6d 0cc830f
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat May 27 23:00:38 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 156dc6dc8bb02785fa57560b9e14cc6a103f63d1[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat May 27 23:00:32 2017 +0200

    high alerts and missed reading alerts

[33mcommit 0cc830fbb68207c7e5ebfe6c77bada2ed65bcaf6[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat May 27 21:06:34 2017 +0200

    Update README.md

[33mcommit 39dd940a604cae49369897ccfad37e4df6e36c43[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue May 23 00:05:36 2017 +0200

    temp commit, missed reading alerts

[33mcommit 62b7bbfcb90516491898b37ed74ddd3588830835[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon May 15 08:47:15 2017 +0200

    start missed reading alert

[33mcommit 3f0be3d69a0872637fe71f8d074ee0a5c3bc7f67[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun May 14 23:02:45 2017 +0200

    canceling the notification if bg reading is ok, even if the notification does not exist, this for high and low

[33mcommit 82597e28dca7aae1bb9fa108c633f565da6eca65[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun May 14 22:53:09 2017 +0200

    high alert

[33mcommit 80215a5e5af02a050822ae968dff106da719a319[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun May 14 19:56:36 2017 +0200

    start high alert

[33mcommit c5a3b63c3858b2dc6b7fef55228746582dbf0767[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat May 13 22:31:36 2017 +0200

    low alert

[33mcommit 42359c84661094efead0ccb7a8ecec8045f63c79[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat May 13 10:00:10 2017 +0200

    temp commit starting with alarms

[33mcommit 33b38e68fbd3cd156e16c407ea01d5492d835460[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat May 13 00:05:09 2017 +0200

    temp commit starting with alarms

[33mcommit 20a7453ef1e5addaf0168682416e9821820cace6[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri May 12 23:50:36 2017 +0200

    temp commit starting with alarms

[33mcommit 09368e16fcd38f2c603e0a6764e98d655cfdd7d9[m
Merge: 7e2e3e6 db62077
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri May 12 21:50:26 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit db620776f6cf6e771064e40e509c4358f7b54bfc[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri May 12 21:48:15 2017 +0200

    Update README.md

[33mcommit 7e2e3e67dd047aefe0010e7e3114a477feeb98a0[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri May 12 20:00:18 2017 +0200

    temp commit starting with alarms

[33mcommit acb93bb83c400529e5f7933aff83112063ad3295[m
Merge: 0992d59 b2dc86e
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed May 10 13:15:18 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 0992d596676cee732d292e6d3657e4cc7352fe3b[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed May 10 13:07:36 2017 +0200

    temp commit starting with alarms

[33mcommit 4c3850ed5089286f16d4092813a4f62c20b81f7f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon May 1 20:57:42 2017 +0200

     temp commit starting with alarms

[33mcommit b2dc86ee85bbc194af2e783cb7371250554b8677[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon May 1 20:31:57 2017 +0200

    Update README.md

[33mcommit 78378efa37b54cb0bd6f8fbd76e597478cdc6d0d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon May 1 20:30:15 2017 +0200

    Update README.md

[33mcommit 217ab73734a9b5f7394715d4da0c0e91de219b25[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Apr 30 23:52:50 2017 +0200

     temp commit starting with alarms

[33mcommit a09af536f75d0ccc5e2e838a6641c6afa9e77510[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Apr 29 16:44:21 2017 +0200

    temp commit starting with alarms

[33mcommit d289cc6255ba0da1df4b00372b69277899a6519d[m
Merge: 9e54585 1c117f2
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Apr 24 22:50:17 2017 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 9e54585dcc4f8bdbc33cc234e1edda9bc9ffb6c4[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Apr 24 22:50:09 2017 +0200

    temp commit starting with alarms

[33mcommit e0cb7a36c0dd0c423e59bb34c4a0719e602af909[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Apr 24 20:47:14 2017 +0200

    temp commit starting with alarms

[33mcommit 1c117f29e2c479867189a69336a6dcddbdfe97be[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Apr 24 20:31:18 2017 +0200

    Update README.md

[33mcommit ba878489fecb1a368af5137ace410ec05bedc24b[m
Merge: ad1faa0 fe56a80
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Apr 24 20:25:11 2017 +0200

    Merge branch 'openaps'

[33mcommit ad1faa06467d98cb7a2c053b9c33f696fa504a30[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Apr 23 21:33:35 2017 +0200

    temp commit starting with alarms

[33mcommit 14ad4e8c79c38f954ee6d18c198bd80d481c0b3a[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Apr 23 20:42:59 2017 +0200

    temp commit starting with alarms

[33mcommit fe56a80010d17b9ac60428822795109c892dc13d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Apr 21 16:54:57 2017 +0200

    if nightscouturl not starting with http, add https://

[33mcommit 59247eb6e154eecf7017ec7f0375fd393b6c37a9[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Apr 19 23:01:02 2017 +0200

    temp commit starting with alarms

[33mcommit 263877c95c9f2053ac773a040f3f6a8e25bfefbc[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Apr 14 23:33:44 2017 +0200

    temp commit starting with alarms

[33mcommit a6c5943a7cc509b4ddf9ea24f3a2b067e5644f12[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Apr 13 20:16:10 2017 +0200

    temp commit starting with alarms

[33mcommit 4065015762a63edda4c07336408ec44e83555d32[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Apr 4 13:30:41 2017 +0200

    disable local fetch, it seems to interfere with remote fetch

[33mcommit 40e17f02160ff0b99d7a327885319f6779281084[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Apr 4 13:23:49 2017 +0200

    temp commit starting with alarms

[33mcommit 157fc36e442a1da2a6ba0bf93b62dd34fffbb08e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Apr 2 22:01:04 2017 +0200

    temp commit starting with alarms

[33mcommit f82b316b989247fc331083ae134951ab19f39b81[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Apr 1 17:27:20 2017 +0200

    temp commit starting with alarms

[33mcommit b418b9ce96a5146f4d5c29d52815f520c6aa0f5c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Mar 24 21:50:04 2017 +0100

    reenabled localfetch, split local and remote fetch, fix in subscription quickblox, changed tracing, use backgroundfetch ane that solves 997 error

[33mcommit e9db19b0b9e82ae9ad43bb9d7237331dbfc8582a[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Mar 21 23:00:35 2017 +0100

    Update README.md

[33mcommit 029a0aea5bebb4c890836e391988d9453f05de1b[m
Merge: d69895a 26a9d08
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Mar 21 22:52:05 2017 +0100

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit d69895aa1dfe797b5cdf420c359fee3005d3b1df[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Mar 21 22:51:57 2017 +0100

    pairing G5

[33mcommit 26a9d08294e16862600dc9c241d5a8a98e3cf2fc[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Mar 17 21:54:31 2017 +0100

    Update README.md

[33mcommit ef943f5a5f0e7d3f9bd13360d498668fc464f6f4[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Mar 17 19:41:01 2017 +0100

    bluetooth reconnect xdrip/xbridge fixed

[33mcommit fd9a0bc09204ccb327cd601f0263967ce13d2960[m
Merge: c5d592f 39f2b2b
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Mar 15 23:51:05 2017 +0100

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit c5d592f6c9661cca9b39e92cb1369b401527b051[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Mar 15 23:50:07 2017 +0100

    reduced logging

[33mcommit 39f2b2b20b0f9c8e4816245b8cee95e380139444[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Mar 15 00:12:05 2017 +0100

    Update README.md

[33mcommit 55c80018e1945857dd50cb97b8cd3c8e6a17e58e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Mar 15 00:02:03 2017 +0100

    G5 working stable

[33mcommit 638d0acf445b8f33c225be535c2ab5ced2da5375[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Mar 11 18:41:05 2017 +0100

    stable bluetooth setup, needs internet always on

[33mcommit 8567e1e4ce5995cca06d1e9bdf5b0d35b828f995[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Mar 7 22:20:52 2017 +0100

    stable bluetooth connection g5 for almost 2 hours, so far so good

[33mcommit 2bbe19e8a091358738ea0d91da2e7165858d0419[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Mar 2 22:33:29 2017 +0100

    fix G5 battery storage

[33mcommit c688fae534e69ff1736033f23185cf8becca3e05[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Feb 28 23:29:49 2017 +0100

    first bgreading received successfully

[33mcommit bd4fdbc187861be556fb161a582fd020f16a151f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Feb 26 22:55:22 2017 +0100

    G5 second draft

[33mcommit 41c0c4726243af0b100e6a38d9f53a73aa717fb5[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Feb 26 16:07:01 2017 +0100

    G5 first draft

[33mcommit df2f86ad10e21a8892c50f6670c985606597e70d[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Feb 9 21:31:12 2017 +0100

    chart, very draft

[33mcommit b99ba4573898a65fbd32ea9e6236d801f492193e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Feb 4 21:13:34 2017 +0100

    ANE trace messages are also written to file

[33mcommit 7fd2afb55a3641bae4587826a4b500301f92588e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Feb 4 21:13:13 2017 +0100

    temp removed chart in HomeView

[33mcommit 640645778984c0527288c52d4dd1e812d901513e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Feb 4 21:12:46 2017 +0100

    to make stuff compile on new computer

[33mcommit d7808d2296e6d0ff767434f7175eea670c265bd2[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Jan 31 21:23:15 2017 +0100

    starting graphical representation

[33mcommit b84876a492cc4821afdab57f0bc45315aaf97218[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Fri Jan 27 21:16:10 2017 +0100

    small change bluetooth reconnection

[33mcommit cab3f9b20758b1c7ce0bcbf6ed6a7a1153a5b5ba[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Thu Jan 26 23:31:35 2017 +0100

    reconnect improved, but still not perfect, will stop here with reconnect problem

[33mcommit e55447da2595661a7bafa1f2b9232bb2a9e419aa[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Thu Jan 26 00:19:33 2017 +0100

    temp commit, trying to improve reconnect

[33mcommit 31bea583f53cd850ebae1deb813abe27461b6c8e[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Fri Jan 20 23:20:54 2017 +0100

    for release

[33mcommit 72881fdf11e7e8a62f1bc943f26b13ba6bca8d4b[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Fri Jan 20 23:08:15 2017 +0100

    for release

[33mcommit a403970a0b2ab8965ed44f5e846717d372857ee7[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Thu Jan 19 23:01:00 2017 +0100

    ..

[33mcommit 93491cec43b13d634713eb877ef6d51e91fe0779[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Thu Jan 19 00:10:38 2017 +0100

    healthkit 1st draft

[33mcommit ccf81ba8857904a80f8db6cde9488073de20deff[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Sun Jan 15 22:08:39 2017 +0100

    Naamloos.rtf

[33mcommit 27c8af1123d99d47e2004c9d72d2ebd63f541b0a[m
Author: Jozefien Degraeve <jozefiendegraeve@MacBook-Pro-van-Jozefien.local>
Date:   Sat Jan 14 12:58:35 2017 +0100

    tracing works

[33mcommit ba500421276f1c20dc9d88286457925ff4c610ea[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Thu Jan 12 20:57:29 2017 +0100

    added LIMITIX as allowed name for peripheral

[33mcommit 255cd19bbc562837258db3b4227b0635283fbb89[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Wed Jan 11 23:25:21 2017 +0100

    back to bluetoothservice without the retry at performfetch event

[33mcommit fd52b363477fdc3c11332f1af10393df3fb278f3[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Jan 10 23:51:47 2017 +0100

    changed tracingé

[33mcommit 74ccffedfb3789ff0154352bda6b145d5a84c802[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Jan 10 21:50:34 2017 +0100

    tracing

[33mcommit 864b99f58e670456bc1ddd8a53458957be1cbbc5[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Jan 10 08:49:02 2017 +0100

    more tracing via e-mail

[33mcommit d243e78165e94b7c8d4981aefd349d52ad078a9f[m
Merge: a459f57 3936848
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Sun Jan 8 00:40:54 2017 +0100

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit a459f576ff4c0c3159528d9a2607ebc4b60c580d[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Sun Jan 8 00:40:13 2017 +0100

    for release

[33mcommit 39368485d6c082908018873d0e11f13421c42db9[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jan 7 23:48:33 2017 +0100

    Update README.md

[33mcommit 200025b54c84fa574c2629f1ecec5e31e5aac69c[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jan 7 23:47:40 2017 +0100

    Update README.md

[33mcommit 5d70b76ecaa4615bbd60fd404d6002098aed5fa1[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jan 7 23:45:56 2017 +0100

    Update README.md

[33mcommit d9c9d84ab34f2018e05b546599d054ab0647f1b9[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Jan 7 22:40:25 2017 +0100

    Update README.md

[33mcommit ad26953bbf6e8d335a831599ca889ac3cdc87e62[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Sat Jan 7 00:15:25 2017 +0100

    bluetooth connectivity status is added in the body of the always on notification

[33mcommit 463b7591a02815c8698f0fd8978f29cf6fb65e1c[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Fri Jan 6 23:47:18 2017 +0100

    bluetoothreconnect every 5 minutes

[33mcommit e6c888922dcaca0d34646857a8d57475e44695ff[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Fri Jan 6 17:45:51 2017 +0100

    will try something completely different

[33mcommit f290d28ccd4bf22e03d4cfaee66c41dab629a539[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Wed Jan 4 00:12:37 2017 +0100

    again

[33mcommit 87917e710d5ff2b9179aae3b9125a73b8b4e7301[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Jan 3 23:43:44 2017 +0100

    small improvements, still under test

[33mcommit 278da04db8a8d2d5fd3b5a1a90453ba28cc73be0[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Jan 2 18:06:15 2017 +0100

    small improvements

[33mcommit 0c42dd4106fa73802d079f332ebc76bc762cf4a7[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Sun Jan 1 23:41:02 2017 +0100

    when receiving performfetch and device not connected take the opportunity to try to reconnect

[33mcommit 7ee89cd19a225aeb57c36c1373b3c358b0da0fcb[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Sun Jan 1 13:38:50 2017 +0100

    version 0.0.20 aligned with pushnotification and backgroundfetch ane

[33mcommit 3418138166941b860b74369cacfea8476558c37c[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Sun Jan 1 13:28:38 2017 +0100

    working with pushnotification

[33mcommit 9644c2e058429460f2561e433ee7b5a66661df5d[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Fri Dec 30 13:03:09 2016 +0100

    add tag list

[33mcommit 947626a076c605a05293cbf28841341631d836b3[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Thu Dec 29 23:08:41 2016 +0100

    removed the pushnotification app to a seperate repository

[33mcommit 8677b643383093fab00683b6147edb60d0e50824[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Wed Dec 28 18:53:26 2016 +0100

    .;

[33mcommit 75df75ec811b1594cf4b6c10c72d1b3ce5b2f546[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Dec 27 23:04:47 2016 +0100

    pushnotification app for ios, not tested

[33mcommit 0307b98756b4efcc37a8f84ee6fa28407e02c63f[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Dec 27 00:16:14 2016 +0100

    quickblox register and subscribe for remote notification, as soon as nightscout url and secret are set up

[33mcommit bea6681912d37d14464987ba24b911c2b831d62d[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Mon Dec 26 12:27:45 2016 +0100

    error form quickblox being logged

[33mcommit ebf13ba49c17d6aae25f8a384fc0cf6a79f2e364[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Mon Dec 26 00:56:25 2016 +0100

    quickblox .

[33mcommit 82201776bcff88023e9b9a7ca5fedf1d03276a79[m
Author: Jozefien Degraeve <jozefiendegraeve@MacBook-Pro-van-Jozefien.local>
Date:   Sun Dec 25 19:21:34 2016 +0100

    fix, no insertlogging should be done if it doesn't exist yet

[33mcommit bd18f65b9ad99087f405cf14417a88946ca6cb0e[m
Merge: d32495d d51b96d
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Sun Dec 25 14:30:08 2016 +0100

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit d32495dd5f232480a0bfb048f2c404a7e52eeae3[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Sun Dec 25 14:14:16 2016 +0100

    configured to support remote notification, also receive device token

[33mcommit d51b96d1291502ebc62cd3955c5eab2826df32e3[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 21 17:28:31 2016 +0100

    Update README.md

[33mcommit de9996a890fcfffa1197172b3845e4d14a1055b3[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 21 17:28:18 2016 +0100

    Update README.md

[33mcommit 1ee1339e6d99601d9744a1c49d2e009f7ed542d4[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 21 17:27:41 2016 +0100

    Update README.md

[33mcommit 72eb754a1e6a1d7db88324235c15ceadc7e151e0[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Dec 21 08:24:30 2016 +0100

    Update README.md

[33mcommit 8130bb552c31650f551434514c1f6e55de77ea16[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 19 23:39:23 2016 +0100

    Update README.md

[33mcommit d89c3f6d2eddb22fe2a196bba720cb099d4657df[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 18 21:18:41 2016 +0100

    final fixes

[33mcommit ba4d72747cd7aa9af149dadee5ddf31a203ce208[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 18 15:58:42 2016 +0100

    finished

[33mcommit f2fbce8278b707a2198588a41ef70697c7b277f8[m
Merge: 2ec6129 c8bb79a
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 16 23:19:17 2016 +0100

    Merge branch 'master' into improve-transmitter-service

[33mcommit c8bb79a28a1e4f78fba4ac87b3dae5ef2de88143[m
Merge: a6c19f8 c4e2cc9
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Fri Dec 16 23:17:39 2016 +0100

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit a6c19f84658399738feb60644b46448d9cb583cd[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Fri Dec 16 23:17:31 2016 +0100

    fix for sensor start, was failing if done between 00:00:00 and 01:00:00 in the morning

[33mcommit c4e2cc924acecb238aaa64ef88c237837a332646[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 16 00:03:16 2016 +0100

    Update README.md

[33mcommit 768ef01a07fcc6b52e3c26f7f7f1ddce2774f7a5[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Thu Dec 15 00:23:42 2016 +0100

    small changes related to tracing

[33mcommit 2ec612950b05d94f8b22fdddca1962ec725c061c[m
Merge: 4e3c39c 614a262
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Dec 13 21:51:11 2016 +0100

    Merge branch 'master' into improve-transmitter-service

[33mcommit 614a262fbaf09025e42cb180d4e67bd2aafc01f2[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Dec 13 21:50:49 2016 +0100

    if app not started last 5 days then stop the sensor

[33mcommit dc21e618751be50b379d1f19941005f6c0ac473b[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Dec 13 21:43:39 2016 +0100

    fix in calculating age of bgreading while starting up

[33mcommit 4e3c39c9dad42f7bfc1b8d0498f61063ef3d73aa[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 12 23:14:50 2016 +0100

    temp, still notification to add in case transmitter id needs to be updated and also check with clean xdrip/xbridge

[33mcommit 99867ca03e96e96e9ffd50cd3da50e7963cff78c[m
Merge: eb71ae7 585ce6e
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 12 21:43:58 2016 +0100

    Merge branch 'master' into improve-transmitter-service

[33mcommit eb71ae7d81880bcba038857c8c6ff5d6cd242a4f[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Dec 12 21:28:34 2016 +0100

    temp

[33mcommit 585ce6e4a64d137628f02cca87c09b05b4092dc0[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 11 23:15:42 2016 +0100

    reading notification not showing up if app is in foreground

[33mcommit 51e0d3e0eacf94c7572d5d8452cf6f3135d680f0[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 11 23:14:33 2016 +0100

    temp

[33mcommit f1a06b09f5f078e5b77813ca595df8d70d2a079b[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Dec 11 12:37:26 2016 +0100

    temp

[33mcommit 2248f10cd64b320abb668e4ff1caa06d5e706870[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Dec 10 22:30:14 2016 +0100

    temp

[33mcommit a43159c1642b82aabb735a1991635c6a4a9f5541[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Dec 6 22:54:47 2016 +0100

    - reduced a bit the calls to completionhandler in nightscoutservice, assuming this was causing problems
    - in modellocator adding log in database when app goes to fore or background

[33mcommit 68780c5a2c558070a58b8ffda018e9d187fedcbb[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Sun Dec 4 08:32:00 2016 +0100

    moved init of backgroundfetchservice

[33mcommit 61f810fbbc41555bb36a07cf89f6737fab8ff415[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Dec 2 17:22:52 2016 +0100

    always on notification can be enabled or disabled via settings

[33mcommit e1abd29042f2d74d54524a4ab593814d181e0f46[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Nov 30 00:16:03 2016 +0100

    LimiTTer also used in menu

[33mcommit 3b626e2e088df9c67bef307edfc0dbaa9fbe2dc2[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Wed Nov 30 00:02:45 2016 +0100

    added bluetoothlogging, for limitter

[33mcommit 8a04b5e4e96592dd6cc7462306d7840e19e13db5[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Nov 29 23:58:06 2016 +0100

    version to 0.0.11

[33mcommit 583f90f2fbe669d3c17ebf025ac33b2e71655c9f[m
Merge: 6ff6ac9 18002a4
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Nov 29 23:57:37 2016 +0100

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 6ff6ac90f18d603a6863458b165ae1a5c4744112[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Nov 29 23:57:17 2016 +0100

    fix body text mandatory for notifications in ios10, version to 0.0.10

[33mcommit 18002a479c0c6c031e00ccffb0a62d0f590dc8ae[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 29 23:24:40 2016 +0100

    Update README.md

[33mcommit 62c731d65eafadc20db2af0002184ee6ecaad9c4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 29 22:59:35 2016 +0100

    fix for perform fetch to as and additional text changes for limitter

[33mcommit 88d9a1fb9b12ec1c9c1042a54fcd6245104c1be5[m
Merge: 731c93b 54af912
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Nov 29 08:50:26 2016 +0100

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 731c93b7a8cdf9d294304e29eefd74a2e2c95db5[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Tue Nov 29 08:50:22 2016 +0100

    needed to avoid exceptions

[33mcommit 54af91270b49d5ce10215d9072d1f320d5500285[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 29 08:49:02 2016 +0100

    more logging

[33mcommit 5c8c7eeee255320b4b8d7890fde28b4aac958a7d[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 29 01:05:08 2016 +0100

    nightscout service and performfetchservice ok

[33mcommit e099e04b76ff12dc4e3fdb2615df0751ee53cf42[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 29 00:47:53 2016 +0100

    uncommented calls to completionhandler in nightscoutservice and from within backgroundfetchservice, now always calling as soon as error or success received from ane

[33mcommit a85b9b4c5c8984969ce0d68223315d3d7ca17579[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 29 00:29:17 2016 +0100

    support limitter

[33mcommit 5e6cb4fdb057189a5e67c080848f9ec66c528a20[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Mon Nov 28 23:09:40 2016 +0100

    ..

[33mcommit 0631eee3ebdadbebb617d0e287f671dbe8ffaa16[m
Merge: 6f75e79 0dbe18d
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 27 16:29:02 2016 +0100

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 6f75e79f8b54a0698897c47834a45fdbb0b5913a[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 27 16:27:50 2016 +0100

    ..

[33mcommit 0dbe18d25092041ef4ae9d9470a26c36f05943d1[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 27 14:51:46 2016 +0100

    Update README.md

[33mcommit 134857d60f43dcaa1412116e884f8754f31eb6be[m
Merge: 2cb5a31 d3eb90f
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 26 23:16:36 2016 +0100

    Merge branch 'master' into redesignbackgroundfetchservice

[33mcommit d3eb90f298ee324a38c53f1509657ae87d5d223d[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 26 23:16:28 2016 +0100

    temp

[33mcommit 2cb5a3136156d5413660d6e35d6dc7f4ac00a7db[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 26 23:11:07 2016 +0100

    temp

[33mcommit 1e270afcd36a199e79f4bd81b9e0c0eda32d87cf[m
Merge: f14913e 6d340e3
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 26 23:07:16 2016 +0100

    Merge branch 'master' into redesignbackgroundfetchservice

[33mcommit 6d340e3bec54bd30a17ba3f8db6d4b5a1892d780[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 26 23:06:42 2016 +0100

    temp

[33mcommit f14913eab431e020c0183181b1c88aa4e8b3f261[m
Merge: 68f2666 813dbee
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 26 23:04:08 2016 +0100

    Merge branch 'master' into redesignbackgroundfetchservice

[33mcommit 813dbee3ede067ea9fd1cf5d2b36091e39bb2c77[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 26 23:03:52 2016 +0100

    temp

[33mcommit 68f26665d9f9e57f440cf058304034150c5f9f06[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 26 22:46:36 2016 +0100

    temp

[33mcommit b5f0d2c1ce2ede8aefd4bed49f7897f5d0dc9135[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 26 22:44:58 2016 +0100

    temp

[33mcommit f83abd77eb59bfa2ccd5c680ee7f6aba15c73d87[m
Author: Jozefien Degraeve <jozefiendegraeve@MBPvanJozefien.lan>
Date:   Sat Nov 26 21:48:01 2016 +0100

    continued with status field

[33mcommit 452490feaa3544c853be2418570e0664b73acbe4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 26 12:14:57 2016 +0100

    temp

[33mcommit fc97d28a0a5bd4b1d3f4d7da730877b9ba43bb2f[m
Merge: d230a1d 959fe07
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 24 20:40:01 2016 +0100

    works with perform-fetch-as de5168514f5b9eb0ffc2a7ef9eb335def9c79b12

[33mcommit d230a1d90008085bd3c8d9d3d39727c6fd24a8cc[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 22 23:44:41 2016 +0100

    temp commit

[33mcommit e2820a0f98bc8dc63a61ef6fccd5f327e95078b6[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Nov 21 11:31:06 2016 +0100

    Update README.md

[33mcommit eb63b437f6c9edb97b80f91ed61e588617df3a86[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 20 21:27:00 2016 +0100

    Update README.md

[33mcommit 7c1c4e30ffa0c9caa7cd81a85089a2ff8cfde234[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 20 18:24:10 2016 +0100

    Update README.md

[33mcommit 4e7ad2314e2f4f0cb48454b2a5bbb636c3924056[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 20 17:35:18 2016 +0100

    Upload to Nightscout works.
    
    Some additional changes.
    
    ..

[33mcommit 70450dfe1876720d59f2a410e45b108d96cb1ffe[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 20 17:32:09 2016 +0100

    Update README.md

[33mcommit 959fe07c21db0e4e235c4f6a1d62c55ebc24740c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Nov 24 01:17:37 2016 +0100

    small changes

[33mcommit c361bc4ed115fd91cc5af421dfdeef6a183758c4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Nov 22 23:44:41 2016 +0100

    temp commit

[33mcommit 90416f0a4ec6da6e9d2e08fab8c8e18c2b1ae683[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Mon Nov 21 11:31:06 2016 +0100

    Update README.md

[33mcommit 3ff4f0c17f62e49342c21724cc357796c029b0fe[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 20 21:27:00 2016 +0100

    Update README.md

[33mcommit 53aa036a9daebbcc65ca1db7d5ef23e914890310[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 20 18:24:10 2016 +0100

    Update README.md

[33mcommit 87b1f0eab7c159189d73b6e5786a62c30f5a2e99[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 20 17:35:18 2016 +0100

    Upload to Nightscout works.
    
    Some additional changes.

[33mcommit 987d73d815392d6f588439c40adfa3e116e2e98e[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 20 17:32:09 2016 +0100

    Update README.md

[33mcommit 2277652ccc3ee86344f133103897c0080a7ff362[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Nov 13 16:46:25 2016 +0100

    nightscout url check not done if sync running

[33mcommit b23fe6f628994539468479182d505efa43f7e803[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 12 23:15:27 2016 +0100

    Update README.md

[33mcommit 3a55f3616e1df38756235c6d7e8869b216681591[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Nov 12 23:06:26 2016 +0100

    aligned with the push on the ANE-BackgroundFetch just done, not sure if background fetch is working

[33mcommit 9b91bb724c07d4d59d6d2bfa7decd5efc99811a5[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Nov 7 22:36:40 2016 +0100

    commit before doing a complete change to make things work, also latest commit of ANE will get complete change

[33mcommit 5494fb2332348a4b711e084f7a375aaa93a296bc[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Oct 24 22:45:37 2016 +0200

    added timer that will call completionhandler if no answer on time from nightscoutservice

[33mcommit ec4ab8207b2c58ccdc938812d8d9b3d6019ea5ef[m
Merge: f2c160e 7109823
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 23 23:20:22 2016 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit f2c160eb7fe5ec519baeb300403e06356f07bcf4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 23 23:17:24 2016 +0200

    working version

[33mcommit b55a167623e9f9235affef4ea648915d5385e477[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Oct 18 22:01:16 2016 +0200

    BackGroundFetchInterval ane included, but this is not working yet, use is commented out

[33mcommit 7109823ad5999076b910ce34e704a4f55e2887fe[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Oct 12 14:39:17 2016 +0200

    Update README.md

[33mcommit c64a02a9d53a3ddf21757c359e6e571da20b1f35[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 8 20:55:42 2016 +0200

    version 0.0.6

[33mcommit 8b4c405028b8836fc34427e7cd06ed208770dc3f[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Oct 3 23:27:44 2016 +0200

    fix, if start of sensor < 2 hours ago then don't ask for calibration

[33mcommit 5dde20853104f317f87469014c798ae19f5526cd[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 2 23:05:00 2016 +0200

    version 0.0.5

[33mcommit 92aeadbf8986ad9f051fabb2ee2f2d322ed9cda3[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 2 23:03:36 2016 +0200

    one more correction

[33mcommit 0c9d4180a5a1cee0cff0841d7b2cdbbf6e79003c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 2 22:59:52 2016 +0200

    more corrections

[33mcommit cf515ad6292be1810dcc4e01c3631683a14512b9[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Oct 2 18:27:55 2016 +0200

    upgraded to air 23 and fixed check for isnetworkreachable

[33mcommit 0adc9355c29f816caf15f589c7b9892011b56dce[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 1 23:18:01 2016 +0200

    fix, dialog for additional calibration request alert

[33mcommit 03c7e8048dc3ab1c892370bffc68553a622def44[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 1 21:37:36 2016 +0200

    setting to enable/disable additional calibration request alert

[33mcommit 455447d60052e1d4548c57a9345da36d488ce72e[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 1 18:20:34 2016 +0200

    - when user enters invalid bg level during calibration, then reopen dialog (was not working anymore)
    - override value correctly taken over in calibrationonrequest
    - database.as, updateBgReadingSynchronous is logging also the sql text.

[33mcommit 041b724a84c0399c820515f0bb00bbbdeef7314a[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 1 17:41:11 2016 +0200

    ....
    
    - if discovery bluetooth services fails for 5 times, then rescan forever.

[33mcommit b7392aab258ce180d796c05cd8f5d452214c823d[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Oct 1 16:56:09 2016 +0200

    corrections related to nightscout upload

[33mcommit f3f55c096859fd764a5f3adae0ee572259ecb56b[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Sep 29 23:02:11 2016 +0200

    nightscoutupload

[33mcommit 5c454318e7b5326bb1a701af825fe56d97a9171c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 25 18:25:58 2016 +0200

    nightscout : test url and api-secret

[33mcommit db58cb72bded7d4771ee5ff0775eab4fece40f8d[m
Merge: afdb7ea 69ba4b5
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 25 18:05:36 2016 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 69ba4b5555a91deaee14cca421ba673765e607a8[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 24 20:23:32 2016 +0200

    Update README.md

[33mcommit afdb7eae3ec0eb61cff506e75e4588efaaf36877[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Sep 23 23:52:31 2016 +0200

    improvements bluetoothconnectivity, to avoid that there's multiple times event listeners added to activebluetoothperipheral

[33mcommit f6c7e1f17037e3c7fd2599574b10b9402cebd22c[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Sep 23 23:13:29 2016 +0200

    default names for api_secret and azurewebsite in a constant

[33mcommit 15789fdffd9db23e836d3637e328bbf4805d9b30[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Sep 21 19:08:08 2016 +0200

    Nightscout settings, not the upload

[33mcommit 29aa77254857c82da6351168a3ae50be639395d9[m
Merge: 0152a80 5c92cd4
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Sep 20 19:29:49 2016 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 0152a80b4619bd1732fb21ab79178903b093a6f8[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Sep 20 19:29:40 2016 +0200

    option to store trace files on disk and send via e-mail

[33mcommit 5c92cd47b15476cda5dd1591737361d54185272f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 18 22:46:59 2016 +0200

    Update README.md

[33mcommit 98f99e4b505b20bfd299b9cd228b7f008849dac9[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Sep 15 21:48:03 2016 +0200

    Update README.md

[33mcommit cc9353b2d553dfa3b20f74aae8ac1d64e7b6c6c2[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Sep 15 21:46:19 2016 +0200

    ....
    
    - bluetooth goes to green after successfully subscribing to characteristic
    This status is now considered as connected
    - bluetooth button color is now always correct according to the status of the bluetooth connection
    - calibration request : notification will not appear if there's no bgreadings in the last 30 minutes

[33mcommit b2c00425d4d341e7584a093339c9bf350f236e79[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 11 22:53:50 2016 +0200

    release 0.0.3

[33mcommit 013942955f623d93164ede1fa49d4401e818b552[m
Merge: 38f2a83 883a1b0
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 11 18:20:47 2016 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 38f2a838890453fe109768d2156f5dbb576d4ff6[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Sep 11 18:20:04 2016 +0200

    removed several calls to removeeventlistener

[33mcommit 883a1b08bf848881a9153dc1eaeaf8e1b8367fa0[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 10 22:50:23 2016 +0200

    Update README.md

[33mcommit 9146c01015df393b5910bec08fc225a40531c0b6[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Sep 10 21:26:14 2016 +0200

    possibility to log calls to notificationservice.updateAllNotifications + fix in timer for bgreadingnotreceived

[33mcommit 540799e228274df24347d33d2ab352d039f8af65[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Sep 9 11:52:08 2016 +0200

    ....
    
    - orange means not connected, it will change to red when not connected for more than 6 minutes
    - linethrough if no readings more than 30 minutes
    - sensor start : warning that date and time should be accurate
    - 2 new white icons (home and settings)
    - fix in TimerService
    - improved reconnecthandler, apparently PeripheralEvent.CONNECT_FAIL is never fired, in Android PeripheralEvent.DISCONNECT is fired for connection attempt failures. In iOS nothing is fired

[33mcommit a925a26382dcce85871bb1606fe54fc78daa0c06[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Sep 6 23:34:15 2016 +0200

    v 0.0.1

[33mcommit a6a29e45eaf4aee1937bddc82f88961bcca89a01[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Sep 6 22:30:13 2016 +0200

    a few fixes, bluetoothbutton color change still not working perfectly

[33mcommit be13369f83313a21a6434664bbdddf716a76e7ea[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Sep 5 09:20:01 2016 +0200

    some final tuning needed
    
    - in Homeview, bluetooth button changing color with status
    	- red = bluetooth not active or no device stored in the database (ie no known device)
    	- orange = bluetooth active, device stored in the database, but not connected
    	- green = bluetooth active, and connected to device
    
    - behind button an actionsheet pops up with options to scan, forget device, ...
    (start and stop sensor not yet included).
    With necessary dialog popups
    
    - Start sensor, with date and time.
    
    - add range if icons (smiley) with different sizes, should work also for notifications but not yet tested
    
    - splash screen for iOS, tested only on iPhone SE
    
    - splash screen for Android, tested on tablet
    
    - In loggingview, background is now always 212121, additional gap between items, white line between items
    
    - initialCalibration changed, it doesn't take lowest as first, it takes first as first and timestamp of the calibration = exact timestamp
    
    - notificationservice : removed everything related to wake-up notification, seems not necessary

[33mcommit bddca4480d54bfb14d82ab1c4d0939299d416e09[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Aug 30 22:37:23 2016 +0200

    bluetoothservice asks oauthorisation, required for Marshmallow - not tested

[33mcommit 140c809e776c75f82dd78a185fd0a3414320e6d8[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Aug 30 22:09:16 2016 +0200

    bluetooth scan
    
    - in Homeview, bluetooth button changing color with status
    	- red = bluetooth not active or no device stored in the database (ie no known device)
    	- orange = bluetooth active, device stored in the database, but not connected
    	- green = bluetooth active, and connected to device
    
    - behind button an actionsheet pops up with options to scan, forget device, ...
    (start and stop sensor not yet included)

[33mcommit cee2242f69d545540596df23f6e35472a0c87de4[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Aug 30 10:12:52 2016 +0200

    intermediate commit, with changes for action sheet behind bluetooth button

[33mcommit 0ae97e6ef930ef7b51df35658c7049e803d5d9c5[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Aug 28 19:32:35 2016 +0200

    ...
    
    - at startup, check if there's more than 1 calibration for the active sensor, if yes enable the calibration button
    - bluetoothservice : forget bluetooth device : don't restart scanning automatically after disconnecting and removing activebluetoothperipheral
    - bluetooth button added in home screen:
       - red = bluetooth not active or no device stored in the database (ie no known device)
       - orange = bluetooth active, device stored in the database, but not connected
       - green = bluetooth active, and connected to
    - fix related to dialogview, need to check index when event is triggered

[33mcommit 1000419dabf15a932e1c1ce00b5f43537903c039[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 27 22:28:45 2016 +0200

    calibration seems to fully work, inclusive calibration request, add calibration, calibration override - still more testing needed

[33mcommit a1851461ae8a6567642e51469b3866d951e2734b[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 27 22:25:02 2016 +0200

    improved bluetoothservice.as another update

[33mcommit 667f6c5076dbb0b33941959ec809d9e0c0aa6f5a[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 24 19:07:50 2016 +0200

    improved bluetoothservice.as update

[33mcommit 67b0495bcdc91e984b596e5ec6e53730f9d95b02[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Aug 24 19:02:02 2016 +0200

    improved bluetoothservice.as

[33mcommit 4598c66efefae60a3292fd9f18f592aaa062d0b3[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Mon Aug 22 22:42:14 2016 +0200

    initial calibration and one calibration override working

[33mcommit e2c22e46575bb6a84c1280a94716f475b7fc7228[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Aug 13 22:49:03 2016 +0200

    Initial calibration works - tested with 12 readings
    
    - each of those 12 readings was equal compated to the Android version up to two digits after the decimal point
    - one strange thing noticed was calculation of value d in calculatewls.
    With w = 20.0508028, l = 92.66081279999999, m = 35639.48038245252, n = 13707821.66360818, p = 22696.899135999996, q = 8729787.313161286
    the Android version was having d = (l * n) - (m * m) =  6907.109718799591.
    While the value should be 5335. This wrong calculation happend while creating the third bgreading, ie the first bgreading after the initial calibration.

[33mcommit 285003cfdf2f7b81b0b466ff625ca38304c94ed7[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 24 21:40:40 2016 +0200

    calibrations triggered at first two bloodglucose readings

[33mcommit 776ead5102365171128c89dd54000e26645f7362[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 24 09:41:14 2016 +0200

    database improvements, save bgreading works

[33mcommit b58ddc3054bb533c6c86b4dae24034b5d5de3a40[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 21 22:30:37 2016 +0200

    works also for Android and some other changes

[33mcommit e831a98bd212bead5903e1ef754595cc12d38bd6[m
Merge: 45ed2ae c327a6e
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 21 17:02:25 2016 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 45ed2aeecebc2dfa5f2e0b34f1073bffc686d816[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Jul 21 17:01:27 2016 +0200

    progress

[33mcommit c327a6e68cde501bbc79df103270c09acb42302f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Sun Jul 17 15:49:14 2016 +0200

    Update README.md

[33mcommit be7793efcfa34ceeed2104126a80ac11ffa6cd38[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sat Jul 16 15:41:19 2016 +0200

    intermediate commit - all calibration classes implemented but not yet fully tested

[33mcommit dc9cd77c18a5f10777e05b5442bb896c990d4ddd[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Jun 29 21:55:57 2016 +0200

    should have been added in previous commit

[33mcommit b8bfb56eddbb7ca7f7755502bb658786f5843de9[m
Merge: 09116a8 2a95b98
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Jun 24 23:56:54 2016 +0200

    Merge branch 'master' of https://github.com/JohanDegraeve/iosxdripreader

[33mcommit 09116a824398054210a49bef8242bbcd14659ec9[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Jun 24 23:55:11 2016 +0200

    Several changes
    
    	- remove the table that holds the connection status of the bluetooth device, makes no sense
    	- also column connected removed from bluetoothdevice table
    	- renamed table name activebluetoothdevice to bluetoothdevice
    	- database method to update the bluetoothdevice
    	- Loggingview that shows bluetooth loggings, generated during run of the application (not yet stored in the database)
    	- removed the connected status in bluetoothdevice, this is redundant info
    	- extended modellocator to eventdispatcher, otherwise warnings aboud bindinng appear
    	- if scanning fails, retry after 60, .. 300 seconds
    	- if connection to peripheral fails, retry after 60, .. 300 seconds
    	- SettingsView page added, from where it's possible to forget bluetoothdevice
    	- Notifications ANE added
    	- Notification every 5 minutes that will launch if app is killed.
    	- Timer 5 seconds right before that notification to reset the notification to 5 minutes later
    	- added logging table to database
    	- in homeview, bluetoothevent is logged in the database
    	- During startup, get logs from database and store them in loglist that will be shown also, sorted

[33mcommit 2a95b98aa8e5fa243ce74a8965cade2224df22ea[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Jun 21 22:49:46 2016 +0200

    Update README.md

[33mcommit 4c3f3f3479a5fd38cf6e957d46ea1fe02654e324[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Tue Jun 21 22:43:17 2016 +0200

    Update README.md

[33mcommit 863460279d72eb03c81e4612349827178a651924[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Jun 14 20:38:43 2016 +0200

    Several changes
    
       - acking receipt of a characteristic updat back to the xdrip
       (call back function of this ack doesn't work, commented out)
       - peripheral name checking anything that contains xdrip or xbridge, case insensitive - al other bluetoothdevices (other names) are ignored
       - created bluetoothserviceevent, to dispatch with status updates, information messages etc.
       - bluetoothserviceevent to pass status information, which can be shown to user
       - UUID that is assigned bij iOS device will be stored as address information

[33mcommit d2f4043052864484458ec6e06a19ca5ae42085ca[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Sun Jun 12 18:16:32 2016 +0200

    bluetooth scanning, connecting, reading transmitted data - no ack yet

[33mcommit c66e9b40b3cdc51673963de81f3da2717bc0f44f[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Jun 8 23:30:32 2016 +0200

    changed singleton concept, no need to call getInstance each time - each variable and method should be made static

[33mcommit 742440c83fcc81a93e7494f9a3eaa402e14485fd[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Tue Jun 7 22:54:55 2016 +0200

    database with 2 tables in it, ble availability check and scanning

[33mcommit 2d15ccc3b469883726527495b98d8530305b8385[m
Merge: d623c48 e59ee7e
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Jun 3 23:35:25 2016 +0200

    Merge remote-tracking branch 'origin/master'

[33mcommit e59ee7e1942a9486c4e5125171e141d841120f4b[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Fri Jun 3 23:35:06 2016 +0200

    Update README.md

[33mcommit d623c48c839cc4e02fe770a8b8478093e4b850e2[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Fri Jun 3 23:31:40 2016 +0200

    ios sdk 9.3

[33mcommit 90afaa3640531bca1a2e7814b88a2b75b2cdc157[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 22:54:46 2016 +0200

    Update README.md

[33mcommit 8db928b1204f82acc796b8e524fe690d6921f335[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 22:50:15 2016 +0200

    had to check the box packaging in flex build packaging

[33mcommit d00256ade060af6d8f5cab2989bf3c10304aa5cd[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 22:41:46 2016 +0200

    added bluetooth as background mode in infoadditions

[33mcommit 3466a3d252bde7320111c7fc76661c988d534f62[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 22:39:42 2016 +0200

    changes done by Flash BBuilder while adding ios SDK in flex build packing - native extensions

[33mcommit f500e467d896b3803a48c1b1bde36e39b316918f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 22:31:05 2016 +0200

    Update README.md

[33mcommit 3b3c61471b2ebcb6819f01103825c783dc688410[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 22:30:41 2016 +0200

    Update README.md

[33mcommit d7ad7b5ca81d762701a5a55a13d17ca05b5bb182[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 22:30:16 2016 +0200

    Update README.md

[33mcommit 49be5229b45a99d0f819823ae3f7261e12f70cc5[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 22:26:30 2016 +0200

    changed id

[33mcommit 8b82f5d342eadde6c273a0a74567300a77581765[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 22:08:48 2016 +0200

    Update README.md

[33mcommit 84416b9032c7cc2726dc520fc886230d5be73356[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 22:00:57 2016 +0200

    added distriqt bluetooth le ane - the ane file itself is not there

[33mcommit 54dcad8a3db1aa3aeaf674d3e263662e112948d8[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 21:24:48 2016 +0200

    one view added : bluetoothscanview, ready to try out bluetooh ane

[33mcommit 4f302408f25976e658b172c860b7f2a7f44e7a4a[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Thu Jun 2 20:43:52 2016 +0200

    unused in helpdiabetes, so probably also not to be used here

[33mcommit f56256f44afe9c7786ccb23867bc54b23f6efff6[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Jun 1 23:55:23 2016 +0200

    added copyright info to all existing files

[33mcommit 7e87b4dc92fe3df75fc09e64f66e73d3577a2e43[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Jun 1 23:51:13 2016 +0200

    changed application skin, grey background, with gradient top to bottom, similar to helpldiabetes

[33mcommit 566ae64716787ee61871aa274b484ae878279c6f[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Jun 1 23:42:51 2016 +0200

    Update README.md

[33mcommit bc9c0ddc436c9caa3085460c5c6f56b0197e6424[m
Author: Johan Degraeve <johan.degraeve@gmail.com>
Date:   Wed Jun 1 23:39:45 2016 +0200

    Create README.md

[33mcommit d20590b05ac0ddcb748b6843f36018290c6cd33d[m
Author: JohanDegraeve <johan.degraeve@gmail.com>
Date:   Wed Jun 1 23:36:23 2016 +0200

    default project created by flash builder
