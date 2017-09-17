package services
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import Utilities.Trace;
	
	import events.BackGroundFetchServiceEvent;

	public class DexcomShareService extends EventDispatcher
	{
		/**
		 * should be a function that takes a BackGroundFetchServiceEvent as parameter and no return value 
		 */
		private static var functionToCallAtUpOrDownloadSuccess:Function = null;
		/**
		 * should be a function that takes a BackGroundFetchServiceEvent as parameter and no return value 
		 */
		private static var functionToCallAtUpOrDownloadFailure:Function = null;

		private static const US_SHARE_BASE_URL:String = "https://share2.dexcom.com/ShareWebServices/Services/";
		private static const NON_US_SHARE_BASE_URL:String = "https://shareous1.dexcom.com/ShareWebServices/Services/";

		private static var initialStart:Boolean = true;
		
		private static var dexcomShareStatus:String = "";
		private static const dexcomShareStatus_Waiting_LoginPublisherAccountByName:String = "Waiting_LoginPublisherAccountByName";
		
		public function DexcomShareService()
		{
			if (_instance != null) {
				throw new Error("DexcomShareService class constructor can not be used");	
			}
		}
		
		private static var _instance:DexcomShareService = new DexcomShareService();
		
		public static function get instance():DexcomShareService
		{
			return _instance;
		}

		//			BackGroundFetchService.instance.addEventListener(BackGroundFetchServiceEvent.LOAD_REQUEST_RESULT, defaultSuccessFunction);
		public static function init():void {
			if (!initialStart)
				return;
			else
				initialStart = false;
			
			BackGroundFetchService.instance.addEventListener(BackGroundFetchServiceEvent.LOAD_REQUEST_ERROR, defaultErrorFunction);
			BackGroundFetchService.instance.addEventListener(BackGroundFetchServiceEvent.LOAD_REQUEST_RESULT, defaultSuccessFunction);
		}
		
		public static function sync():void {
			myTrace("in sync");
			/*
			"accountName":"yourlogin",
			"applicationId":"d8665ade-9673-4e27-9ff6-92db4ce13d13",
			"password":"yourpassword"*/
			var authParameters:Object = new Object();
			createAndLoadURLRequest(NON_US_SHARE_BASE_URL + "General/LoginPublisherAccountByName", URLRequestMethod.POST, null, JSON.stringify(authParameters), dexcomLoginPublisherAccountByNameSuccess, dexcomLoginPublisherAccountByNameFailed);
			dexcomShareStatus = dexcomShareStatus_Waiting_LoginPublisherAccountByName;
		}

		private static function dexcomLoginPublisherAccountByNameSuccess(event:Event):void {
			//contents in event.data.information
			if (dexcomShareStatus == dexcomShareStatus_Waiting_LoginPublisherAccountByName) {
				myTrace("in dexcomUploadSuccess and dexcomShareStatus == dexcomShareStatus_Waiting_LoginPublisherAccountByName");
				
 			} else {
				myTrace("in dexcomUploadSuccess, dexcomShareStatus != dexcomShareStatus_Waiting_LoginPublisherAccountByName");
			}
		}
		
		private static function dexcomLoginPublisherAccountByNameFailed(event:BackGroundFetchServiceEvent):void {
			var errorMessage:String;
			if (event.data) {
				if (event.data.information)
					errorMessage = event.data.information;
			} else {
				errorMessage = "";
			}
			myTrace("in dexcomUploadFailed" + errorMessage);
		}

		/**
		 * creates URL request and loads it<br>
		 */
		private static function createAndLoadURLRequest(url:String, requestMethod:String, urlVariables:URLVariables, data:String, successFunction:Function, errorFunction:Function):void {
			if (errorFunction != null) {
				functionToCallAtUpOrDownloadFailure = errorFunction;
			} else
				functionToCallAtUpOrDownloadFailure = null;
			if (successFunction != null) {
				functionToCallAtUpOrDownloadSuccess = successFunction;
			} else {
				functionToCallAtUpOrDownloadSuccess = null;
			}
			BackGroundFetchService.createAndLoadUrlRequest(url, requestMethod ? requestMethod:URLRequestMethod.GET, urlVariables, data, "application/json", "Accept", "application/json", "User-Agent", "Dexcom Share/3.0.2.11 CFNetwork/711.2.23 Darwin/14.0.0");
		}
		
		private static function defaultErrorFunction(event:BackGroundFetchServiceEvent):void {
			if(functionToCallAtUpOrDownloadFailure != null) {
				functionToCallAtUpOrDownloadFailure(event);
			}
			else {
			}
			
			functionToCallAtUpOrDownloadSuccess = null;
			functionToCallAtUpOrDownloadFailure = null;
		}
		
		private static function defaultSuccessFunction(event:BackGroundFetchServiceEvent):void {
			if(functionToCallAtUpOrDownloadSuccess != null) {
				functionToCallAtUpOrDownloadSuccess(event);
			}
			else {
			}
			functionToCallAtUpOrDownloadSuccess = null;
			functionToCallAtUpOrDownloadFailure = null;
		}

		private static function myTrace(log:String):void {
			Trace.myTrace("DexcomShareService.as", log);
		}
	}
}