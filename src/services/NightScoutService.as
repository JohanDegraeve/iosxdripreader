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
	
	import spark.formatters.DateTimeFormatter;
	
	import Utilities.DateTimeUtilities;
	import Utilities.Trace;
	import Utilities.UniqueId;
	
	import databaseclasses.BgReading;
	import databaseclasses.BlueToothDevice;
	import databaseclasses.Calibration;
	import databaseclasses.CommonSettings;
	
	import events.CalibrationServiceEvent;
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
			CalibrationService.instance.addEventListener(CalibrationServiceEvent.INITIAL_CALIBRATION_EVENT, initialCalibrationReceived);
			TimerService.instance.addEventListener(TimerServiceEvent.BG_READING_NOT_RECEIVED_ON_TIME, bgReadingNotReceived);
			NetworkInfo.networkInfo.addEventListener(NetworkInfoEvent.CHANGE, networkChanged);
			sync();
			
			function initialCalibrationReceived(event:CalibrationServiceEvent):void {
				sync();
			}
			
			function bgreadingEventReceived(event:TransmitterServiceEvent):void {
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
				createAndLoadURLRequest(nightScoutEventsUrl, URLRequestMethod.GET,urlVariables,null,null,nightScoutAPICallFailed);
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
				createAndLoadURLRequest(nightScoutTreatmentsUrl, URLRequestMethod.PUT,null,JSON.stringify(testEvent), nightScoutUrlTestSuccess, nightScoutUrlTestError);
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
			var errorMessage:String = ModelLocator.resourceManagerInstance.getString("nightscoutservice","nightscout_test_result_nok");
			if (event.currentTarget.data) {
				if ((event.currentTarget.data as String).length > 0) {
					errorMessage += "\n" + event.currentTarget.data;
				}
			}
			
			if (event.text) {
				if ((event.text as String).length > 0) {
					errorMessage += "\n" + event.text;
				}
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
		
		public static function sync(event:Event = null):void {
			var starttime:Number  = (new Date()).valueOf();
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) == CommonSettings.DEFAULT_SITE_NAME
				||
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET) == CommonSettings.DEFAULT_API_SECRET
				||
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED) ==  "false") {
				_instance.dispatchEvent(new NightScoutServiceEvent(NightScoutServiceEvent.UPLOAD_NO_DATA));
				return;
			}
			
			if (Calibration.allForSensor().length < 2) {
				_instance.dispatchEvent(new NightScoutServiceEvent(NightScoutServiceEvent.UPLOAD_NO_DATA));
				return;
			}
			
			//var testdata:String = "[{\"direction\":\"NOT COMPUTABLE\",\"xDrip_filtered\":189.6,\"sgv\":180,\"xDrip_raw\":184.96,\"xDrip_hide_slope\":true,\"noise\":1,\"xDrip_age_adjusted_raw_value\":184.96,\"xDrip_calculated_value\":180,\"date\":1475006213914,\"dateString\":\"2016-09-27T19:56:53.000+0000\",\"xDrip_calculated_current_slope\":-0.0000039255230669482775,\"device\":\"xBridgeaa94\",\"rssi\":100,\"type\":\"sgv\",\"filtered\":189600,\"sysTime\":\"2016-09-27T19:56:53.000+0000\",\"xDrip_filtered_calculated_value\":0,\"unfiltered\":184960}]";
			//createAndLoadURLRequest(nightScoutEventsUrl, URLRequestMethod.POST, null, testdata, nightScoutUploadSuccess, nightScoutUploadFailed);
			
			var listOfReadingsAsArray:Array = [];
			var lastSyncTimeStamp:Number = new Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_NIGHTSCOUT_SYNC_TIMESTAMP));
			var formatter:DateTimeFormatter = new DateTimeFormatter();
			formatter.dateTimePattern = "yyyy-MM-dd'T'HH:mm:ss.SSSZ";
			formatter.setStyle("locale", "en_US");
			formatter.useUTC = false;
			
			var cntr:int = ModelLocator.bgReadings.length - 1;
			var arrayCntr:int = 0;
			
			while (cntr > -1) {
				var bgReading:BgReading = ModelLocator.bgReadings.getItemAt(cntr) as BgReading;
				if (bgReading.timestamp > lastSyncTimeStamp) {
					if (bgReading.calculatedValue != 0) {
						var newReading:Object = new Object();
						newReading["device"] = BlueToothDevice.name;
						newReading["date"] = bgReading.timestamp;
						newReading["dateString"] = formatter.format(bgReading.timestamp);
						newReading["sgv"] = Math.round(bgReading.calculatedValue);
						newReading["direction"] = bgReading.slopeName();
						newReading["type"] = "sgv";
						newReading["filtered"] = bgReading.ageAdjustedFiltered() * 1000;
						newReading["unfiltered"] = bgReading.usedRaw() * 1000;
						newReading["rssi"] = 100;
						newReading["noise"] = bgReading.noiseValue();
						newReading["xDrip_filtered_calculated_value"] = bgReading.filteredCalculatedValue;
						newReading["xDrip_raw"] = bgReading.rawData;
						newReading["xDrip_filtered"] = bgReading.filteredData;
						newReading["xDrip_calculated_value"] = bgReading.calculatedValue;
						newReading["xDrip_age_adjusted_raw_value"] = bgReading.ageAdjustedRawValue;
						newReading["xDrip_calculated_current_slope"] = bgReading.currentSlope();
						newReading["xDrip_hide_slope"] = bgReading.hideSlope;
						newReading["sysTime"] = formatter.format(bgReading.timestamp);
						newReading["_id"] = bgReading.uniqueId;
						listOfReadingsAsArray[arrayCntr] = newReading;
					}
				} else {
					break;
				}
				cntr--;
				arrayCntr++;
			}			
			
			var endtime:Number  = (new Date()).valueOf();
			
			trace("NightScoutService.as sync , time taken to go through bgreadings = " + ((endtime - starttime)/1000) + " seconds");
			if (listOfReadingsAsArray.length > 0) {
				createAndLoadURLRequest(nightScoutEventsUrl, URLRequestMethod.POST, null, JSON.stringify(listOfReadingsAsArray), nightScoutUploadSuccess, nightScoutUploadFailed);
				var logString:String = "";
				for (var cntr2:int = 0; cntr2 < listOfReadingsAsArray.length; cntr2++) {
					logString += " " + listOfReadingsAsArray[cntr2]["_id"] + ",";
				}
				dispatchInformation("uploading_events_with_id", logString);
			} else {
				_instance.dispatchEvent(new NightScoutServiceEvent(NightScoutServiceEvent.UPLOAD_NO_DATA));
			}
		}
		
		private static function nightScoutUploadSuccess(event:Event):void {
			dispatchInformation("upload_to_nightscout_successfull");
			CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_NIGHTSCOUT_SYNC_TIMESTAMP, (new Date()).valueOf().toString());
			_instance.dispatchEvent(new NightScoutServiceEvent(NightScoutServiceEvent.UPLOAD_SUCCEEDED));
		}
		
		private static function nightScoutUploadFailed(event:Event):void {
			var errorMessage:String;
			if (event.currentTarget.data) {
				if (event.currentTarget.data is String)
					errorMessage = ModelLocator.resourceManagerInstance.getString("nightscoutservice","upload_to_nightscout_unsuccessfull") + "\n" + event.currentTarget.data;
			} else {
				errorMessage = ModelLocator.resourceManagerInstance.getString("nightscoutservice","upload_to_nightscout_unsuccessfull");
			}
			dispatchInformation("upload_to_nightscout_unsuccessfull" + errorMessage);
			_instance.dispatchEvent(new NightScoutServiceEvent(NightScoutServiceEvent.UPLOAD_FAILED));
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
			nightScoutServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('nightscoutservice',informationResourceName) + (additionalInfo == null ? "":" - " + additionalInfo);
			_instance.dispatchEvent(nightScoutServiceEvent);
		}
		
	}
}