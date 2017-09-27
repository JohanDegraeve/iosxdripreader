package services
{
	import com.distriqt.extension.bluetoothle.BluetoothLE;
	import com.distriqt.extension.bluetoothle.events.PeripheralEvent;
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetchEvent;
	import com.hurlant.util.Hex;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import Utilities.Trace;
	import Utilities.UniqueId;
	
	import databaseclasses.BgReading;
	import databaseclasses.BlueToothDevice;
	import databaseclasses.CommonSettings;
	import databaseclasses.LocalSettings;
	
	import events.BackGroundFetchServiceEvent;
	import events.IosXdripReaderEvent;
	import events.TransmitterServiceEvent;
	
	import model.ModelLocator;
	
	import quickbloxsecrets.QuickBloxSecrets;
	
	/**
	 * controls all services that need up or download<br>
	 * 
	 * up- or downloads can not be done in parallel<br>
	 * 
	 * Services that need up or download, need to call createandloadurlrequest and listen for events BackgroundFetchServiceEvent.LOAD_REQUEST_RESULT
	 * and BackgroundFetchServiceEvent.LOAD_REQUEST_ERROR<br>
	 * Failing to do so will not give the chance to BackGroundFetchService to keep control, ie to launch other services that need up or download and to call callcompletionhandler resulting in 
	 * timeout in BackGroundFetch (which is 20 seconds)  
	 * 
	 */
	public class BackGroundFetchService extends EventDispatcher
	{
		private static var _instance:BackGroundFetchService = new BackGroundFetchService(); 
		private static var initialStart:Boolean = true;
		
		private static const QUICKBLOX_DOMAIN:String = "https://api.quickblox.com";
		private static const QUICKBLOX_REST_API_VERSION:String = "0.1.0";
		
		private static var QB_Token:String = "";
		private static var _QBSessionBusy:Boolean = false;
		private static var QBSessionBusySetToTrueTimestamp:Number = 0;
		private static var timeStampOfLastDeviceDiscovery:Number = 0;
		
		//private static var completionHandlerResult:String;
		private static function get QBSessionBusy():Boolean
		{
			if ((new Date()).valueOf() - QBSessionBusySetToTrueTimestamp > 15 * 1000) {//if one qbsession has finished within 15 seconds and a second is starting, then this second one will be ignored
				_QBSessionBusy = false;
			}
			return _QBSessionBusy;
		}
		
		private static function set QBSessionBusy(value:Boolean):void
		{
			_QBSessionBusy = value;
			if (_QBSessionBusy == true)
				QBSessionBusySetToTrueTimestamp = (new Date()).valueOf();
		}
		
		
		/**
		 * to be used in function  callCompletionHandler
		 */
		public static const NEW_DATA: String = "NEW_DATA"; 
		/**
		 * to be used in function  callCompletionHandler
		 */
		public static const FETCH_FAILED: String = "FETCH_FAILED";
		/**
		 * to be used in function  callCompletionHandler
		 */
		public static const NO_DATA: String = "NO_DATA";
		
		private static var wishedTagList:String = "ONE";
		private static var currentTagList:String = "ONE";
		
		public static function get instance():BackGroundFetchService {
			return _instance;
		}
		
		public function BackGroundFetchService() {
			if (_instance != null) {
				throw new Error("BackGroundFetchService class constructor can not be used");	
			}
		}
		
		public static function init():void {
			if (!initialStart)
				return;
			else
				initialStart = false;
			
			BackgroundFetch.init();
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.LOG_INFO, logInfoReceived);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.LOAD_REQUEST_RESULT, loadRequestSuccess);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.LOAD_REQUEST_ERROR, loadRequestError);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.PERFORMLOCALFETCH, performFetch);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.PERFORMREMOTEFETCH, performFetch);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.DEVICE_TOKEN_RECEIVED, deviceTokenReceived);
			BackgroundFetch.minimumBackgroundFetchInterval = BackgroundFetch.BACKGROUND_FETCH_INTERVAL_NEVER;
			BackgroundFetch.setMaxFetchTimeInSeconds(3);
			iosxdripreader.instance.addEventListener(IosXdripReaderEvent.APP_IN_FOREGROUND, retryRegisterPushNotificationIfNeeded);
			
			//goal is to regularly check if phone is  musted
			BluetoothLE.service.centralManager.addEventListener(PeripheralEvent.DISCOVERED, central_peripheralDiscoveredHandler);
		}
		
		private static function retryRegisterPushNotificationIfNeeded(event:Event = null):void {
			myTrace("in registerPushNotification");
			if (((new Date()).valueOf() - new Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TIME_SINCE_LAST_QUICK_BLOX_SUBSCRIPTION))) > 24 * 60 * 60 * 1000) {
				myTrace("BackGroundFetchService.retryRegisterPushNotificationIfNeeded");
				BackGroundFetchService.registerPushNotification(LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_WISHED_QBLOX_SUBSCRIPTION_TAG));
				CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_TIME_SINCE_LAST_QUICK_BLOX_SUBSCRIPTION, (new Date()).valueOf().toString());
			}
		}
		
		private static function central_peripheralDiscoveredHandler(be:PeripheralEvent):void {
			if (BlueToothDevice.alwaysScan()) {
				if ((new Date()).valueOf() - timeStampOfLastDeviceDiscovery < 60 * 1000) {
					
				} else {
					timeStampOfLastDeviceDiscovery = (new Date()).valueOf();
					BackgroundFetch.checkMuted();
				}
			}				
		}
		
		public static function callCompletionHandler(result:String):void {
			myTrace("in callCompletionhandler , result = " + result);
			BackgroundFetch.callCompletionHandler(result);
		}
		
		private static function performFetch(event:BackgroundFetchEvent):void {
			if (event.type == BackgroundFetchEvent.PERFORMREMOTEFETCH) {
				myTrace("performRemoteFetch");
				BluetoothService.startRescan(null);
			} else {
				myTrace("performLocalFetch");
			}
			if (!ModelLocator.isInForeground) {
				var backgroundfetchServiceEvent:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.PERFORM_FETCH);
				backgroundfetchServiceEvent.data = new Object();
				backgroundfetchServiceEvent.data.information = event.data.result as String;
				_instance.dispatchEvent(backgroundfetchServiceEvent);
			} else {
				callCompletionHandler(NO_DATA);
			}
		}
		
		private static function deviceTokenReceived(event:BackgroundFetchEvent):void {
			var token:String = (event.data.token as String).replace("<","").replace(">","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","");
			myTrace("deviceTokenReceived");
			
			//if already registered for push notifications, then update the token
			if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_SUBSCRIBED_TO_PUSH_NOTIFICATIONS) ==  "true"
				&&
				ModelLocator.isInForeground
				&&
				LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_DEVICE_TOKEN_ID) != token
			) {
				registerPushNotification(LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_WISHED_QBLOX_SUBSCRIPTION_TAG));
			} else if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_SUBSCRIBED_TO_PUSH_NOTIFICATIONS) ==  "true") {
				//new device token but app not in foreground, let's locally set it as not subscribed
				//subscription should occur later on, hopefully
				LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_SUBSCRIBED_TO_PUSH_NOTIFICATIONS, "false");
			}
			LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_DEVICE_TOKEN_ID, token);
			
		}
		
		private static function loadRequestSuccess(event:BackgroundFetchEvent):void {
			myTrace("loadRequestSuccess, result only visible in NSLog : connect phone to Mac and use cfgutil");
			myTrace("result = " + (event.data.result as String), true); 
			
			var backgroundFetchServiceResult:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOAD_REQUEST_RESULT);
			backgroundFetchServiceResult.data = new Object();
			backgroundFetchServiceResult.data.information = event.data.result as String;
			_instance.dispatchEvent(backgroundFetchServiceResult);
		}
		
		private static function loadRequestError(event:BackgroundFetchEvent):void {
			myTrace("loadRequestError");
			myTrace("error = " + (event.data.error as String));
			if (event.data.text)
				myTrace("text = " + (event.data.text as String));
			if (event.data.type)
				myTrace("type = " + (event.data.type as String));
			
			var backgroundFetchServiceResult:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOAD_REQUEST_ERROR);
			backgroundFetchServiceResult.data = new Object();
			backgroundFetchServiceResult.data.information = event.data.error as String;
			_instance.dispatchEvent(backgroundFetchServiceResult);
		}
		
		/**
		 * url is the url and should not be null<br>
		 * <br>
		 * if requestMethod is null then "GET" will be done<br>
		 * <br>
		 * urlVariables or data can be null, if urlVariables is not null, then urlVariables are added in the body, not the data<br>
		 * if urlVariables is null, then data is added in the body<br
		 * <br>
		 * urlvariables or data are url encoded within the ANE itself<br>
		 * <br>
		 * contentType can be null, if null it will get the value "application/x-www-form-urlencoded"
		 * <br>
		 * args parameter is to pass additional header name value pairs, must always be by two.<br>
		 */
		public static function createAndLoadUrlRequest(url: String, requestMethod:String, urlVariables:URLVariables, data:String, contentType:String, ... args): void {
			var parameters:Array = new Array(6 + args.length);
			parameters[0] = url;
			parameters[1] = requestMethod;
			parameters[2] = urlVariables;
			parameters[3] = ModelLocator.isInForeground;
			parameters[4] = data;
			parameters[5] = contentType;
			for (var i:int = 0;i < args.length;i++) {
				parameters[6 + i] = args[i];
			}
			BackgroundFetch.createAndLoadUrlRequest.apply(null, parameters);
		}
		
		private static function logInfoReceived(event:BackgroundFetchEvent):void {
			myTrace(event.data.information);
		}
		
		public static function registerPushNotification(newTagList:String ):void {
			myTrace("in registerPushNotification, but quickblox registration is disabled, returning");
			return;//quick blox registration disabled
			if (QBSessionBusy) {
				myTrace("quickblox-trace : registerPushNotification not executed because QBSessionBusy, setting LOCAL_SETTING_SUBSCRIBED_TO_PUSH_NOTIFICATIONS to false");
				LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_SUBSCRIBED_TO_PUSH_NOTIFICATIONS, "false");
				return;
			}
			QBSessionBusy = true;
			myTrace("quickblox-trace : registerPushNotification with taglist " + newTagList);
			wishedTagList = newTagList;
			createSessionQuickBlox();
		}
		
		private static function createSessionQuickBlox():void {
			myTrace("quickblox-trace : createSessionQuickBlox");
			var nonce:String = UniqueId.createNonce(10);
			var timeStamp:String = (new Date()).valueOf().toString().substr(0, 10);
			var udid:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_UDID);
			var toSign:String = "application_id=" + QuickBloxSecrets.ApplicationId 
				+ "&auth_key=" + QuickBloxSecrets.AuthorizationKey
				+ "&nonce=" + nonce
				+ "&timestamp=" + timeStamp;
			
			var key:ByteArray = Hex.toArray(Hex.fromString(QuickBloxSecrets.AuthorizationSecret));
			var data:ByteArray = Hex.toArray(Hex.fromString(toSign));
			var signature:Object = BackgroundFetch.generateHMAC_SHA1(QuickBloxSecrets.AuthorizationSecret, toSign);
			
			var postBody:String = 
				'{"application_id": "' + QuickBloxSecrets.ApplicationId + 
				'", "auth_key": "' + QuickBloxSecrets.AuthorizationKey + 
				'", "timestamp": "' + timeStamp + 
				'", "nonce": "' + nonce + 
				'", "signature": "' + signature +
				'"}';
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(QUICKBLOX_DOMAIN + "/session.json");
			request.contentType = "application/json";
			request.method = URLRequestMethod.POST;					
			request.data = postBody;
			request.requestHeaders.push(new URLRequestHeader("QuickBlox-REST-API-Version", QUICKBLOX_REST_API_VERSION));
			loader.addEventListener(Event.COMPLETE, createBloxSessionSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, createBloxSessionFailure);
			loader.load(request);
		}
		
		private static function createBloxSessionSuccess(event:Event):void {
			myTrace("quickblox-trace : createBloxSessionSuccess");
			var eventAsJSONObject:Object = JSON.parse(event.target.data as String);
			QB_Token = eventAsJSONObject.session.token;
			signUpQuickBlox();
		}
		
		private static function signUpQuickBlox():void {
			myTrace("quickblox-trace : signUpQuickBlox with tag_list = " + wishedTagList);
			var udid:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_UDID);
			var postBody:String = '{"user": {"login": "' + udid + '", "password": "' + QuickBloxSecrets.GenericUserPassword + '", "tag_list": "' + wishedTagList +'"}}';
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(QUICKBLOX_DOMAIN + "/users.json");
			request.method = URLRequestMethod.POST;					
			request.data = postBody;
			request.contentType = "application/json";
			request.requestHeaders.push(new URLRequestHeader("QuickBlox-REST-API-Version", QUICKBLOX_REST_API_VERSION));
			request.requestHeaders.push(new URLRequestHeader("QB-Token", QB_Token));
			loader.addEventListener(Event.COMPLETE, signUpSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, signUpFailure);
			loader.load(request);
		}
		
		private static function signUpSuccess(event:Event):void {
			myTrace("quickblox-trace : signUpSuccess");
			LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_ACTUAL_QBLOX_SUBSCRIPTION_TAG, wishedTagList);
			userSignInQuickBlox();
		}
		
		private static function signUpFailure(event:IOErrorEvent):void {
			myTrace("quickblox-trace : signUpFailure" + event.currentTarget.data ? event.currentTarget.data:"");
			if (event.currentTarget.data) {
				var eventAsJSONObject:Object = JSON.parse(event.target.data as String);
				if (eventAsJSONObject.errors) {
					if (eventAsJSONObject.errors.login) {
						if ((eventAsJSONObject.errors.login[0] as String) == "has already been taken."){
							userSignInQuickBlox();
						} else {
						}
					}
				}
			}
		}
		
		private static function userSignInQuickBlox():void {
			myTrace("quickblox-trace : userSignInQuickBlox");
			var udid:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_UDID);
			var postBody:String = '{"login": "' + udid + '", "password": "' + QuickBloxSecrets.GenericUserPassword + '"}';
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(QUICKBLOX_DOMAIN + "/login.json");
			request.method = URLRequestMethod.POST;					
			request.data = postBody;
			request.contentType = "application/json";
			request.requestHeaders.push(new URLRequestHeader("QuickBlox-REST-API-Version", QUICKBLOX_REST_API_VERSION));
			request.requestHeaders.push(new URLRequestHeader("QB-Token", QB_Token));
			loader.addEventListener(Event.COMPLETE, signInSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, signInFailure);
			loader.load(request);
		}
		
		private static function signInSuccess(event:Event):void {
			myTrace("quickblox-trace : signInSuccess");
			var eventAsJSONObject:Object = JSON.parse(event.target.data as String);
			
			if (eventAsJSONObject.user.user_tags != wishedTagList) {
				currentTagList = eventAsJSONObject.user.user_tags;
				updateUserTagList(eventAsJSONObject.user);
			} else {
				//because it happened in some case that tag list at qblox was equal to wished tag list, actual in setting was still having wrong value
				LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_ACTUAL_QBLOX_SUBSCRIPTION_TAG, wishedTagList);
				createSubscription();
			}
		}
		
		private static function updateUserTagList(user:Object):void {
			myTrace("quickblox-trace : updateUserTagList");
			//create new user without all the null properties
			var newUser:Object = new Object;
			newUser.tag_list = wishedTagList;
			var data:Object = new Object;
			data.user = newUser;
			
			var postBody:String = JSON.stringify(data);
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(QUICKBLOX_DOMAIN + "/users/" + user.id + ".json");
			request.method = URLRequestMethod.PUT;					
			request.data = postBody;
			request.contentType = "application/json";
			request.requestHeaders.push(new URLRequestHeader("QuickBlox-REST-API-Version", QUICKBLOX_REST_API_VERSION));
			request.requestHeaders.push(new URLRequestHeader("QB-Token", QB_Token));
			loader.addEventListener(Event.COMPLETE, updateUserSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, updateUserFailure);
			loader.load(request);
		}
		
		private static function updateUserSuccess(event:Event):void {
			myTrace("quickblox-trace : updateUserSuccess with taglist " + wishedTagList);
			LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_ACTUAL_QBLOX_SUBSCRIPTION_TAG, wishedTagList);
			createSubscription();
		}
		
		private static function updateUserFailure(event:IOErrorEvent):void {
			myTrace("quickblox-trace : updateUserFailure, resetting taglist in settings to value received from quickblox = " + currentTagList + ", event.currentTarget.data = " + (event.currentTarget.data ? event.currentTarget.data:"No info received from quickblox"));
			LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_ACTUAL_QBLOX_SUBSCRIPTION_TAG, currentTagList);
			createSubscription();
		}
		
		private static function signInFailure(event:IOErrorEvent):void {
			myTrace("quickblox-trace : signInFailure " + (event.currentTarget.data ? event.currentTarget.data:""));
		}
		
		private static function createSubscription():void {
			myTrace("quickblox-trace : createSubscription");
			var client_identification_sequence:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_DEVICE_TOKEN_ID);
			var udid:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_UDID);
			var environment:String = ModelLocator.DEBUG_MODE ? "development":"production";
			var postBody:String = '{"notification_channels": "apns",' +
				' "push_token": {"environment": "development", "client_identification_sequence": "' + client_identification_sequence + '"}, ' +
				'"device": {"platform": "ios", "udid": "' + udid + '"}}';
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(QUICKBLOX_DOMAIN + "/subscriptions.json");
			request.method = URLRequestMethod.POST;					
			request.data = postBody;
			request.contentType = "application/json";
			request.requestHeaders.push(new URLRequestHeader("QuickBlox-REST-API-Version", QUICKBLOX_REST_API_VERSION));
			request.requestHeaders.push(new URLRequestHeader("QB-Token", QB_Token));
			loader.addEventListener(Event.COMPLETE, subscriptionSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, subscriptionFailure);
			loader.load(request);
		}
		
		private static function createBloxSessionFailure(event:IOErrorEvent):void {
			myTrace("quickblox-trace : createBloxSessionFailure " + (event.currentTarget.data ? event.currentTarget.data:""));
		}
		
		private static function subscriptionSuccess(event:Event):void {
			myTrace("quickblox-trace : subscriptionSuccess");
			LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_SUBSCRIBED_TO_PUSH_NOTIFICATIONS, "true");
			destroySession();
		}
		
		private static function subscriptionFailure(event:IOErrorEvent):void {
			myTrace("quickblox-trace : subscriptionFailure" + (event.currentTarget.data ? event.currentTarget.data:""));
			LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_SUBSCRIBED_TO_PUSH_NOTIFICATIONS, "false");
			destroySession();
		}
		
		private static function destroySession():void {
			myTrace("quickblox-trace : destroySession");
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(QUICKBLOX_DOMAIN + "/session.json");
			request.method = URLRequestMethod.DELETE;					
			request.requestHeaders.push(new URLRequestHeader("QuickBlox-REST-API-Version", QUICKBLOX_REST_API_VERSION));
			request.requestHeaders.push(new URLRequestHeader("QB-Token", QB_Token));
			request.contentType = "application/json";
			loader.addEventListener(Event.COMPLETE, sessionDestroyed);
			loader.addEventListener(IOErrorEvent.IO_ERROR, sessionDestroyFailure);
			loader.load(request);
		}
		
		private static function sessionDestroyed(event:Event):void  {
			myTrace("quickblox-trace : sessionDestroyed");
		}
		
		private static function sessionDestroyFailure(event:Event):void  {
			myTrace("quickblox-trace : sessionDestroyFailure");
		}
		
		private static function myTrace(log:String, dontWriteToFile:Boolean = false):void {
			Trace.myTrace("BackGroundFetchService.as", log, dontWriteToFile);
		}
		
	}
}