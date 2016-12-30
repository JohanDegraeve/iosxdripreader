package services
{
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
	
	import Utilities.UniqueId;
	
	import databaseclasses.LocalSettings;
	
	import events.BackGroundFetchServiceEvent;
	
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
		
		private static var register:Boolean = false;
		
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
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.PERFORMFETCH, performFetch);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.DEVICE_TOKEN_RECEIVED, deviceTokenReceived);
			BackgroundFetch.minimumBackgroundFetchInterval = BackgroundFetch.BACKGROUND_FETCH_INTERVAL_MINIMUM;
		}
		
		public static function callCompletionHandler(result:String):void {
			trace("BackGroundFetchService.as callCompletionhandler with result " + result);
			BackgroundFetch.callCompletionHandler(result);
		}
		
		private static function performFetch(event:BackgroundFetchEvent):void {
			trace("BackGroundFetchService.as performFetch");
			var backgroundfetchServiceEvent:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchServiceEvent.data = new Object();
			backgroundfetchServiceEvent.data.information = "BackGroundFetchService.as performFetch";
			_instance.dispatchEvent(backgroundfetchServiceEvent);
			var backgroundfetchServiceEvent:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.PERFORM_FETCH);
			backgroundfetchServiceEvent.data = new Object();
			backgroundfetchServiceEvent.data.information = event.data.result as String;
			_instance.dispatchEvent(backgroundfetchServiceEvent);
		}
		
		private static function deviceTokenReceived(event:BackgroundFetchEvent):void {
			trace("BackGroundFetchService.as deviceTokenReceived ");// + event.data.token);
			var token:String = (event.data.token as String).replace("<","").replace(">","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","").replace(" ","");
			trace("BackGroundFetchService.as deviceTokenReceived  = " + token);
			LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_DEVICE_TOKEN_ID, token);
			
			//if already registered for push notifications, then update the token
			if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_SUBSCRIBED_TO_PUSH_NOTIFICATIONS) ==  "true") {
				var backgroundfetchserviceLogInfo:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
				backgroundfetchserviceLogInfo.data = new Object();
				backgroundfetchserviceLogInfo.data.information = "BackGroundFetchService.as new device_token received, start update at quickBlox";
				_instance.dispatchEvent(backgroundfetchserviceLogInfo);
				register = true;
				createSessionQuickBlox();
			} else {
				
			}
		}
		
		private static function loadRequestSuccess(event:BackgroundFetchEvent):void {
			trace("BackGroundFetchService.as loadRequestSuccess");
			trace("result = " + (event.data.result as String)); 
			
			var backgroundfetchserviceLogInfo:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceLogInfo.data = new Object();
			backgroundfetchserviceLogInfo.data.information = event.data.result as String;
			_instance.dispatchEvent(backgroundfetchserviceLogInfo);
			
			var backgroundFetchServiceResult:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOAD_REQUEST_RESULT);
			backgroundFetchServiceResult.data = new Object();
			backgroundFetchServiceResult.data.information = event.data.result as String;
			_instance.dispatchEvent(backgroundFetchServiceResult);
		}
		
		private static function loadRequestError(event:BackgroundFetchEvent):void {
			trace("BackGroundFetchService.as loadRequestError");
			trace("error = " + (event.data.error as String));
			
			var backgroundfetchserviceLogInfo:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceLogInfo.data = new Object();
			backgroundfetchserviceLogInfo.data.information = event.data.error as String;
			_instance.dispatchEvent(backgroundfetchserviceLogInfo);
			
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
			var backgroundfetchserviceEvent:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceEvent.data = new Object();
			backgroundfetchserviceEvent.data.information = event.data.information;
			backgroundfetchserviceEvent.timeStamp = event.timeStamp;
			_instance.dispatchEvent(backgroundfetchserviceEvent);
		}
		
		public static function registerPushNotification():void {
			register = true;
			createSessionQuickBlox();
		}
		
		public static function deRegisterPushNotification():void {
			register = false;
			createSessionQuickBlox();
		}
		
		private static function createSessionQuickBlox():void {
			var nonce:String = UniqueId.createNonce(10);
			var timeStamp:String = (new Date()).valueOf().toString().substr(0, 10);
			var udid:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_UDID);
			var toSign:String = "application_id=" + QuickBloxSecrets.ApplicationId 
				+ "&auth_key=" + QuickBloxSecrets.AuthorizationKey
				+ "&nonce=" + nonce
				+ "&timestamp=" + timeStamp;
			//+ "&user[login]=" + udid
			//+ "&user[password]=" + QuickBloxSecrets.GenericUserPassword;
			
			var key:ByteArray = Hex.toArray(Hex.fromString(QuickBloxSecrets.AuthorizationSecret));
			var data:ByteArray = Hex.toArray(Hex.fromString(toSign));
			var signature:Object = BackgroundFetch.generateHMAC_SHA1(QuickBloxSecrets.AuthorizationSecret, toSign);
			
			var postBody:String = 
				'{"application_id": "' + QuickBloxSecrets.ApplicationId + 
				'", "auth_key": "' + QuickBloxSecrets.AuthorizationKey + 
				'", "timestamp": "' + timeStamp + 
				'", "nonce": "' + nonce + 
				'", "signature": "' + signature +
				//'", "user": {"login": "' + udid + '", "password": "' + QuickBloxSecrets.GenericUserPassword + 
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
			trace("BackGroundFetchService.as createBloxSessionSuccess");
			var eventAsJSONObject:Object = JSON.parse(event.target.data as String);
			QB_Token = eventAsJSONObject.session.token;
			signUpQuickBlox();
		}
		
		private static function signUpQuickBlox():void {
			var taglist = "ALL";
			var udid:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_UDID);
			var postBody:String = '{"user": {"login": "' + udid + '", "password": "' + QuickBloxSecrets.GenericUserPassword + '", "tag_list": "' + taglist +'"}}';
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
			trace("BackGroundFetchService signUpSuccess");
			userSignInQuickBlox();
		}
		
		private static function signUpFailure(event:IOErrorEvent):void {
			trace("BackGroundFetchService signUpFailure" + (event.currentTarget.data ? event.currentTarget.data:""));
			if (event.currentTarget.data) {
				var eventAsJSONObject:Object = JSON.parse(event.target.data as String);
				if (eventAsJSONObject.errors) {
					if (eventAsJSONObject.errors.login) {
						if ((eventAsJSONObject.errors.login[0] as String) == "has already been taken"){
							userSignInQuickBlox();
						}
					}
				}
			}
		}
		
		private static function userSignInQuickBlox():void {
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
			trace("BackGroundFetchService.as signInSuccess");
			var eventAsJSONObject:Object = JSON.parse(event.target.data as String);
			
			if (register)
				createSubscription();
			else
				deleteUser(new Number(eventAsJSONObject.user.id));
		}
		
		private static function signInFailure(event:IOErrorEvent):void {
			trace("BackGroundFetchService.as signInFailure " + (event.currentTarget.data ? event.currentTarget.data:""));
			var backgroundfetchserviceEvent:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceEvent.data = new Object();
			backgroundfetchserviceEvent.data.information = "BackGroundFetchService.as signInFailure " + (event.currentTarget.data ? event.currentTarget.data:"No info received from quickblox");
			_instance.dispatchEvent(backgroundfetchserviceEvent);
		}
		
		private static function createSubscription():void {
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
		
		private static function deleteUser(id:Number):void {
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(QUICKBLOX_DOMAIN + "/users/" + id + ".json");
			request.method = URLRequestMethod.DELETE;					
			request.requestHeaders.push(new URLRequestHeader("QuickBlox-REST-API-Version", QUICKBLOX_REST_API_VERSION));
			request.requestHeaders.push(new URLRequestHeader("QB-Token", QB_Token));
			request.contentType = "application/json";
			loader.addEventListener(Event.COMPLETE, userDeleteSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, userDeleteFailure);
			loader.load(request);
		}
		
		private static function userDeleteSuccess(event:Event):void {
			trace("BackGroundFetchService.as subscriptionDeleteSuccess");
			LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_SUBSCRIBED_TO_PUSH_NOTIFICATIONS, "false");
			destroySession();
		}
		
		private static function userDeleteFailure(event:IOErrorEvent):void {
			trace("BackGroundFetchService.as subscriptionDeleteFailure" + (event.currentTarget.data ? event.currentTarget.data:""));
			var backgroundfetchserviceEvent:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceEvent.data = new Object();
			backgroundfetchserviceEvent.data.information = "BackGroundFetchService.as subscriptionDeleteFailure " + (event.currentTarget.data ? event.currentTarget.data:"No info received from quickblox");
			_instance.dispatchEvent(backgroundfetchserviceEvent);
			destroySession();
		}
		
		private static function createBloxSessionFailure(event:IOErrorEvent):void {
			trace("BackGroundFetchService.as createBloxSessionFailure " + (event.currentTarget.data ? event.currentTarget.data:""));
			var backgroundfetchserviceEvent:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceEvent.data = new Object();
			backgroundfetchserviceEvent.data.information = "BackGroundFetchService.as createBloxSessionFailure " + (event.currentTarget.data ? event.currentTarget.data:"No info received from quickblox");
			_instance.dispatchEvent(backgroundfetchserviceEvent);
		}
		
		private static function subscriptionSuccess(event:Event):void {
			trace("BackGroundFetchService.as subscriptionSuccess");
			LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_SUBSCRIBED_TO_PUSH_NOTIFICATIONS, "true");
			destroySession();
		}
		
		private static function subscriptionFailure(event:IOErrorEvent):void {
			trace("BackGroundFetchService.as subscriptionFailure" + (event.currentTarget.data ? event.currentTarget.data:""));
			var backgroundfetchserviceEvent:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceEvent.data = new Object();
			backgroundfetchserviceEvent.data.information = "BackGroundFetchService.as subscriptionFailure " + (event.currentTarget.data ? event.currentTarget.data:"No info received from quickblox");
			_instance.dispatchEvent(backgroundfetchserviceEvent);
			LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_SUBSCRIBED_TO_PUSH_NOTIFICATIONS, "false");
			destroySession();
		}
		
		private static function destroySession():void {
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
			trace("BackGroundFetchService.as sessionDestroyed");
		}
		
		private static function sessionDestroyFailure(event:Event):void  {
			trace("BackGroundFetchService.as sessionDestroyFailure");
			var backgroundfetchserviceEvent:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceEvent.data = new Object();
			backgroundfetchserviceEvent.data.information = "BackGroundFetchService.as sessionDestroyFailure " + (event.currentTarget.data ? event.currentTarget.data:"No info received from quickblox");
			_instance.dispatchEvent(backgroundfetchserviceEvent);
		}
	}
}