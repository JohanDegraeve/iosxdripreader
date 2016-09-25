package services
{
	import com.distriqt.extension.dialog.Dialog;
	import com.distriqt.extension.dialog.DialogView;
	import com.distriqt.extension.dialog.builders.AlertBuilder;
	import com.distriqt.extension.dialog.objects.DialogAction;
	import com.distriqt.extension.networkinfo.NetworkInfo;
	import com.distriqt.extension.networkinfo.events.NetworkInfoEvent;
	import com.hurlant.crypto.hash.SHA1;
	import com.hurlant.util.Hex;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import Utilities.DateTimeUtilities;
	import Utilities.Trace;
	import Utilities.UniqueId;
	
	import databaseclasses.BgReading;
	import databaseclasses.Calibration;
	import databaseclasses.CommonSettings;
	
	import events.NightScoutServiceEvent;
	import events.SettingsServiceEvent;
	import events.TimerServiceEvent;
	import events.TransmitterServiceEvent;
	
	import model.ModelLocator;
	
	public class NightScoutService extends EventDispatcher
	{
		[ResourceBundle("nightscoutservice")]
		
		private static var _instance:NightScoutService = new NightScoutService();
		
		public static function get instance():NightScoutService
		{
			return _instance;
		}
		
		
		private static var initialStart:Boolean = true;
		private static var loader:URLLoader;
		private static var nightScoutEventsUrl:String = "";
		private static var testUniqueId:String;
		private static var hash:SHA1 = new SHA1();
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
			
			hashedAPISecret = Hex.fromArray(hash.hash(Hex.toArray(Hex.fromString(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET)))));
			nightScoutEventsUrl = "https://" + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) + "/api/v1/entries";
			
			CommonSettings.instance.addEventListener(SettingsServiceEvent.SETTING_CHANGED, settingChanged);
			TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, bgreadingEventReceived);
			TimerService.instance.addEventListener(TimerServiceEvent.BG_READING_NOT_RECEIVED_ON_TIME, bgReadingNotReceived);
			NetworkInfo.networkInfo.addEventListener(NetworkInfoEvent.CHANGE, networkChanged);
			
			function bgreadingEventReceived(event:BgReading):void {
				sync();
			}
			
			function networkChanged(event:NetworkInfoEvent):void {
				if (NetworkInfo.networkInfo.isReachable()) {
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) != CommonSettings.DEFAULT_SITE_NAME
						&&
						CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET) != CommonSettings.DEFAULT_API_SECRET
						&&
						CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED) == "false"
					) {
						testNightScoutUrlAndSecret();
					} else {
						sync();
					}
				} 
			}
			
			function settingChanged(event:SettingsServiceEvent):void {
				if (event.data == CommonSettings.COMMON_SETTING_API_SECRET) {
					hashedAPISecret = Hex.fromArray(hash.hash(Hex.toArray(Hex.fromString(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET)))));
					CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED,"false");
				} else if (event.data == CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME){
					nightScoutEventsUrl = "https://" + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) + "/api/v1/entries";
					CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED,"false");
				}
				
				if (event.data == CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME || event.data == CommonSettings.COMMON_SETTING_API_SECRET) {
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) != CommonSettings.DEFAULT_SITE_NAME
						&&
						CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET) != CommonSettings.DEFAULT_API_SECRET) {
						testNightScoutUrlAndSecret();
					}
				}
			}
		}
		
		private static function bgReadingNotReceived(event:Event):void {
			//just doing a get from nightscout, to see if that works to keep the app running in the background always
			if (NetworkInfo.networkInfo.isReachable() &&
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED) == "true") {
				var urlVariables:URLVariables = new URLVariables();
				urlVariables["find[created_at][$gte]"] = DateTimeUtilities.createNSFormattedDateAndTime(new Date());
				createAndLoadURLRequest(nightScoutEventsUrl, URLRequestMethod.GET,urlVariables,null,null,null);
				dispatchInformation("call_to_nightscout_to_keep_app_alive");
			}
		}
		
		private static function testNightScoutUrlAndSecret():void {
			//test if network is available
			if (NetworkInfo.networkInfo.isReachable()) {
				var testEvent:Object = new Object();
				testUniqueId = UniqueId.createEventId();
				testEvent["_id"] = testUniqueId;
				testEvent["eventType"] = "Exercise";
				testEvent["duration"] = 20;
				testEvent["notes"] = "to test nightscout url";
				var nightScoutTreatmentsUrl:String = "https://" + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) + "/api/v1/treatments";
				createAndLoadURLRequest(nightScoutTreatmentsUrl, URLRequestMethod.PUT,null,JSON.stringify(testEvent),nightScoutUrlTestSuccess,nightScoutUrlTestError);
				dispatchInformation("call_to_nightscout_to_verify_url_and_secret");
			} else {
				dispatchInformation("call_to_nightscout_to_verify_url_and_secret_can_not_be_made");
			}
		}
		
		private static function nightScoutUrlTestSuccess(event:Event):void {
			CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED,"true");
			var alert:DialogView = Dialog.service.create(
				new AlertBuilder()
				.setTitle(ModelLocator.resourceManagerInstance.getString("nightscoutservice","nightscout_title"))
				.setMessage(ModelLocator.resourceManagerInstance.getString("nightscoutservice","nightscout_test_result_ok"))
				.addOption("Ok", DialogAction.STYLE_POSITIVE, 0)
				.build()
			);
			DialogService.addDialog(alert, 60);
			dispatchInformation("nightscout_test_result_ok");
			var nightScoutTreatmentsUrl:String = "https://" + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) + "/api/v1/treatments";
			createAndLoadURLRequest(nightScoutTreatmentsUrl + "/" + testUniqueId, URLRequestMethod.DELETE, null, null,sync, null);
		}
		
		private static function nightScoutUrlTestError(event:IOErrorEvent):void {
			var errorMessage:String;
			if (event.currentTarget.data) {
				if (event.currentTarget.data is String)
					errorMessage = ModelLocator.resourceManagerInstance.getString("nightscoutservice","nightscout_test_result_nok") + "\n" + event.currentTarget.data;
			} else {
				errorMessage = ModelLocator.resourceManagerInstance.getString("nightscoutservice","nightscout_test_result_nok");
			}
			var alert:DialogView = Dialog.service.create(
				new AlertBuilder()
				.setTitle(ModelLocator.resourceManagerInstance.getString("nightscoutservice","nightscout_title"))
				.setMessage(errorMessage)
				.addOption("Ok", DialogAction.STYLE_POSITIVE, 0)
				.build()
			);
			DialogService.addDialog(alert, 60);
			dispatchInformation("nightscout_test_result_nok");
		}
		
		private static function sync(event:Event = null):void {
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) == CommonSettings.DEFAULT_SITE_NAME
				||
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET) == CommonSettings.DEFAULT_API_SECRET) {
				return;
			} else {
				trace("sync still to be implemented");
				enkel syncenals we als gekalibereerd hebben
				ook eens opkuis van logging database loggen, (ja den tijd dat dat in beslag neemt)
				en die logopkuis om de 24 uur doen, met timerservice
				
			}
		}
		
		/**
		 * creates URL request and loads it<br>
		 */
		private static function createAndLoadURLRequest(url:String, requestMethod:String, urlVariables:URLVariables, data:String, successFunction:Function, errorFunction:Function):void {
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
			
			if (successFunction != null) {
				loader.addEventListener(Event.COMPLETE,successFunction);
			}
			
			if (errorFunction != null) {
				loader.addEventListener(IOErrorEvent.IO_ERROR, errorFunction);
			} else {
				loader.addEventListener(IOErrorEvent.IO_ERROR,nightScoutAPICallFailed);
			}
			
			loader.load(request);
			myTrace("createAndLoadURLRequest url = " + request.url + ", method = " + request.method + ", request.data = " + request.data); 
		}
		
		private static function myTrace(log:String):void {
			Trace.myTrace("xdrip-NightScoutService.as", log);
		}
		
		private static function nightScoutAPICallFailed(event:IOErrorEvent):void {
			var errorMessage:String = "NightScoutAPICallFailed event.target.data = ";
			if (event.target.data)
				if (event.target.data is String)
					errorMessage +=  event.target.data as String;
			myTrace(errorMessage);
			
			var nightScoutServiceEvent:NightScoutServiceEvent = new NightScoutServiceEvent(NightScoutServiceEvent.NIGHTSCOUT_SERVICE_INFORMATION_EVENT);
			nightScoutServiceEvent.data = new Object();
			nightScoutServiceEvent.data.information = errorMessage;
			_instance.dispatchEvent(nightScoutServiceEvent);
			syncFinished(false);
		}
		
		private static function syncFinished(result:Boolean):void {
			trace("syncfinished still to be implemented");
		}
		
		/**
		 * informationResourceName will look up the text in local/database.properties<br>
		 * additionalInfo will be added after a dash, if not null
		 */
		private static function dispatchInformation(informationResourceName:String, additionalInfo:String = null):void {
			var nightScoutServiceEvent:NightScoutServiceEvent = new NightScoutServiceEvent(NightScoutServiceEvent.NIGHTSCOUT_SERVICE_INFORMATION_EVENT);
			nightScoutServiceEvent.data = new Object();
			nightScoutServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('nightscoutservice',informationResourceName) + (additionalInfo == null ? "":" - ") + additionalInfo;
			_instance.dispatchEvent(nightScoutServiceEvent);
		}
	}
}