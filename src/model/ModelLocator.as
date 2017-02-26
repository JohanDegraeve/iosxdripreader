/**
 Copyright (C) 2016  Johan Degraeve
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/gpl.txt>.
 
 */
package model
{
	import com.distriqt.extension.application.Application;
	import com.distriqt.extension.message.Message;
	import com.distriqt.extension.networkinfo.NetworkInfo;
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.components.Image;
	import spark.core.ContentCache;
	
	import G5Model.AuthChallengeRxMessage;
	import G5Model.AuthRequestTxMessage;
	
	import Utilities.UniqueId;
	
	import databaseclasses.BgReading;
	import databaseclasses.Database;
	import databaseclasses.LocalSettings;
	import databaseclasses.Sensor;
	
	import distriqtkey.DistriqtKey;
	
	import events.BackGroundFetchServiceEvent;
	import events.BlueToothServiceEvent;
	import events.CalibrationServiceEvent;
	import events.DatabaseEvent;
	import events.NightScoutServiceEvent;
	import events.NotificationServiceEvent;
	import events.TransmitterServiceEvent;
	
	import services.BackGroundFetchService;
	import services.BluetoothService;
	import services.CalibrationService;
	import services.NightScoutService;
	import services.NotificationService;
	import services.TimerService;
	import services.TransmitterService;
	
	import views.HomeView;

	/**
	 * holds arraylist needed for displaying etc, like bgreadings of last 24 hours, loggings, .. 
	 */
	public class ModelLocator extends EventDispatcher
	{
		[ResourceBundle("general")]
		
		private static var _instance:ModelLocator = new ModelLocator();
		private static var dataSortFieldForBGReadings:SortField;
		private static var dataSortForBGReadings:Sort;

		public static var image_calibrate_active:Image;
		public static var image_bluetooth_red:Image;
		public static var image_bluetooth_green:Image;
		public static var image_bluetooth_orange:Image
		public static var iconCache:ContentCache;

		private static var _isInForeground:Boolean = false;
		
		public const MAX_DAYS_TO_STORE_BGREADINGS_IN_MODELLOCATOR:int = 5;
		public static const DEBUG_MODE:Boolean = true;

		public static function get isInForeground():Boolean
		{
			return _isInForeground;
		}

		public static function set isInForeground(value:Boolean):void
		{
			if (_isInForeground == value)
				return;
			
			_isInForeground = value;
			if (_loggingList != null) {
				_loggingList.addItem((new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT)).getTimeStampAsString() + " ML : " + "app is " + (_isInForeground ? "":"not") + " in foreground");
				_loggingList.refresh();
				Database.insertLogging(Utilities.UniqueId.createEventId(), (new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT)).getTimeStampAsString() + " ML : " + "app is " + (_isInForeground ? "":"not") + " in foreground", (new Date()).valueOf(), (new Date()).valueOf(),null);
			}
		}

		
		public static function get instance():ModelLocator
		{
			return _instance;
		}

		private static var _resourceManagerInstance:IResourceManager;

		/**
		 * can be used anytime the resourcemanager is needed
		 */
		public static function get resourceManagerInstance():IResourceManager
		{
			return _resourceManagerInstance;
		}
		
		private static var _loggingList:ArrayCollection;

		[bindable]
		/**
		 * logging info dispatches by several components
		 */
		public static function get loggingList():ArrayCollection
		{
			return _loggingList;
		}
		
		private static var _bgReadings:ArrayCollection;

		/**
		 * last 24 hour bg readings<br>
		 * seperate method is there to add a bg reading, which will also there to clean up any items older dan 24 hours<br>
		 * there's no guarantee that there are no items older dan 24 hours<br>
		 * Sorted ascending, from small to large, ie latest element is also the last element
		 */
		public static function get bgReadings():ArrayCollection
		{
			return _bgReadings;
		}
		
		private static var _appStartTimestamp:Number;

		/**
		 * time that the application was started 
		 */
		public static function get appStartTimestamp():Number
		{
			return _appStartTimestamp;
		}
		
		public function ModelLocator()
		{
			if (_instance != null) {
				throw new Error("ModelLocator class can only be instantiated through ModelLocator.getInstance()");	
			}
			trace("Modellocator.as, instantiating modellocator");
			trace("Modellocator.as, setting ModelLocator.isInForeground = true");
			_isInForeground = true;
			
			_appStartTimestamp = (new Date()).valueOf();
			
			_resourceManagerInstance = ResourceManager.getInstance();
			//event listeners for receiving bluetooth service dand database information events and to store them in the logging
			BluetoothService.instance.addEventListener(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT,blueToothServiceInformationReceived);
			NotificationService.instance.addEventListener(NotificationServiceEvent.LOG_INFO, notificationServiceLogInfoReceived);
			Database.instance.addEventListener(DatabaseEvent.DATABASE_INFORMATION_EVENT, databaseInformationEventReceived);
			NightScoutService.instance.addEventListener(NightScoutServiceEvent.NIGHTSCOUT_SERVICE_INFORMATION_EVENT, nightScoutServiceInformationReceived);
			CalibrationService.instance.addEventListener(CalibrationServiceEvent.INITIAL_CALIBRATION_EVENT, initialCalibrationEventReceived);
			CalibrationService.instance.addEventListener(CalibrationServiceEvent.NEW_CALIBRATION_EVENT, newCalibrationEventReceived);
			BackGroundFetchService.instance.addEventListener(BackGroundFetchServiceEvent.LOG_INFO, backgroundFetchServiceLogInfoReceived);
			TransmitterService.instance.addEventListener(TransmitterServiceEvent.TRANSMITTER_SERVICE_INFORMATION_EVENT, transmitterServiceInfoReceived);

			function transmitterServiceInfoReceived(be:TransmitterServiceEvent):void {
				_loggingList.addItem(be.getTimeStampAsString() + " TR : " + be.data.information);
				_loggingList.refresh();
				Database.insertLogging(Utilities.UniqueId.createEventId(), be.getTimeStampAsString() + " TR : " + be.data.information, be.timeStamp,(new Date()).valueOf(),null); 
			}
			
			function backgroundFetchServiceLogInfoReceived(be:BackGroundFetchServiceEvent):void {
				_loggingList.addItem(be.getTimeStampAsString() + " BG : " + be.data.information);
				_loggingList.refresh();
				Database.insertLogging(Utilities.UniqueId.createEventId(), be.getTimeStampAsString() + " BG : " + be.data.information, be.timeStamp,(new Date()).valueOf(),null); 
			}
			
			function initialCalibrationEventReceived(be:CalibrationServiceEvent):void {
				_loggingList.addItem(be.getTimeStampAsString() + " CS : " + "initial calibration done");
				_loggingList.refresh();
				Database.insertLogging(Utilities.UniqueId.createEventId(), be.getTimeStampAsString() + " CS : " + "initial calibration done", be.timeStamp,(new Date()).valueOf(),null);
			}
			
			function newCalibrationEventReceived(be:CalibrationServiceEvent):void {
				_loggingList.addItem(be.getTimeStampAsString() + " CS : " + "new calibration done");
				_loggingList.refresh();
				Database.insertLogging(Utilities.UniqueId.createEventId(), be.getTimeStampAsString() + " CS : " + "new calibration done", be.timeStamp,(new Date()).valueOf(),null);
			}
			
			function nightScoutServiceInformationReceived(be:NightScoutServiceEvent):void {
				_loggingList.addItem(be.getTimeStampAsString() + " NS : " + be.data.information);
				_loggingList.refresh();
				Database.insertLogging(Utilities.UniqueId.createEventId(), be.getTimeStampAsString() + " NS : " + be.data.information, be.timeStamp,(new Date()).valueOf(),null);				
			}
			
			function databaseInformationEventReceived(be:DatabaseEvent):void {
				_loggingList.addItem(be.getTimeStampAsString() + " DB : " + be.data.information);
				_loggingList.refresh();
				Database.insertLogging(Utilities.UniqueId.createEventId(), be.getTimeStampAsString() + " DB : " + be.data.information, be.timeStamp,(new Date()).valueOf(),null);				
			}
			
			function blueToothServiceInformationReceived(be:BlueToothServiceEvent):void {
				_loggingList.addItem(be.getTimeStampAsString() + " BT : " + be.data.information);
				_loggingList.refresh();
				//Database.insertLogging(Utilities.UniqueId.createEventId(),be.getTimeStampAsString() + " BT : " + be.data.information, be.timeStamp,(new Date()).valueOf(),null);
			}
			
			function notificationServiceLogInfoReceived(be:NotificationServiceEvent):void {
				//_loggingList.addItem(be.getTimeStampAsString() + " NI : " + be.data.information);
				//_loggingList.refresh();
				//Database.insertLogging(Utilities.UniqueId.createEventId(), be.getTimeStampAsString() + " NI : " + be.data.information, be.timeStamp,(new Date()).valueOf(),null);
			}
			
			//create the logging list and bgreading list and assign a sorting - but don't get the logs from the database yet because maybe the database init is not finished yet
			//sorting is alphabetical, which should result in chronologial order because every stored text will begin with a timestamp.
			var dataSortField:SortField= new SortField();
			dataSortField.numeric = false;
			var dataSort:Sort = new Sort();
			dataSort.fields=[dataSortField];
			_loggingList = new ArrayCollection();
			_loggingList.sort = dataSort;
			
			//bgreadings arraycollection
			_bgReadings = new ArrayCollection();
			dataSortFieldForBGReadings = new SortField();
			dataSortFieldForBGReadings.name = "timestamp";
			dataSortFieldForBGReadings.numeric = true;
			dataSortFieldForBGReadings.descending = false;//ie ascending = from small to large
			dataSortForBGReadings = new Sort();
			dataSortForBGReadings.fields=[dataSortFieldForBGReadings];
			_bgReadings.sort = dataSortForBGReadings;
			Database.instance.addEventListener(DatabaseEvent.DATABASE_INIT_FINISHED_EVENT,getBgReadingsAndLogsFromDatabase);
						
			function getBgReadingsAndLogsFromDatabase():void {
				Database.instance.addEventListener(DatabaseEvent.BGREADING_RETRIEVAL_EVENT, bgReadingReceivedFromDatabase);
				//bgreadings created after app start time are not needed because they are already stored in the _bgReadings by the transmitter service
				Database.getBgReadings(_appStartTimestamp);
				
				//for an unknown reasy _isInForeground is back to value false here, so setting it to true.
				isInForeground = true;
			}

			function bgReadingReceivedFromDatabase(de:DatabaseEvent):void {
				if (de.data != null)
					if (de.data is BgReading) {
						if ((de.data as BgReading).timestamp > ((new Date()).valueOf() - MAX_DAYS_TO_STORE_BGREADINGS_IN_MODELLOCATOR * 24 * 60 * 60 * 1000)) {
							_bgReadings.addItem(de.data);
						}
					} else if (de.data is String) {
						if (de.data as String == Database.END_OF_RESULT) {
							_bgReadings.refresh();
							getLogsFromDatabase();
							if (_bgReadings.length < 2) {
								if (Sensor.getActiveSensor() != null) {
									//sensor is active but there's less than two bgreadings, this may happen exceptionally if was started previously but not used for exactly or more than  MAX_DAYS_TO_STORE_BGREADINGS_IN_MODELLOCATOR days
									Sensor.stopSensor();
								}
							}
						}
					}
			}

			//get stored logs from the database
			function getLogsFromDatabase():void {
				Database.instance.addEventListener(DatabaseEvent.LOGRETRIEVED_EVENT, logReceivedFromDatabase);
				//logs created after app start time are not needed because they are already added in the logginglist
				Database.getLoggings(_appStartTimestamp);
			}
			
			function logReceivedFromDatabase(de:DatabaseEvent):void {
				if (de.data != null)
					if (de.data is String) {
						if (de.data as String == Database.END_OF_RESULT) {
							_loggingList.refresh();

							//now is the time to start the bluetoothservice because as soon as this service is started, 
							//new bgreadings may come in, being created synchronously in the database, there should be no more async transactions in the database

							//will initialise the bluetoothdevice
							Database.getBlueToothDevice();24 *24
							Application.init(DistriqtKey.distriqtKey);
							if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_UDID) == "")
								LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_UDID, Application.service.device.uniqueId("vendor", true));
							//trace("unique device id = " + LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_UDID));
							Message.init(DistriqtKey.distriqtKey);
							TransmitterService.init();
							BluetoothService.init();

							NotificationService.instance.addEventListener(NotificationServiceEvent.NOTIFICATION_SERVICE_INITIATED_EVENT, HomeView.notificationServiceInitiated);
							NotificationService.init();
							
							CalibrationService.init();
							TimerService.init();
							NetworkInfo.init(DistriqtKey.distriqtKey);
							BackGroundFetchService.init();
							
							/*var testString:String = "03B324D1AA8A308A8A9DD27650ACD7BF20";
							var testbytearray:ByteArray = UniqueId.hexStringToByteArray(testString);
							testbytearray.position = 0;
							
							var authRequest:AuthRequestTxMessage = null;
							
							var authChallenge:AuthChallengeRxMessage = new AuthChallengeRxMessage(testbytearray);
							trace("AuthChallengeRxMessage created, tokenHash = " + UniqueId.byteArrayToString(authChallenge.tokenHash));
							trace("AuthChallengeRxMessage created, challenge = " + UniqueId.byteArrayToString(authChallenge.challenge));
							if (authRequest == null) {
								authRequest = new AuthRequestTxMessage(8);
							}
							trace("authrequest.singleUseToken = " + UniqueId.byteArrayToString(authRequest.singleUseToken));
							var key:ByteArray = BluetoothService.cryptKey();
							trace("key = " + UniqueId.byteArrayToString(key));
							var challengeHash:ByteArray = BluetoothService.calculateHash(authChallenge.challenge);
							trace("challengeHash = " + UniqueId.byteArrayToString(challengeHash));
							trace("should be  challenge hash[-55, 56, 32, 37, 116, -103, 78, 12]");*/

							NightScoutService.init();
							NightScoutService.sync(null);
						} else {
							_loggingList.addItem(de.data as String);
						}
					}
			}
			
			iconCache = new ContentCache();
			iconCache.enableCaching = true;
			iconCache.enableQueueing = true;
			
			image_calibrate_active = new Image();
			image_calibrate_active.contentLoader = iconCache;
			image_calibrate_active.source = '../assets/image_calibrate_active.png';
			
			image_bluetooth_red = new Image();
			image_bluetooth_red.contentLoader = iconCache;
			image_bluetooth_red.source = "../assets/image_bluetooth_red.png";
			
			image_bluetooth_orange = new Image();
			image_bluetooth_orange.contentLoader = iconCache;
			image_bluetooth_orange.source = "../assets/image_bluetooth_orange.png";
			
			image_bluetooth_green = new Image();
			image_bluetooth_green.contentLoader = iconCache;
			image_bluetooth_green.source = "../assets/image_bluetooth_green.png";
		}
		
		private static function coreEvent(event:Event):void {
			var test:int = 0;
			test++;
		}
		
		/**
		 * add bgreading also removes bgreadings olther than 24 hours but keeps at least 5
		 */
		public static function addBGReading(bgReading:BgReading):void {
			_bgReadings.addItem(bgReading);
			_bgReadings.refresh();
			
			if (_bgReadings.length <= 5)
				return;
			
			var firstBGReading:BgReading = _bgReadings.getItemAt(0) as BgReading;
			var now:Number = (new Date()).valueOf();
			while (now - firstBGReading.timestamp > 24 * 3600 * 1000) {
				_bgReadings.removeItemAt(0);
				if (_bgReadings.length <= 5)
					break;
				firstBGReading = _bgReadings.getItemAt(0) as BgReading;
			}
		}
	}
}