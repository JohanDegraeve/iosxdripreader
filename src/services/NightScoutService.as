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
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import spark.formatters.DateTimeFormatter;
	
	import Utilities.Trace;
	import Utilities.UniqueId;
	
	import databaseclasses.BgReading;
	import databaseclasses.BlueToothDevice;
	import databaseclasses.Calibration;
	import databaseclasses.CommonSettings;
	import databaseclasses.LocalSettings;
	
	import events.BackGroundFetchServiceEvent;
	import events.CalibrationServiceEvent;
	import events.NightScoutServiceEvent;
	import events.SettingsServiceEvent;
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
		private static var _nightScoutEventsUrl:String = "";
		private static var testUniqueId:String;
		private static var hash:SHA1 = new SHA1();
		
		private static var _syncRunning:Boolean = false;
		private static var lastSyncrunningChangeDate:Number = (new Date()).valueOf();
		private static const maxMinutesToKeepSyncRunningTrue:int = 1;
		
		private static function get syncRunning():Boolean
		{
			if (!_syncRunning)
				return false;
			
			if ((new Date()).valueOf() - lastSyncrunningChangeDate > maxMinutesToKeepSyncRunningTrue * 60 * 1000) {
				lastSyncrunningChangeDate = (new Date()).valueOf();
				_syncRunning = false;
				return false;
			}
			return true;
		}
		
		private static function set syncRunning(value:Boolean):void
		{
			_syncRunning = value;
			lastSyncrunningChangeDate = (new Date()).valueOf();
		}
		
		
		private static var _hashedAPISecret:String = "";
		
		/**
		 * should be a function that takes a BackGroundFetchServiceEvent as parameter and no return value 
		 */
		private static var functionToCallAtUpOrDownloadSuccess:Function = null;
		/**
		 * should be a function that takes a BackGroundFetchServiceEvent as parameter and no return value 
		 */
		private static var functionToCallAtUpOrDownloadFailure:Function = null;
		
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
			
			_hashedAPISecret = Hex.fromArray(hash.hash(Hex.toArray(Hex.fromString(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET)))));
			_nightScoutEventsUrl = "https://" + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) + "/api/v1/entries";
			
			CommonSettings.instance.addEventListener(SettingsServiceEvent.SETTING_CHANGED, settingChanged);
			TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, bgreadingEventReceived);
			CalibrationService.instance.addEventListener(CalibrationServiceEvent.INITIAL_CALIBRATION_EVENT, initialCalibrationReceived);
			NetworkInfo.networkInfo.addEventListener(NetworkInfoEvent.CHANGE, networkChanged);
			BackGroundFetchService.instance.addEventListener(BackGroundFetchServiceEvent.LOAD_REQUEST_ERROR, defaultErrorFunction);
			BackGroundFetchService.instance.addEventListener(BackGroundFetchServiceEvent.LOAD_REQUEST_RESULT, defaultSuccessFunction);
			BackGroundFetchService.instance.addEventListener(BackGroundFetchServiceEvent.PERFORM_FETCH, performFetch);

			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) != CommonSettings.DEFAULT_SITE_NAME
				&&
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET) != CommonSettings.DEFAULT_API_SECRET
				&&
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED) == "false"
			) {
				testNightScoutUrlAndSecret();
			} else if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) != CommonSettings.DEFAULT_SITE_NAME
				&&
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET) != CommonSettings.DEFAULT_API_SECRET
				&&
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED) == "true"
			) {
				sync();
			}
			
			function initialCalibrationReceived(event:CalibrationServiceEvent):void {
				sync();
			}
			
			function performFetch(event:BackGroundFetchServiceEvent):void {
				trace("NightScoutService.as sync : performfetch");
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
					} else if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) != CommonSettings.DEFAULT_SITE_NAME
						&&
						CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET) != CommonSettings.DEFAULT_API_SECRET
						&&
						CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED) == "true"
					) {
						sync();
					}
				} 
			}
			
			function settingChanged(event:SettingsServiceEvent):void {
				if (event.data == CommonSettings.COMMON_SETTING_API_SECRET) {
					LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_WARNING_THAT_NIGHTSCOUT_URL_AND_SECRET_IS_NOT_OK_ALREADY_GIVEN, "false");
					_hashedAPISecret = Hex.fromArray(hash.hash(Hex.toArray(Hex.fromString(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET)))));
					CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED,"false");
				} else if (event.data == CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) {
					LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_WARNING_THAT_NIGHTSCOUT_URL_AND_SECRET_IS_NOT_OK_ALREADY_GIVEN, "false");
					_nightScoutEventsUrl = "https://" + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) + "/api/v1/entries";
					CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED,"false");
				}
				
				if (event.data == CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME || event.data == CommonSettings.COMMON_SETTING_API_SECRET) {
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) != CommonSettings.DEFAULT_SITE_NAME
						&&
						CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET) != CommonSettings.DEFAULT_API_SECRET
						&& 
						!syncRunning) {
						testNightScoutUrlAndSecret();
					}
				}
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
				dispatchInformation("call_to_nightscout_to_verify_url_and_secret");
				createAndLoadURLRequest(nightScoutTreatmentsUrl, URLRequestMethod.PUT,null,JSON.stringify(testEvent), nightScoutUrlTestSuccess, nightScoutUrlTestError);
			} else {
				dispatchInformation("call_to_nightscout_to_verify_url_and_secret_can_not_be_made");
			}
		}
		
		private static function nightScoutUrlTestSuccess(event:BackGroundFetchServiceEvent):void {
			trace("NightScoutService.as nightScoutUrlTestSuccess with information =  " + event.data.information as String);
			functionToCallAtUpOrDownloadSuccess = null;
			functionToCallAtUpOrDownloadFailure = null;
			
			CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED,"true");
			dispatchInformation("nightscout_test_result_ok");
			var nightScoutTreatmentsUrl:String = "https://" + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) + "/api/v1/treatments";
			createAndLoadURLRequest(nightScoutTreatmentsUrl + "/" + testUniqueId, URLRequestMethod.DELETE, null, null,sync, null);

			if (ModelLocator.isInForeground) {
				var alert:DialogView = Dialog.service.create(
					new AlertBuilder()
					.setTitle(ModelLocator.resourceManagerInstance.getString("nightscoutservice","nightscout_title"))
					.setMessage(ModelLocator.resourceManagerInstance.getString("nightscoutservice","nightscout_test_result_ok"))
					.addOption("Ok", DialogAction.STYLE_POSITIVE, 0)
					.build()
				);
				DialogService.addDialog(alert, 60);
			}
		}
		
		private static function nightScoutUrlTestError(event:BackGroundFetchServiceEvent):void {
			trace("NightScoutService.as nightScoutUrlTestError with information =  " + event.data.information as String);
			functionToCallAtUpOrDownloadSuccess = null;
			functionToCallAtUpOrDownloadFailure = null;
			
			if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_WARNING_THAT_NIGHTSCOUT_URL_AND_SECRET_IS_NOT_OK_ALREADY_GIVEN) == "false" && ModelLocator.isInForeground) {
				var errorMessage:String = ModelLocator.resourceManagerInstance.getString("nightscoutservice","nightscout_test_result_nok");
				errorMessage += "\n" + event.data.information;
				
				var alert:DialogView = Dialog.service.create(
					new AlertBuilder()
					.setTitle(ModelLocator.resourceManagerInstance.getString("nightscoutservice","nightscout_title"))
					.setMessage(errorMessage)
					.addOption("Ok", DialogAction.STYLE_POSITIVE, 0)
					.build()
				);
				DialogService.addDialog(alert, 60);
				dispatchInformation("nightscout_test_result_nok");
				LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_WARNING_THAT_NIGHTSCOUT_URL_AND_SECRET_IS_NOT_OK_ALREADY_GIVEN, "true");
			}
		}
		
		public static function sync(event:Event = null):void {
			if (syncRunning) {
				var nightScoutServiceEvent:NightScoutServiceEvent = new NightScoutServiceEvent(NightScoutServiceEvent.NIGHTSCOUT_SERVICE_INFORMATION_EVENT);
				nightScoutServiceEvent.data = new Object();
				nightScoutServiceEvent.data.information = "NightScoutService.as sync : sync running already, return";
				_instance.dispatchEvent(nightScoutServiceEvent);
				return;
			}
			
			functionToCallAtUpOrDownloadSuccess = null;
			functionToCallAtUpOrDownloadFailure = null;
			
			var starttime:Number  = (new Date()).valueOf();
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_AZURE_WEBSITE_NAME) == CommonSettings.DEFAULT_SITE_NAME
				||
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_API_SECRET) == CommonSettings.DEFAULT_API_SECRET
				||
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_URL_AND_API_SECRET_TESTED) ==  "false") {
				BackGroundFetchService.callCompletionHandler(BackGroundFetchService.NO_DATA);
				return;
			}
			
			if (Calibration.allForSensor().length < 2) {
				BackGroundFetchService.callCompletionHandler(BackGroundFetchService.NO_DATA);
				return;
			}
			
			trace("NightScoutService.as setting syncRunning = true");
			syncRunning = true;
			
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
						newReading["xDrip_calculated_current_slope"] = BgReading.currentSlope();
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
				var logString:String = ".. not filled in ..";
				/*for (var cntr2:int = 0; cntr2 < listOfReadingsAsArray.length; cntr2++) {
				logString += " " + listOfReadingsAsArray[cntr2]["_id"] + ",";
				}*/
				dispatchInformation("uploading_events_with_id", logString);
				createAndLoadURLRequest(_nightScoutEventsUrl, URLRequestMethod.POST, null, JSON.stringify(listOfReadingsAsArray), nightScoutUploadSuccess, nightScoutUploadFailed);
			} else {
				trace("NightScoutService.as setting syncRunning = false");
				BackGroundFetchService.callCompletionHandler(BackGroundFetchService.NO_DATA);
				syncRunning = false;
			}
		}
		
		private static function nightScoutUploadSuccess(event:Event):void {
			trace("NightScoutService.as in nightScoutUploadSuccess");
			BackGroundFetchService.callCompletionHandler(BackGroundFetchService.NEW_DATA);
			
			dispatchInformation("upload_to_nightscout_successfull");
			CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_NIGHTSCOUT_SYNC_TIMESTAMP, (new Date()).valueOf().toString());
			syncFinished(true);
		}
		
		private static function nightScoutUploadFailed(event:BackGroundFetchServiceEvent):void {
			trace("NightScoutService.as in nightScoutUploadFailed");
			BackGroundFetchService.callCompletionHandler(BackGroundFetchService.FETCH_FAILED);
			
			var errorMessage:String;
			if (event.data) {
				if (event.data.information)
					errorMessage = event.data.information;
			} else {
				errorMessage = "";
			}
			
			dispatchInformation("upload_to_nightscout_unsuccessfull", errorMessage);
			syncFinished(false);
		}
		
		private static function defaultErrorFunction(event:BackGroundFetchServiceEvent):void {
			trace("NightScoutService.as in defaultErrorFunction");
			if(functionToCallAtUpOrDownloadFailure != null) {
				trace("NightScoutService.as in defaultErrorFunction functionToCallAtUpOrDownloadFailure != null");
				functionToCallAtUpOrDownloadFailure(event);
			}
			else {
				trace("NightScoutService.as in defaultErrorFunction functionToCallAtUpOrDownloadFailure = null");
				BackGroundFetchService.callCompletionHandler(BackGroundFetchService.FETCH_FAILED);
			}
			
			functionToCallAtUpOrDownloadSuccess = null;
			functionToCallAtUpOrDownloadFailure = null;
		}
		private static function defaultSuccessFunction(event:BackGroundFetchServiceEvent):void {
			trace("NightScoutService.as in defaultSuccessFunction");
			if(functionToCallAtUpOrDownloadSuccess != null) {
				trace("NightScoutService.as in defaultSuccessFunction functionToCallAtUpOrDownloadSuccess != null");
				functionToCallAtUpOrDownloadSuccess(event);
			}
			else {
				trace("NightScoutService.as in defaultSuccessFunction functionToCallAtUpOrDownloadSuccess = null");
				BackGroundFetchService.callCompletionHandler(BackGroundFetchService.NEW_DATA);
			}
			
			functionToCallAtUpOrDownloadSuccess = null;
			functionToCallAtUpOrDownloadFailure = null;
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
			BackGroundFetchService.createAndLoadUrlRequest(url, requestMethod ? requestMethod:URLRequestMethod.GET, urlVariables, data, "application/json", "api-secret", _hashedAPISecret);
		}
		
		private static function myTrace(log:String):void {
			Trace.myTrace("xdrip-NightScoutService.as", log);
		}
		
		private static function syncFinished(result:Boolean):void {
			trace("syncfinished still to be implemented");
			trace("NightScoutService.as setting syncRunning = false (might appear double");
			syncRunning = false;
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