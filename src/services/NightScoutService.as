package services
{
	import com.hurlant.crypto.hash.SHA1;
	import com.hurlant.util.Hex;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import Utilities.Trace;
	
	import databaseclasses.CommonSettings;
	import databaseclasses.Settings;
	
	import events.SettingsServiceEvent;

	public class NightScoutService
	{
		private static var _instance:NightScoutService = new NightScoutService();
		
		private static var initialStart:Boolean = true;
		private static var loader:URLLoader;
		/**
		 * when a function tries to access nightscout api, functionToRecall will be called when http request is completed
		 */
		private var functionToRecall:Function;

		private static var hashedAPISecret:String = "";
		
		public function NightScoutService()
		{
			if (_instance != null) {
				throw new Error("NightScoutService class constructor can not be used");	
			}
		}
		
		public static function init():void {
			if (!initialStart)
				return;
			else
				initialStart = false;
			
			var hash:SHA1 = new SHA1();
			hashedAPISecret = Hex.fromArray(hash.hash(Hex.toArray(Hex.fromString(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET)))));
			
			CommonSettings.instance.addEventListener(SettingsServiceEvent.SETTING_CHANGED, settingChanged);
			
			function settingChanged(event:SettingsServiceEvent):void {
				if (event.data == CommonSettings.COMMON_SETTING_API_SECRET) {
					hashedAPISecret = Hex.fromArray(hash.hash(Hex.toArray(Hex.fromString(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET)))));
				}
				
				if (event.data == CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME || event.data == CommonSettings.COMMON_SETTING_API_SECRET) {
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) != CommonSettings.DEFAULT_SITE_NAME
						&&
						CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET) != CommonSettings.COMMON_SETTING_API_SECRET) {
						testNightScoutUrlAndSecret();
					}
				}
			}
			
			function testNightScoutUrlAndSecret():void {
				/*test url
				als niet goed geef dan een dialog met de fout
				als wel goed een sync opstarten
				//doe sowieso al een addeventlistener voor 
				transmitterservice
				wijziging van netwerk status (da's) een nieuwe ane' +
				missedreading
				bij elk van deze een sync opstarten, als 'm niet aan't draaien is tenminste*/
			}
		}
		
		public function sync():void {
			check if url and apisecret are nto default
			if not try ...
				
		}
		
		/**
		 * creates URL request and loads it<br>
		 * if paramFunctionToRecall != null then <br>
		 * - eventlistener is registered for that function for Event.COMPLETE<br>
		 * - paramFunctionToRecall is assigned to variable functionToRecall<br>
		 * if addIOErrorListener then a listener will be added for the event IOErrorEvent.IO_ERROR, with function nightScoutAPICallFailed<br>
		 * urlVariables or data needs to be supplied, not both.
		 */
		private function createAndLoadURLRequest(url:String, requestMethod:String, urlVariables:URLVariables, data:String, paramFunctionToRecall:Function, addIOErrorListener:Boolean):void {
			var request:URLRequest = new URLRequest(url);
			loader = new URLLoader();
			
			request.requestHeaders.push(new URLRequestHeader("api-secret", hashedAPISecret));
			request.requestHeaders.push(new URLRequestHeader("Content-type", "application/json"));
			request.contentType = "application/json";
			
			if (!requestMethod)
				requestMethod = URLRequestMethod.GET;
			request.method = requestMethod;
			
			if (data != null)
				request.data = data;
			else if (urlVariables != null)
				request.data = urlVariables;
			
			if (paramFunctionToRecall != null) {
				loader.addEventListener(Event.COMPLETE,paramFunctionToRecall);
				functionToRecall = paramFunctionToRecall;
			}
			
			if (addIOErrorListener)
				loader.addEventListener(IOErrorEvent.IO_ERROR,nightScoutAPICallFailed);
			
			loader.load(request);
			myTrace("createAndLoadURLRequest url = " + request.url + ", method = " + request.method + ", request.data = " + request.data); 
		}
		
		private static function myTrace(log:String):void {
			Trace.myTrace("xdrip-NightScoutService.as", log);
		}
		
		/**
		 * cheks if functionToRemoveFromEventListner != null and if not removed from Event.COMPLETE<br>
		 * removes eventlistener nightScoutAPICallFailed from IOErrorEvent.IO_ERROR
		 */
		private function removeEventListeners():void  {
			
			if (functionToRecall != null)
				loader.removeEventListener(Event.COMPLETE,functionToRecall);
			loader.removeEventListener(IOErrorEvent.IO_ERROR,nightScoutAPICallFailed);
		}
		
		private function nightScoutAPICallFailed(event:Event):void {
			myTrace("NightScoutAPICallFailed event.target.data = " + event.target.data as String);
			removeEventListeners();
			syncFinished(false);
		}
	}
}