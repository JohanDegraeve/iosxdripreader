package services
{
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetchEvent;
	import com.hurlant.crypto.Crypto;
	import com.hurlant.util.Base64;
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
	
	import databaseclasses.CommonSettings;
	
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
		
		private static const QUICKBLOX_URL:String = "https://api.quickblox.com/session.json";
		private static const QUICKBLOX_REST_API_VERSION:String = "0.1.0";
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
			createQuickBloxSession();
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
			var token:String = (event.data.token as String).replace("<","").replace(">","").replace(" ","");
			trace("BackGroundFetchService.as deviceTokenReceived  = " + token);
			CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_DEVICE_TOKEN_ID, token);
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
		
		private static function createQuickBloxSession():void {
			var nonce:String = UniqueId.createNonce(10);
			var timeStamp:String = (new Date()).valueOf().toString().substr(0, 10);
			//application_id=51098&auth_key=DKPYLHHLVQMMLPV&nonce=134056951&timestamp=1482683701&user[login]=testuser&user[password]=dkke123JJ
			var toSign:String = "application_id=" + QuickBloxSecrets.ApplicationId 
				+ "&auth_key=" + QuickBloxSecrets.AuthorizationKey
				+ "&nonce=" + nonce
				+ "&timestamp=" + timeStamp;
			
			var key:ByteArray = Hex.toArray(Hex.fromString(QuickBloxSecrets.AuthorizationSecret));
			var data:ByteArray = Hex.toArray(Hex.fromString(toSign));
			var signature:Object = BackgroundFetch.generateHMAC_SHA1(QuickBloxSecrets.AuthorizationSecret, toSign);
			//			var signaturebase64:String = Base64.encode(signature);
			
			var postBody:String = 
				'{"application_id": "' + QuickBloxSecrets.ApplicationId + 
				'", "auth_key": "' + QuickBloxSecrets.AuthorizationKey + 
				'", "timestamp": "' + timeStamp + 
				'", "nonce": "' + nonce + 
				'", "signature": "' + signature +'"}';
			var loader:URLLoader = new URLLoader();
			var request:URLRequest = new URLRequest(QUICKBLOX_URL);
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
		}
		
		private static function createBloxSessionFailure(event:IOErrorEvent):void {
			trace("BackGroundFetchService.as createBloxSessionFailure " + (event.currentTarget.data ? event.currentTarget.data:""));
			var backgroundfetchserviceEvent:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceEvent.data = new Object();
			backgroundfetchserviceEvent.data.information = "BackGroundFetchService.as createBloxSessionFailure " + (event.currentTarget.data ? event.currentTarget.data:"No info received from quickblox");
			_instance.dispatchEvent(backgroundfetchserviceEvent);
		}
	}
}