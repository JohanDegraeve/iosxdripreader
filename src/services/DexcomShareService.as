package services
{
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	
	import flash.events.EventDispatcher;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import Utilities.Trace;
	
	import databaseclasses.BgReading;
	import databaseclasses.BlueToothDevice;
	import databaseclasses.CommonSettings;
	
	import events.BackGroundFetchServiceEvent;
	
	import model.ModelLocator;

	public class DexcomShareService extends EventDispatcher
	{
		private static const US_SHARE_BASE_URL:String = "https://share2.dexcom.com/ShareWebServices/Services/";
		private static const NON_US_SHARE_BASE_URL:String = "https://shareous1.dexcom.com/ShareWebServices/Services/";

		private static var initialStart:Boolean = true;
		
		private static var dexcomShareStatus:String = "";
		private static const dexcomShareStatus_Waiting_LoginPublisherAccountByName:String = "Waiting_LoginPublisherAccountByName";
		private static const dexcomShareStatus_Waiting_PostReceiverEgvRecords:String = "Waiting_PostReceiverEgvRecords";
		private static const dexcomShareStatus_Waiting_StartRemoteMonitoringSession:String = "Waiting_StartRemoteMonitoringSession";
		private static var dexcomShareSessionId:String = "";
		
		private static var _syncRunning:Boolean = false;
		private static var lastSyncrunningChangeDate:Number = (new Date()).valueOf();
		private static const maxMinutesToKeepSyncRunningTrue:int = 1;

		public static function DexcomShareSyncRunning():Boolean {
			return syncRunning;
		}

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
			myTrace("set syncRunning to " + value);
			_syncRunning = value;
			lastSyncrunningChangeDate = (new Date()).valueOf();
			if (syncRunning == false)
				dexcomShareStatus = "";
		}

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

		public static function init():void {
			if (!initialStart)
				return;
			else
				initialStart = false;
			
			BackGroundFetchService.instance.addEventListener(BackGroundFetchServiceEvent.LOAD_REQUEST_ERROR, createAndLoadUrlRequestFailed);
			BackGroundFetchService.instance.addEventListener(BackGroundFetchServiceEvent.LOAD_REQUEST_RESULT, createAndLoadUrlRequestSuccess);
		}
		
		public static function sync():void {
			myTrace("in sync");
			syncRunning = true;
			
			var authParameters:Object = new Object();
			authParameters["accountName"] = "accountname";
			authParameters["applicationId"] = "d8665ade-9673-4e27-9ff6-92db4ce13d13";
			authParameters["password"] = "accountpassword";
			BackGroundFetchService.createAndLoadUrlRequest(NON_US_SHARE_BASE_URL + "General/LoginPublisherAccountByName", URLRequestMethod.POST, null, JSON.stringify(authParameters), "application/json");
			dexcomShareStatus = dexcomShareStatus_Waiting_LoginPublisherAccountByName;
		}
		
		private static function createAndLoadUrlRequestSuccess(event:BackGroundFetchServiceEvent):void {
			if (dexcomShareStatus == dexcomShareStatus_Waiting_LoginPublisherAccountByName) {
				myTrace("in createAndLoadUrlRequestSuccess and dexcomShareStatus == dexcomShareStatus_Waiting_LoginPublisherAccountByName");
				dexcomShareSessionId = event.data.information.split('"').join('');
				uploadBGRecords();
			} else if (dexcomShareStatus == dexcomShareStatus_Waiting_PostReceiverEgvRecords) {
				myTrace("in createAndLoadUrlRequestSuccess and dexcomShareStatus == dexcomShareStatus_Waiting_PostReceiverEgvRecords");
				syncRunning = false;
			} else if (dexcomShareStatus == dexcomShareStatus_Waiting_StartRemoteMonitoringSession) {
				myTrace("in createAndLoadUrlRequestSuccess and dexcomShareStatus == dexcomShareStatus_Waiting_StartRemoteMonitoringSession");
				uploadBGRecords();
			} else if (dexcomShareStatus == dexcomShareStatus_Waiting_PostReceiverEgvRecords) {
				myTrace("in createAndLoadUrlRequestSuccess and dexcomShareStatus == dexcomShareStatus_Waiting_PostReceiverEgvRecords");
				CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_DEXCOMSHARE_SYNC_TIMESTAMP, (new Date()).valueOf().toString());
				syncRunning = false;
			}
		}
		
		private static function uploadBGRecords():void {
			dexcomShareStatus = dexcomShareStatus_Waiting_PostReceiverEgvRecords;
			myTrace("in uploadBGRecords");
			var lastSyncTimeStamp:Number = new Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_DEXCOMSHARE_SYNC_TIMESTAMP));
			var Egvs:Array = [];
			
			var cntr:int = ModelLocator.bgReadings.length - 1;
			var arrayCntr:int = 0;
			
			while (cntr > -1) {
				var bgReading:BgReading = ModelLocator.bgReadings.getItemAt(cntr) as BgReading;
				if (bgReading.timestamp > lastSyncTimeStamp) {
					if (bgReading.calculatedValue != 0) {
						var newReading:Object = new Object();
						newReading.Trend = bgReading.getSlopeOrdinal();
						newReading.ST = toDateString(bgReading.timestamp);
						newReading.DT = newReading.ST;
						newReading.Value = Math.round(bgReading.calculatedValue);

						newReading["direction"] = bgReading.slopeName();
						Egvs[arrayCntr] = newReading;
					}
				} else {
					break;
				}
				cntr--;
				arrayCntr++;
			}		
			
			if (Egvs.length > 0) {
				var uploaddata:Object = new Object();
				uploaddata.Egvs = Egvs;
				uploaddata.SN = getSerialNumber();
				uploaddata.TA = -5;
				dexcomShareStatus = dexcomShareStatus_Waiting_PostReceiverEgvRecords;
				BackgroundFetch.createAndLoadDexWithJSONDataUrlRequest(NON_US_SHARE_BASE_URL + "Publisher/PostReceiverEgvRecords",  
					URLRequestMethod.POST, 
					JSON.stringify(uploaddata),
					"sessionId", dexcomShareSessionId );
				//createAndLoadURLRequest(NON_US_SHARE_BASE_URL + "General/LoginPublisherAccountByName", URLRequestMethod.POST, null, JSON.stringify(authParameters));
			} else {
				myTrace("in uploadBGRecords, no records to upload");
				syncRunning = false;
			}
		}

		private static function createAndLoadUrlRequestFailed(event:BackGroundFetchServiceEvent):void {
			var eventDataInformation:String;
			if (event.data) {
				if (event.data.information)
					eventDataInformation = event.data.information;
			} else {
				eventDataInformation = "";
			}
			if (dexcomShareStatus == dexcomShareStatus_Waiting_PostReceiverEgvRecords) {
				if (eventDataInformation.length > 0) {
					try {
						var eventAsJSONObject:Object = JSON.parse(event.data.information as String);
						var code:String = eventAsJSONObject.Code as String;
						myTrace("in createAndLoadUrlRequestFailed and dexcomShareStatus == dexcomShareStatus_Waiting_PostReceiverEgvRecords, code = " + code);
						if (code == "MonitoringSessionNotActive") {
							dexcomShareStatus == dexcomShareStatus_Waiting_StartRemoteMonitoringSession;
							BackGroundFetchService.createAndLoadUrlRequest(NON_US_SHARE_BASE_URL + "Publisher/StartRemoteMonitoringSession?sessionId=" + 
								escape(dexcomShareSessionId) + "&serialNumber=" +
								escape(getSerialNumber()),
								URLRequestMethod.POST, 
								null,
								null,
								"application/json");
						} else if (code == "DuplicateEgvPosted") {
							myTrace("code DuplicateEgvPosted, treated as successful and setting lastsynctimestamp to current data and time");
							CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_DEXCOMSHARE_SYNC_TIMESTAMP, (new Date()).valueOf().toString());
							syncRunning = false;
						} else {
							myTrace("unknown code");
							syncRunning = false;
						}
					} catch (error:Error) {
						myTrace("in createAndLoadUrlRequestFailed, exception, error = " + error.message);
						syncRunning = false
					}
				} else {
					myTrace("in createAndLoadUrlRequestFailed, event.data.information not available");
					syncRunning = false;
				}
			} else if (dexcomShareStatus == dexcomShareStatus_Waiting_LoginPublisherAccountByName) {
				myTrace("in createAndLoadUrlRequestFailed and dexcomShareStatus == dexcomShareStatus_Waiting_LoginPublisherAccountByName, eventDataInformation = " + eventDataInformation);
				syncRunning = false;
			} else if (dexcomShareStatus == dexcomShareStatus_Waiting_StartRemoteMonitoringSession) {
				myTrace("in createAndLoadUrlRequestFailed and dexcomShareStatus == dexcomShareStatus_Waiting_StartRemoteMonitoringSession, eventDataInformation = " + eventDataInformation);
				syncRunning = false;
			}
		}
		
		private static function toDateString(timestamp:Number):String {
			var shortened:Number = Math.floor(timestamp/1000);
			return "/Date(" + (new Number(shortened * 1000)).toString() + ")/";
		}
		
		private static function getSerialNumber():String {
			return (BlueToothDevice.isDexcomG5() ? CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID) : CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_RECEIVER_SN));
		}
		
		private static function myTrace(log:String):void {
			Trace.myTrace("DexcomShareService.as", log);
		}
	}
}