package services
{
	import com.distriqt.extension.application.Application;
	import com.distriqt.extension.application.events.ApplicationStateEvent;
	import com.distriqt.extension.dialog.Dialog;
	import com.distriqt.extension.dialog.DialogView;
	import com.distriqt.extension.dialog.builders.PickerDialogBuilder;
	import com.distriqt.extension.dialog.events.DialogViewEvent;
	import com.distriqt.extension.notifications.NotificationRepeatInterval;
	import com.distriqt.extension.notifications.Notifications;
	import com.distriqt.extension.notifications.builders.NotificationBuilder;
	import com.distriqt.extension.notifications.events.NotificationEvent;
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetchEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.TabbedViewNavigator;
	import spark.transitions.FlipViewTransition;
	
	import Utilities.DateTimeUtilities;
	import Utilities.FromtimeAndValueArrayCollection;
	import Utilities.Trace;
	
	import databaseclasses.AlertType;
	import databaseclasses.BgReading;
	import databaseclasses.BlueToothDevice;
	import databaseclasses.Calibration;
	import databaseclasses.CommonSettings;
	import databaseclasses.Database;
	import databaseclasses.Sensor;
	
	import events.BlueToothServiceEvent;
	import events.IosXdripReaderEvent;
	import events.NotificationServiceEvent;
	import events.SettingsServiceEvent;
	import events.TransmitterServiceEvent;
	
	import model.ModelLocator;
	
	import views.PickerView;
	
	public class AlarmService extends EventDispatcher
	{
		[ResourceBundle("alarmservice")]
		
		private static var initialStart:Boolean = true;
		private static var _instance:AlarmService = new AlarmService(); 
		
		//low alert
		/**
		 * 0 is not snoozed, if > 0 this is snooze value chosen by user
		 */
		private static var _lowAlertSnoozePeriodInMinutes:int = 0;
		/**
		 * timestamp when alert was snoozed, ms 
		 */
		private static var _lowAlertLatestSnoozeTimeInMs:Number = Number.NaN;
		/**
		 * timestamp of latest notification 
		 */
		private static var _lowAlertLatestNotificationTime:Number = Number.NaN;
		
		//verylow alert
		/**
		 * 0 is not snoozed, if > 0 this is snooze value chosen by user
		 */
		private static var _veryLowAlertSnoozePeriodInMinutes:int = 0;
		/**
		 * timestamp when alert was snoozed, ms 
		 */
		private static var _veryLowAlertLatestSnoozeTimeInMs:Number = Number.NaN;
		/**
		 * timestamp of latest notification 
		 */
		private static var _veryLowAlertLatestNotificationTime:Number = Number.NaN;
		
		//high alert
		/**
		 * 0 is not snoozed, if > 0 this is snooze value chosen by user
		 */
		private static var _highAlertSnoozePeriodInMinutes:int = 0;
		/**
		 * timestamp when alert was snoozed, ms 
		 */
		private static var _highAlertLatestSnoozeTimeInMs:Number = Number.NaN;
		/**
		 * timestamp of latest notification 
		 */
		private static var _highAlertLatestNotificationTime:Number = Number.NaN;
		
		//very high alert
		/**
		 * 0 is not snoozed, if > 0 this is snooze value chosen by user
		 */
		private static var _veryHighAlertSnoozePeriodInMinutes:int = 0;
		/**
		 * timestamp when alert was snoozed, ms 
		 */
		private static var _veryHighAlertLatestSnoozeTimeInMs:Number = Number.NaN;
		/**
		 * timestamp of latest notification 
		 */
		private static var _veryHighAlertLatestNotificationTime:Number = Number.NaN;
		
		/**
		 * if lastbgreading is older than MAX_AGE_OF_READING_IN_MINUTES minutes, then no low or high alert will be generated  
		 */
		public static const MAX_AGE_OF_READING_IN_MINUTES:int = 15
		
		//batteryLevel alert
		/**
		 * 0 is not snoozed, if > 0 this is snooze value chosen by user
		 */
		private static var _batteryLevelAlertSnoozePeriodInMinutes:int = 0;
		/**
		 * timestamp when alert was snoozed, ms 
		 */
		private static var _batteryLevelAlertLatestSnoozeTimeInMs:Number = Number.NaN;
		/**
		 * timestamp of latest notification 
		 */
		private static var _batteryLevelAlertLatestNotificationTime:Number = Number.NaN;
		
		//missed reading
		/**
		 * 0 is not snoozed, if > 0 this is snooze value chosen by user
		 */
		private static var _missedReadingAlertSnoozePeriodInMinutes:int = 0;
		/**
		 * timestamp when alert was snoozed, ms 
		 */
		private static var _missedReadingAlertLatestSnoozeTimeInMs:Number = Number.NaN;
		/**
		 * timestamp of latest notification 
		 */
		private static var _missedReadingAlertLatestNotificationTime:Number = Number.NaN;
		
		//phone muted
		/**
		 * 0 is not snoozed, if > 0 this is snooze value chosen by user
		 */
		private static var _phoneMutedAlertSnoozePeriodInMinutes:int = 0;
		/**
		 * timestamp when alert was snoozed, ms 
		 */
		private static var _phoneMutedAlertLatestSnoozeTimeInMs:Number = Number.NaN;
		/**
		 * timestamp of latest notification 
		 */
		private static var _phoneMutedAlertLatestNotificationTime:Number = Number.NaN;
		
		//calibration request
		/**
		 * 0 is not snoozed, if > 0 this is snooze value chosen by user
		 */
		private static var _calibrationRequestSnoozePeriodInMinutes:int = 0;
		/**
		 * timestamp when alert was snoozed, ms 
		 */
		private static var _calibrationRequestLatestSnoozeTimeInMs:Number = Number.NaN;
		/**
		 * timestamp of latest notification 
		 */
		private static var _calibrationRequestLatestNotificationTime:Number = Number.NaN;
		
		private static var checkMissedReadingAlertTimer:Timer;
		
		private static var missedReadingSnoozePickerOpen:Boolean;
		
		private static var snoozeValueMinutes:Array = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 75, 90, 120, 150, 180, 240, 300, 360, 420, 480, 540, 600, 1440, 10080];
		private static var snoozeValueStrings:Array = ["5 minutes", "10 minutes", "15 minutes", "20 minutes", "25 minutes", "30 minutes", "35 minutes",
			"40 minutes", "45 minutes", "50 minutes", "55 minutes", "1 hour", "1 hour 15 minutes", "1,5 hours", "2 hours", "2,5 hours", "3 hours", "4 hours",
			"5 hours", "6 hours", "7 hours", "8 hours", "9 hours", "10 hours", "1 day", "1 week"];
		
		private static var lastAlarmCheckTimeStamp:Number;
		private static var lastPhoneMuteAlarmCheckTimeStamp:Number;
		private static var latestAlertTypeUsedInMissedReadingNotification:AlertType;
		
		public static function get instance():AlarmService {
			return _instance;
		}
		
		public function AlarmService() {
			if (_instance != null) {
				throw new Error("AlarmService class constructor can not be used");	
			}
		}
		
		public static function init():void {
			if (!initialStart)
				return;
			else
				initialStart = false;
			
			lastPhoneMuteAlarmCheckTimeStamp = new Number(0);
			TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, checkAlarms);
			NotificationService.instance.addEventListener(NotificationServiceEvent.NOTIFICATION_EVENT, notificationReceived);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.PERFORMREMOTEFETCH, checkAlarmsAfterPerformFetch);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.PHONE_MUTED, phoneMuted);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.PHONE_NOT_MUTED, phoneNotMuted);
			BluetoothService.instance.addEventListener(BlueToothServiceEvent.CHARACTERISTIC_UPDATE, characteristicUpdate);
			CommonSettings.instance.addEventListener(SettingsServiceEvent.SETTING_CHANGED, settingChanged);
			if (Application.isSupported) {
				Application.service.addEventListener(ApplicationStateEvent.DEACTIVATE, application_deactivateHandler);
			}
			iosxdripreader.instance.addEventListener(IosXdripReaderEvent.APP_IN_FOREGROUND, appInForeGround);
			
			lastAlarmCheckTimeStamp = 0;
			
			for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
				snoozeValueStrings[cntr] = (snoozeValueStrings[cntr] as String).replace("minutes", ModelLocator.resourceManagerInstance.getString("alarmservice","minutes"));
				snoozeValueStrings[cntr] = (snoozeValueStrings[cntr] as String).replace("hour", ModelLocator.resourceManagerInstance.getString("alarmservice","hour"));
				snoozeValueStrings[cntr] = (snoozeValueStrings[cntr] as String).replace("hours", ModelLocator.resourceManagerInstance.getString("alarmservice","hours"));
				snoozeValueStrings[cntr] = (snoozeValueStrings[cntr] as String).replace("day", ModelLocator.resourceManagerInstance.getString("alarmservice","day"));
				snoozeValueStrings[cntr] = (snoozeValueStrings[cntr] as String).replace("week", ModelLocator.resourceManagerInstance.getString("alarmservice","week"));
			}
			
			//immediately check missedreading alerts
			checkMissedReadingAlert(new Date(), true);
			myTrace("in init, calling appInForeGround");
			appInForeGround();
		}
		
		public static function appInForeGround(event:Event = null):void {
			myTrace("in appInForeGround, calling checkMissedReadingAlert");
			checkMissedReadingAlert(new Date(), true);
			myTrace("starting checkMissedReadingAlertTimer with delay = 6 minutes, indefinitely");
			checkMissedReadingAlertTimer = new Timer(6 * 60 * 1000, 0);
			checkMissedReadingAlertTimer.addEventListener(TimerEvent.TIMER, checkMissedReadingAlertTimerExpiry);
			checkMissedReadingAlertTimer.start();
		}
		
		private static function checkMissedReadingAlertTimerExpiry(event:Event = null):void {
			myTrace("in checkMissedReadingAlertTimerExpiry, calling checkMissedReadingAlert");
			checkMissedReadingAlert(new Date(), true);
		}
		
		private static function application_deactivateHandler(event:ApplicationStateEvent):void {
			myTrace("in application_deactivateHandler, event.code = " + event.code);
			switch (event.code) 
			{
				case ApplicationStateEvent.CODE_LOCK:
				case ApplicationStateEvent.CODE_HOME:
					if (checkMissedReadingAlertTimer != null) {
						if (checkMissedReadingAlertTimer.running) {
							myTrace("stopping checkMissedReadingAlertTimer because it will not expire when app is in brackground");
							checkMissedReadingAlertTimer.stop();
						}
						checkMissedReadingAlertTimer = null;
					}
					break;
			}
		}
		
		private static function characteristicUpdate(event:Event):void {
			if (!BlueToothDevice.alwaysScan())
				BackgroundFetch.checkMuted();
		}
		
		
		private static function notificationReceived(event:NotificationServiceEvent):void {
			myTrace("in notificationReceived");
			if (event != null) {
				var listOfAlerts:FromtimeAndValueArrayCollection;
				var alertName:String ;
				var alertType:AlertType;
				var index:int;
				var flipTrans:FlipViewTransition = new FlipViewTransition(); 
				flipTrans.duration = 0;
				
				(ModelLocator.navigator.parentNavigator as TabbedViewNavigator).selectedIndex = 0;
				//((ModelLocator.navigator.parentNavigator as TabbedViewNavigator).navigators[0] as ViewNavigator).popToFirstView();
				
				var notificationEvent:NotificationEvent = event.data as NotificationEvent;
				myTrace("in notificationReceived, event != null, id = " + NotificationService.notificationIdToText(notificationEvent.id));
				if (notificationEvent.id == NotificationService.ID_FOR_LOW_ALERT) {
					var now:Date = new Date();
					if ((now.valueOf() - _lowAlertLatestSnoozeTimeInMs) > _lowAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_lowAlertLatestSnoozeTimeInMs)) {
						listOfAlerts = FromtimeAndValueArrayCollection.createList(
							CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_LOW_ALERT), true);
						alertName = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
						alertType = Database.getAlertType(alertName);
						myTrace("in notificationReceived with id = ID_FOR_LOW_ALERT, cancelling notification");
						myTrace("cancel any existing alert for ID_FOR_LOW_ALERT");
						Notifications.service.cancel(NotificationService.ID_FOR_LOW_ALERT);
						index = 0;
						for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
							if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
								index = cntr;
								break;
							}
						}
						if (notificationEvent.identifier == null) {
							var snoozePeriodPicker1:DialogView;
							snoozePeriodPicker1 = Dialog.service.create(
								new PickerDialogBuilder()
								.setTitle("")
								.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
								.setAcceptLabel("Ok")
								.addColumn( snoozeValueStrings, index )
								.build()
							);
							snoozePeriodPicker1.addEventListener( DialogViewEvent.CLOSED, lowSnoozePicker_closedHandler );
							var dataToSend:Object = new Object();
							dataToSend.picker = snoozePeriodPicker1;
							dataToSend.pickertext = ModelLocator.resourceManagerInstance.getString("alarmservice","snooze_text_low_alert");
							myTrace("adding PickerView");
							ModelLocator.navigator.pushView(PickerView, dataToSend, null, flipTrans);
						} else if (notificationEvent.identifier == NotificationService.ID_FOR_LOW_ALERT_SNOOZE_IDENTIFIER) {
							_lowAlertSnoozePeriodInMinutes = alertType.defaultSnoozePeriodInMinutes;
							myTrace("in notificationReceived with id = ID_FOR_LOW_ALERT, snoozing the notification for " + _lowAlertSnoozePeriodInMinutes + " minutes");
							_lowAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
						}
					} else {
						myTrace("in checkAlarms, alarm snoozed, _lowAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_lowAlertLatestSnoozeTimeInMs)) + ", _lowAlertSnoozePeriodInMinutes = " + _lowAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				} else if (notificationEvent.id == NotificationService.ID_FOR_HIGH_ALERT) {
					var now:Date = new Date();
					if ((now.valueOf() - _highAlertLatestSnoozeTimeInMs) > _highAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_highAlertLatestSnoozeTimeInMs)) {
						listOfAlerts = FromtimeAndValueArrayCollection.createList(
							CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_HIGH_ALERT), true);
						alertName = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
						alertType = Database.getAlertType(alertName);
						myTrace("in notificationReceived with id = ID_FOR_HIGH_ALERT, cancelling notification");
						myTrace("cancel any existing alert for ID_FOR_HIGH_ALERT");
						Notifications.service.cancel(NotificationService.ID_FOR_HIGH_ALERT);
						index = 0;
						for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
							if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
								index = cntr;
								break;
							}
						}
						if (notificationEvent.identifier == null) {
							var snoozePeriodPicker2:DialogView;
							snoozePeriodPicker2 = Dialog.service.create(
								new PickerDialogBuilder()
								.setTitle("")
								.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
								.setAcceptLabel("Ok")
								.addColumn( snoozeValueStrings, index )
								.build()
							);
							snoozePeriodPicker2.addEventListener( DialogViewEvent.CLOSED, highSnoozePicker_closedHandler );
							var dataToSend:Object = new Object();
							dataToSend.picker = snoozePeriodPicker2;
							dataToSend.pickertext = ModelLocator.resourceManagerInstance.getString("alarmservice","snooze_text_high_alert");
							ModelLocator.navigator.pushView(PickerView, dataToSend, null, flipTrans);
						} else if (notificationEvent.identifier == NotificationService.ID_FOR_HIGH_ALERT_SNOOZE_IDENTIFIER) {
							_highAlertSnoozePeriodInMinutes = alertType.defaultSnoozePeriodInMinutes;
							myTrace("in notificationReceived with id = ID_FOR_HIGH_ALERT, snoozing the notification for " + _highAlertSnoozePeriodInMinutes + " minutes");
							_highAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
						}
					} else {
						myTrace("in checkAlarms, alarm snoozed, _highAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_highAlertLatestSnoozeTimeInMs)) + ", _highAlertSnoozePeriodInMinutes = " + _highAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				} else if (notificationEvent.id == NotificationService.ID_FOR_VERY_LOW_ALERT) {
					var now:Date = new Date();
					if ((now.valueOf() - _veryLowAlertLatestSnoozeTimeInMs) > _veryLowAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_veryLowAlertLatestSnoozeTimeInMs)) {
						listOfAlerts = FromtimeAndValueArrayCollection.createList(
							CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_VERY_LOW_ALERT), true);
						alertName = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
						alertType = Database.getAlertType(alertName);
						myTrace("in notificationReceived with id = ID_FOR_VERY_LOW_ALERT, cancelling notification");
						myTrace("cancel any existing alert for ID_FOR_VERY_LOW_ALERT");
						Notifications.service.cancel(NotificationService.ID_FOR_VERY_LOW_ALERT);
						index = 0;
						for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
							if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
								index = cntr;
								break;
							}
						}
						if (notificationEvent.identifier == null) {
							var snoozePeriodPicker7:DialogView;
							snoozePeriodPicker7 = Dialog.service.create(
								new PickerDialogBuilder()
								.setTitle("")
								.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
								.setAcceptLabel("Ok")
								.addColumn( snoozeValueStrings, index )
								.build()
							);
							snoozePeriodPicker7.addEventListener( DialogViewEvent.CLOSED, veryLowSnoozePicker_closedHandler );
							var dataToSend:Object = new Object();
							dataToSend.picker = snoozePeriodPicker7;
							dataToSend.pickertext = ModelLocator.resourceManagerInstance.getString("alarmservice","snooze_text_very_low_alert");
							myTrace("adding PickerView");
							ModelLocator.navigator.pushView(PickerView, dataToSend, null, flipTrans);
						} else if (notificationEvent.identifier == NotificationService.ID_FOR_VERY_LOW_ALERT_SNOOZE_IDENTIFIER) {
							_veryLowAlertSnoozePeriodInMinutes = alertType.defaultSnoozePeriodInMinutes;
							myTrace("in notificationReceived with id = ID_FOR_VERY_LOW_ALERT, snoozing the notification for " + _veryLowAlertSnoozePeriodInMinutes + " minutes");
							_veryLowAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
						}
					} else {
						myTrace("in checkAlarms, alarm snoozed, _veryLowAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_veryLowAlertLatestSnoozeTimeInMs)) + ", _veryLowAlertSnoozePeriodInMinutes = " + _veryLowAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				} else if (notificationEvent.id == NotificationService.ID_FOR_VERY_HIGH_ALERT) {
					var now:Date = new Date();
					if ((now.valueOf() - _veryHighAlertLatestSnoozeTimeInMs) > _veryHighAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_veryHighAlertLatestSnoozeTimeInMs)) {
						listOfAlerts = FromtimeAndValueArrayCollection.createList(
							CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_VERY_HIGH_ALERT), true);
						alertName = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
						alertType = Database.getAlertType(alertName);
						myTrace("in notificationReceived with id = ID_FOR_VERY_HIGH_ALERT, cancelling notification");
						myTrace("cancel any existing alert for ID_FOR_VERY_HIGH_ALERT");
						Notifications.service.cancel(NotificationService.ID_FOR_VERY_HIGH_ALERT);
						index = 0;
						for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
							if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
								index = cntr;
								break;
							}
						}
						if (notificationEvent.identifier == null) {
							var snoozePeriodPicker8:DialogView;
							snoozePeriodPicker8 = Dialog.service.create(
								new PickerDialogBuilder()
								.setTitle("")
								.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
								.setAcceptLabel("Ok")
								.addColumn( snoozeValueStrings, index )
								.build()
							);
							snoozePeriodPicker8.addEventListener( DialogViewEvent.CLOSED, veryHighSnoozePicker_closedHandler );
							var dataToSend:Object = new Object();
							dataToSend.picker = snoozePeriodPicker8;
							dataToSend.pickertext = ModelLocator.resourceManagerInstance.getString("alarmservice","snooze_text_very_high_alert");
							ModelLocator.navigator.pushView(PickerView, dataToSend, null, flipTrans);
						} else if (notificationEvent.identifier == NotificationService.ID_FOR_VERY_HIGH_ALERT_SNOOZE_IDENTIFIER) {
							_veryHighAlertSnoozePeriodInMinutes = alertType.defaultSnoozePeriodInMinutes;
							myTrace("in notificationReceived with id = ID_FOR_VERY_HIGH_ALERT, snoozing the notification for " + _veryHighAlertSnoozePeriodInMinutes + " minutes");
							_veryHighAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
						}
					} else {
						myTrace("in checkAlarms, alarm snoozed, _veryHighAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_veryHighAlertLatestSnoozeTimeInMs)) + ", _veryHighAlertSnoozePeriodInMinutes = " + _veryHighAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				} else if (notificationEvent.id == NotificationService.ID_FOR_MISSED_READING_ALERT) {
					
					listOfAlerts = FromtimeAndValueArrayCollection.createList(
						CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_MISSED_READING_ALERT), false);
					alertName = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
					alertType = Database.getAlertType(alertName);
					myTrace("in notificationReceived with id = ID_FOR_MISSED_READING_ALERT, cancelling notification");
					myTrace("cancel any existing alert for ID_FOR_MISSED_READING_ALERT");
					Notifications.service.cancel(NotificationService.ID_FOR_MISSED_READING_ALERT);
					index = 0;
					for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
						if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
							index = cntr;
							break;
						}
					}
					if (notificationEvent.identifier == null && !missedReadingSnoozePickerOpen) {
						var snoozePeriodPicker3:DialogView;
						snoozePeriodPicker3 = Dialog.service.create(
							new PickerDialogBuilder()
							.setTitle("")
							.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
							.setAcceptLabel("Ok")
							.addColumn( snoozeValueStrings, index )
							.build()
						);
						snoozePeriodPicker3.addEventListener( DialogViewEvent.CLOSED, missedReadingSnoozePicker_closedHandler );
						//also interested when user cancels the snooze picker because in that case the missed reading alert needs to be replanned
						snoozePeriodPicker3.addEventListener( DialogViewEvent.CANCELLED, missedReadingSnoozePicker_canceledHandler );
						var dataToSend:Object = new Object();
						dataToSend.picker = snoozePeriodPicker3;
						dataToSend.pickertext = ModelLocator.resourceManagerInstance.getString("alarmservice","snooze_text_missed_reading_alert");
						ModelLocator.navigator.pushView(PickerView, dataToSend, null, flipTrans);
						missedReadingSnoozePickerOpen = true;
					}
				} else if (notificationEvent.id == NotificationService.ID_FOR_PHONEMUTED_ALERT) {
					var now:Date = new Date();
					if ((now.valueOf() - _phoneMutedAlertLatestSnoozeTimeInMs) > _phoneMutedAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_phoneMutedAlertLatestSnoozeTimeInMs)) {
						listOfAlerts = FromtimeAndValueArrayCollection.createList(
							CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_PHONE_MUTED_ALERT), false);
						alertName = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
						alertType = Database.getAlertType(alertName);
						myTrace("in notificationReceived with id = ID_FOR_PHONEMUTED_ALERT, cancelling notification");
						myTrace("cancel any existing alert for ID_FOR_PHONEMUTED_ALERT");
						Notifications.service.cancel(NotificationService.ID_FOR_PHONEMUTED_ALERT);
						index = 0;
						for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
							if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
								index = cntr;
								break;
							}
						}
						if (notificationEvent.identifier == null) {
							var snoozePeriodPicker4:DialogView;
							snoozePeriodPicker4 = Dialog.service.create(
								new PickerDialogBuilder()
								.setTitle("")
								.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
								.setAcceptLabel("Ok")
								.addColumn( snoozeValueStrings, index )
								.build()
							);
							snoozePeriodPicker4.addEventListener( DialogViewEvent.CLOSED, phoneMutedSnoozePicker_closedHandler );
							var dataToSend:Object = new Object();
							dataToSend.picker = snoozePeriodPicker4;
							dataToSend.pickertext = ModelLocator.resourceManagerInstance.getString("alarmservice","snooze_text_phone_muted_alert");
							ModelLocator.navigator.pushView(PickerView, dataToSend, null, flipTrans);
						} else if (notificationEvent.identifier == NotificationService.ID_FOR_PHONE_MUTED_SNOOZE_IDENTIFIER) {
							_phoneMutedAlertSnoozePeriodInMinutes = alertType.defaultSnoozePeriodInMinutes;
							myTrace("in notificationReceived with id = ID_FOR_PHONEMUTED_ALERT, snoozing the notification for " + _phoneMutedAlertSnoozePeriodInMinutes + " minutes");
							_phoneMutedAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
						}
					} else {
						myTrace("in checkAlarms, alarm snoozed, _phoneMutedAlertLatestSnoozeTimeInMs = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_phoneMutedAlertLatestSnoozeTimeInMs)) + ", _phoneMutedAlertSnoozePeriodInMinutes = " + _phoneMutedAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				} else if (notificationEvent.id == NotificationService.ID_FOR_BATTERY_ALERT) {
					var now:Date = new Date();
					if ((now.valueOf() - _batteryLevelAlertLatestSnoozeTimeInMs) > _batteryLevelAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_batteryLevelAlertLatestSnoozeTimeInMs)) {
						listOfAlerts = FromtimeAndValueArrayCollection.createList(
							CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BATTERY_ALERT), false);
						alertName = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
						alertType = Database.getAlertType(alertName);
						myTrace("in notificationReceived with id = ID_FOR_BATTERY_ALERT, cancelling notification");
						myTrace("cancel any existing alert for ID_FOR_BATTERY_ALERT");
						Notifications.service.cancel(NotificationService.ID_FOR_BATTERY_ALERT);
						index = 0;
						for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
							if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
								index = cntr;
								break;
							}
						}
						if (notificationEvent.identifier == null) {
							var snoozePeriodPicker4:DialogView;
							snoozePeriodPicker4 = Dialog.service.create(
								new PickerDialogBuilder()
								.setTitle("")
								.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
								.setAcceptLabel("Ok")
								.addColumn( snoozeValueStrings, index )
								.build()
							);
							snoozePeriodPicker4.addEventListener( DialogViewEvent.CLOSED, batteryLevelSnoozePicker_closedHandler );
							var dataToSend:Object = new Object();
							dataToSend.picker = snoozePeriodPicker4;
							dataToSend.pickertext = ModelLocator.resourceManagerInstance.getString("alarmservice","snooze_text_battery_alert");
							ModelLocator.navigator.pushView(PickerView, dataToSend, null, flipTrans);
						} else if (notificationEvent.identifier == NotificationService.ID_FOR_BATTERY_LEVEL_ALERT_SNOOZE_IDENTIFIER) {
							_batteryLevelAlertSnoozePeriodInMinutes = alertType.defaultSnoozePeriodInMinutes;
							myTrace("in notificationReceived with id = ID_FOR_BATTERY_ALERT, snoozing the notification for " + _batteryLevelAlertSnoozePeriodInMinutes + " minutes");
							_batteryLevelAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
						}
					} else {
						myTrace("in checkAlarms, alarm snoozed, _batteryLevelAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_batteryLevelAlertLatestSnoozeTimeInMs)) + ", _batteryLevelAlertSnoozePeriodInMinutes = " + _batteryLevelAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				} else if (notificationEvent.id == NotificationService.ID_FOR_CALIBRATION_REQUEST_ALERT) {
					var now:Date = new Date();
					if ((now.valueOf() - _calibrationRequestLatestSnoozeTimeInMs) > _calibrationRequestSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_calibrationRequestLatestSnoozeTimeInMs)) {
						listOfAlerts = FromtimeAndValueArrayCollection.createList(
							CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CALIBRATION_REQUEST_ALERT), false);
						alertName = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
						alertType = Database.getAlertType(alertName);
						myTrace("in notificationReceived with id = ID_FOR_CALIBRATION_REQUEST_ALERT, cancelling notification");
						myTrace("cancel any existing alert for ID_FOR_CALIBRATION_REQUEST_ALERT");
						Notifications.service.cancel(NotificationService.ID_FOR_CALIBRATION_REQUEST_ALERT);
						index = 0;
						for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
							if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
								index = cntr;
								break;
							}
						}
						if (notificationEvent.identifier == null) {
							CalibrationService.calibrationOnRequest(false, false, true, snoozeCalibrationRequest);
						} else if (notificationEvent.identifier == NotificationService.ID_FOR_CALIBRATION_REQUEST_ALERT_SNOOZE_IDENTIFIER) {
							_calibrationRequestSnoozePeriodInMinutes = alertType.defaultSnoozePeriodInMinutes;
							myTrace("in notificationReceived with id = ID_FOR_CALIBRATION_REQUEST_ALERT, snoozing the notification for " + _calibrationRequestSnoozePeriodInMinutes + " minutes");
							_calibrationRequestLatestSnoozeTimeInMs = (new Date()).valueOf();
						}
					} else {
						myTrace("in checkAlarms, alarm snoozed, _calibrationRequestLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_calibrationRequestLatestSnoozeTimeInMs)) + ", _calibrationRequestSnoozePeriodInMinutes = " + _calibrationRequestSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				}
			}
			
			function snoozeCalibrationRequest():void {
				myTrace("in snoozeCalibrationRequest");
				var snoozePeriodPicker5:DialogView;
				snoozePeriodPicker5 = Dialog.service.create(
					new PickerDialogBuilder()
					.setTitle("")
					.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
					.setAcceptLabel("Ok")
					.addColumn( snoozeValueStrings, index )
					.build()
				);
				snoozePeriodPicker5.addEventListener( DialogViewEvent.CLOSED, calibrationRequestSnoozePicker_closedHandler );
				var dataToSend:Object = new Object();
				dataToSend.picker = snoozePeriodPicker5;
				dataToSend.pickertext = ModelLocator.resourceManagerInstance.getString("alarmservice","snooze_text_calibration_alert");
				ModelLocator.navigator.pushView(PickerView, dataToSend, null, flipTrans);
			}
			
			function calibrationRequestSnoozePicker_closedHandler(event:DialogViewEvent): void {
				myTrace("in calibrationRequestSnoozePicker_closedHandler snoozing the notification for " + snoozeValueStrings[event.indexes[0]] + " minutes");
				_calibrationRequestSnoozePeriodInMinutes = snoozeValueMinutes[event.indexes[0]];
				_calibrationRequestLatestSnoozeTimeInMs = (new Date()).valueOf();
			}
			
			function batteryLevelSnoozePicker_closedHandler(event:DialogViewEvent): void {
				myTrace("in batteryLevelSnoozePicker_closedHandler snoozing the notification for " + snoozeValueStrings[event.indexes[0]] + " minutes");
				_batteryLevelAlertSnoozePeriodInMinutes = snoozeValueMinutes[event.indexes[0]];
				_batteryLevelAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
			}
			
			function phoneMutedSnoozePicker_closedHandler(event:DialogViewEvent): void {
				myTrace("in phoneMutedSnoozePicker_closedHandler snoozing the notification for " + snoozeValueStrings[event.indexes[0]] + " minutes");
				_phoneMutedAlertSnoozePeriodInMinutes = snoozeValueMinutes[event.indexes[0]];
				_phoneMutedAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
			}
			
			function missedReadingSnoozePicker_canceledHandler(event:DialogViewEvent):void {
				missedReadingSnoozePickerOpen = false;
				myTrace("in missedReadingSnoozePicker_canceledHandler");
				//first cancelling any existing because it may already have been set while app came in foreground
				myTrace("cancel any existing alert for ID_FOR_MISSED_READING_ALERT");
				Notifications.service.cancel(NotificationService.ID_FOR_MISSED_READING_ALERT);
				_missedReadingAlertSnoozePeriodInMinutes = 5;
				_missedReadingAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
				myTrace("planning a new notification of the same type with delay in minues 5");
				
				if (latestAlertTypeUsedInMissedReadingNotification != null) {
					fireAlert(
						latestAlertTypeUsedInMissedReadingNotification, 
						NotificationService.ID_FOR_MISSED_READING_ALERT, 
						ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"), 
						ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"),
						alertType.enableVibration,
						alertType.enableLights,
						null,
						_missedReadingAlertSnoozePeriodInMinutes * 60
					);
				}
			}
			
			function missedReadingSnoozePicker_closedHandler(event:DialogViewEvent): void {
				missedReadingSnoozePickerOpen = false;
				myTrace("in missedReadingSnoozePicker_closedHandler snoozing the notification for " + snoozeValueStrings[event.indexes[0]] + " minutes");
				//first cancelling any existing because it may already have been set while app came in foreground
				myTrace("cancel any existing alert for ID_FOR_MISSED_READING_ALERT");
				Notifications.service.cancel(NotificationService.ID_FOR_MISSED_READING_ALERT);
				_missedReadingAlertSnoozePeriodInMinutes = snoozeValueMinutes[event.indexes[0]];
				_missedReadingAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
				myTrace("in missedReadingSnoozePicker_closedHandler planning a new notification of the same type with delay in minues " + _missedReadingAlertSnoozePeriodInMinutes);
				
				if (latestAlertTypeUsedInMissedReadingNotification != null) {
					fireAlert(
						latestAlertTypeUsedInMissedReadingNotification, 
						NotificationService.ID_FOR_MISSED_READING_ALERT, 
						ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"), 
						ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"),
						alertType.enableVibration,
						alertType.enableLights,
						null,
						_missedReadingAlertSnoozePeriodInMinutes * 60
					); 
				}
			}
			
			function lowSnoozePicker_closedHandler(event:DialogViewEvent): void {
				myTrace("in lowSnoozePicker_closedHandler snoozing the notification for " + snoozeValueStrings[event.indexes[0]]);
				_lowAlertSnoozePeriodInMinutes = snoozeValueMinutes[event.indexes[0]];
				_lowAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
			}
			
			function highSnoozePicker_closedHandler(event:DialogViewEvent): void {
				myTrace("in highSnoozePicker_closedHandler snoozing the notification for " + snoozeValueStrings[event.indexes[0]]);
				_highAlertSnoozePeriodInMinutes = snoozeValueMinutes[event.indexes[0]];
				_highAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
			}
			
			function veryHighSnoozePicker_closedHandler(event:DialogViewEvent): void {
				myTrace("in veryHighSnoozePicker_closedHandler snoozing the notification for " + snoozeValueStrings[event.indexes[0]]);
				_veryHighAlertSnoozePeriodInMinutes = snoozeValueMinutes[event.indexes[0]];
				_veryHighAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
			}
			
			function veryLowSnoozePicker_closedHandler(event:DialogViewEvent): void {
				myTrace("in veryLowSnoozePicker_closedHandler snoozing the notification for " + snoozeValueStrings[event.indexes[0]]);
				_veryLowAlertSnoozePeriodInMinutes = snoozeValueMinutes[event.indexes[0]];
				_veryLowAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
			}
		}
		
		private static function checkAlarmsAfterPerformFetch(event:BackgroundFetchEvent):void {
			myTrace("in checkAlarmsAfterPerformFetch");
			if ((new Date()).valueOf() - lastAlarmCheckTimeStamp > (4 * 60 + 45) * 1000) {
				myTrace("in checkAlarmsAfterPerformFetch, calling checkAlarms because it's been more than 4 minutes 45 seconds");
				checkAlarms(null);
			}
		}
		
		/**
		 * if be == null, then check was triggered by  checkAlarmsAfterPerformFetch
		 */
		private static function checkAlarms(be:TransmitterServiceEvent):void {
			myTrace("in checkAlarms");
			var now:Date = new Date();
			lastAlarmCheckTimeStamp = now.valueOf();
			
			var lastbgreading:BgReading = BgReading.lastNoSensor();
			if (lastbgreading != null) {
				if (now.valueOf() - lastbgreading.timestamp < MAX_AGE_OF_READING_IN_MINUTES * 60 * 1000) {
					if(!checkVeryLowAlert(now)) {
						if (!checkLowAlert(now)) {
							if (!checkVeryHighAlert(now)) {
								checkHighAlert(now);
							} else {
								resetHighAlert();
							}
						} else {
							resetHighAlert();
							resetVeryHighAlert();
						}
					} else {
						resetHighAlert();
						resetVeryHighAlert();
						resetLowAlert();
					}
				}
				checkMissedReadingAlert(now, be == null);
				checkCalibrationRequestAlert(now);
			}
			checkBatteryLowAlert(now);
		}
		
		private static function phoneMuted(event:BackgroundFetchEvent):void {
			myTrace("in phoneMuted");
			var now:Date = new Date(); 
			if (now.valueOf() - lastPhoneMuteAlarmCheckTimeStamp > (4 * 60 + 45) * 1000) {
				lastPhoneMuteAlarmCheckTimeStamp = now.valueOf();
				myTrace("in phoneMuted, checking phoneMute Alarm because it's been more than 4 minutes 45 seconds");
				var listOfAlerts:FromtimeAndValueArrayCollection = FromtimeAndValueArrayCollection.createList(
					CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_PHONE_MUTED_ALERT), false);
				//var alertValue:Number = listOfAlerts.getValue(Number.NaN, "", now);
				var alertName:String = listOfAlerts.getAlarmName(Number.NaN, "", now);
				var alertType:AlertType = Database.getAlertType(alertName);
				if (alertType.enabled) {
					//first check if snoozeperiod is passed, checking first for value would generate multiple alarms in case the sensor is unstable
					if (((now).valueOf() - _phoneMutedAlertLatestSnoozeTimeInMs) > _phoneMutedAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_phoneMutedAlertLatestSnoozeTimeInMs)) {
						myTrace("in phoneMuted, phoneMuted alert not snoozed ");
						fireAlert(
							alertType, 
							NotificationService.ID_FOR_PHONEMUTED_ALERT, 
							ModelLocator.resourceManagerInstance.getString("alarmservice","phonemuted_alert_notification_alert_text"), 
							ModelLocator.resourceManagerInstance.getString("alarmservice","phonemuted_alert_notification_alert_text"),
							alertType.enableVibration,
							alertType.enableLights,
							NotificationService.ID_FOR_PHONE_MUTED_CATEGORY
						); 
						_phoneMutedAlertLatestSnoozeTimeInMs = Number.NaN;
						_phoneMutedAlertSnoozePeriodInMinutes = 0;
					} else {
						//snoozed no need to do anything
						myTrace("in phoneMuted, alarm snoozed, _phoneMutedAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_phoneMutedAlertLatestSnoozeTimeInMs)) + ", _phoneMutedAlertSnoozePeriodInMinutes = " + _phoneMutedAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				} else {
					//remove notification, even if there isn't any
					myTrace("in phoneMuted, alerttype not enabled");
					myTrace("cancel any existing alert for ID_FOR_PHONEMUTED_ALERT");
					Notifications.service.cancel(NotificationService.ID_FOR_PHONEMUTED_ALERT);
					_phoneMutedAlertLatestSnoozeTimeInMs = Number.NaN;
					_phoneMutedAlertLatestNotificationTime = Number.NaN;
					_phoneMutedAlertSnoozePeriodInMinutes = 0;
				}
				
			} else {
				myTrace("less than 4 minutes 45 seconds since last check, not checking phoneMuted alert now");
				return;
			}
		}
		
		private static function phoneNotMuted(event:BackgroundFetchEvent):void {
			myTrace("in phoneNotMuted");
			//remove notification, even if there isn't any
			myTrace("cancel any existing alert for ID_FOR_PHONEMUTED_ALERT");
			Notifications.service.cancel(NotificationService.ID_FOR_PHONEMUTED_ALERT);
			_phoneMutedAlertLatestSnoozeTimeInMs = Number.NaN;
			_phoneMutedAlertLatestNotificationTime = Number.NaN;
			_phoneMutedAlertSnoozePeriodInMinutes = 0;
		}
		
		private static function fireAlert(alertType:AlertType, notificationId:int, alertText:String, titleText:String, enableVibration:Boolean, enableLights:Boolean, categoryId:String, delay:int = 0):void {
			var soundsAsDisplayed:String = ModelLocator.resourceManagerInstance.getString("alerttypeview","sound_names_as_displayed_can_be_translated_must_match_above_list");
			var soundsAsStoredInAssets:String = ModelLocator.resourceManagerInstance.getString("alerttypeview","sound_names_as_in_assets_no_translation_needed_comma_seperated");
			var soundsAsDisplayedSplitted:Array = soundsAsDisplayed.split(',');
			var soundsAsStoredInAssetsSplitted:Array = soundsAsStoredInAssets.split(',');
			var notificationBuilder:NotificationBuilder;
			var newSound:String;
			
			notificationBuilder = new NotificationBuilder()
				.setId(notificationId)
				.setAlert(alertText)
				.setTitle(titleText)
				.setBody(" ")
				.enableVibration(enableVibration)
				.enableLights(enableLights);
			if (categoryId != null)
				notificationBuilder.setCategory(categoryId);
			if (alertType.repeatInMinutes > 0)
				notificationBuilder.setRepeatInterval(NotificationRepeatInterval.REPEAT_MINUTE);
			if (delay != 0) {
				notificationBuilder.setDelay(delay);
			}
			if (alertType.sound == "no_sound" && enableVibration) {
				notificationBuilder.setSound("../assets/silence-1sec.aif");
			} else 	if (alertType.sound == "no_sound" && !enableVibration) {
				notificationBuilder.setSound("");
			} else {
				if (alertType.sound == "default") {
					//it's the default sound, nothing to do
				} else {
					for (var cntr:int = 0;cntr < soundsAsDisplayedSplitted.length;cntr++) {
						newSound = soundsAsDisplayedSplitted[cntr];
						if (newSound == alertType.sound) {
							notificationBuilder.setSound(soundsAsStoredInAssetsSplitted[cntr]);
							break;
						}
					}
				}
			}
			Notifications.service.notify(notificationBuilder.build());
		}
		
		private static function checkMissedReadingAlert(now:Date, notTriggeredByNewReading:Boolean):void {
			var listOfAlerts:FromtimeAndValueArrayCollection;
			var alertValue:Number;
			var alertName:String;
			var alertType:AlertType;
			var delay:int;
			
			if (Sensor.getActiveSensor() == null) {
				myTrace("in checkMissedReadingAlert, but sensor is not active, not planning a missed reading alert now, and cancelling any missed reading alert that maybe still exists");
				myTrace("cancel any existing alert for ID_FOR_MISSED_READING_ALERT");
				Notifications.service.cancel(NotificationService.ID_FOR_MISSED_READING_ALERT);
				return;
			}
			var lastBgReadings:ArrayCollection = BgReading.latestBySize(1);
			if (lastBgReadings.length == 0) {
				myTrace("in checkMissedReadingAlert, but no readings exist yet, not planning a missed reading alert now, and cancelling any missed reading alert that maybe still exists");
				myTrace("cancel any existing alert for ID_FOR_MISSED_READING_ALERT");
				Notifications.service.cancel(NotificationService.ID_FOR_MISSED_READING_ALERT);
				return;
			} 
			var lastBgReading:BgReading = lastBgReadings.getItemAt(0) as BgReading;
			
			listOfAlerts = FromtimeAndValueArrayCollection.createList(
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_MISSED_READING_ALERT), false);
			alertValue = listOfAlerts.getValue(Number.NaN, "", now);
			alertName = listOfAlerts.getAlarmName(Number.NaN, "", now);
			alertType = Database.getAlertType(alertName);
			if (alertType.enabled) {
				myTrace("in checkMissedReadingAlert, alertType enabled");
				if (((now).valueOf() - _missedReadingAlertLatestSnoozeTimeInMs) > _missedReadingAlertSnoozePeriodInMinutes * 60 * 1000
					||
					isNaN(_missedReadingAlertLatestSnoozeTimeInMs)) {
					myTrace("in checkMissedReadingAlert, missed reading alert not snoozed, canceling any planned missed reading alert");
					//not snoozed
					//cance any planned alert because it's not snoozed and we actually received a reading
					myTrace("cancel any existing alert for ID_FOR_MISSED_READING_ALERT");
					Notifications.service.cancel(NotificationService.ID_FOR_MISSED_READING_ALERT);
					//check if missed reading alert is still enabled at the time it's supposed to fire
					var dateOfFire:Date = new Date(now.valueOf() + alertValue * 60 * 1000);
					delay = alertValue * 60;
					myTrace("in checkMissedReadingAlert, calculated delay in minutes = " + delay/60);
					if (notTriggeredByNewReading) {
						var diffInSeconds:Number = (now.valueOf() - lastBgReading.timestamp)/1000;
						delay = delay - diffInSeconds;
						if (delay < 0)
							delay = 0;
						myTrace("in checkMissedReadingAlert, was not triggered by new reading, reducing delay with time since last bgreading, new delay value in minutes = " + delay/60);
					}
					myTrace("in checkMissedReadingAlert, adding 30 seconds to the planned firedate, to avoid it fires just before a new reading is received");
					delay += 30;
					if (Database.getAlertType(listOfAlerts.getAlarmName(Number.NaN, "", dateOfFire)).enabled) {
						latestAlertTypeUsedInMissedReadingNotification = alertType;
						myTrace("in checkMissedReadingAlert, missed reading planned with delay in minutes = " + delay/60);
						fireAlert(
							alertType, 
							NotificationService.ID_FOR_MISSED_READING_ALERT, 
							ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"), 
							ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"),
							alertType.enableVibration,
							alertType.enableLights,
							null,
							delay
						); 
						_missedReadingAlertLatestSnoozeTimeInMs = Number.NaN;
						_missedReadingAlertSnoozePeriodInMinutes = 0;
					} else {
						myTrace("in checkMissedReadingAlert, current missed reading alert is enabled, but the time it's supposed to expire it is not enabled so not setting it");
					}
					
				} else {
					//snoozed no need to do anything
					myTrace("in checkMissedReadingAlert, missed reading snoozed, _missedReadingAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_missedReadingAlertLatestSnoozeTimeInMs)) + ", _missedReadingAlertSnoozePeriodInMinutes = " + _missedReadingAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
				}
			} else {// missed reading alert according to current time not enabled, but check if next period has the alert enabled
				myTrace("in checkMissedReadingAlert, alertType not enabled");
				if (((now).valueOf() - _missedReadingAlertLatestSnoozeTimeInMs) > _missedReadingAlertSnoozePeriodInMinutes * 60 * 1000
					||
					isNaN(_missedReadingAlertLatestSnoozeTimeInMs)) {
					myTrace("in checkMissedReadingAlert, missed reading, current alert not enabled and also not snoozed, checking future alert");
					//get the next alertname
					alertName = listOfAlerts.getNextAlarmName(Number.NaN, "", now);
					alertValue = listOfAlerts.getNextValue(Number.NaN, "", now);
					alertType = Database.getAlertType(alertName);
					if (alertType.enabled) {
						myTrace("in checkMissedReadingAlert, next alert is enabled");
						//cance any planned alert because it's not snoozed and we actually received a reading
						myTrace("cancel any existing alert for ID_FOR_MISSED_READING_ALERT");
						Notifications.service.cancel(NotificationService.ID_FOR_MISSED_READING_ALERT);
						var currentHourLocal:int = now.hours;
						var currentMinuteLocal:int = now.minutes;
						var currentSecondsLocal:int = now.seconds;
						var currentTimeInSeconds:int = 3600 * currentHourLocal + 60 * currentMinuteLocal + currentSecondsLocal;
						var fromTimeNextAlertInSeconds:int = listOfAlerts.getNextFromTime(Number.NaN, "", now);
						if (fromTimeNextAlertInSeconds > currentTimeInSeconds)
							delay = fromTimeNextAlertInSeconds - currentTimeInSeconds;
						else 
							delay = 24 * 3600  - (currentTimeInSeconds - fromTimeNextAlertInSeconds);
						if (delay < alertValue * 60)
							delay = alertValue * 60;
						myTrace("in checkMissedReadingAlert, calculated delay in minutes = " + delay/60);
						latestAlertTypeUsedInMissedReadingNotification = alertType;
						myTrace("in checkMissedReadingAlert, adding 30 seconds to the planned firedate, to avoid it fires just before a new reading is received");
						delay += 30;
						myTrace("in checkMissedReadingAlert, missed reading planned with delay in minutes = " + delay/60);
						fireAlert(
							alertType, 
							NotificationService.ID_FOR_MISSED_READING_ALERT, 
							ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"), 
							ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"),
							alertType.enableVibration,
							alertType.enableLights,
							null,
							delay
						); 
						_missedReadingAlertLatestSnoozeTimeInMs = Number.NaN;
						_missedReadingAlertSnoozePeriodInMinutes = 0;
					} else {
						//no need to set the notification, on the contrary just cancel any existing notification
						myTrace("in checkMissedReadingAlert, missed reading, snoozed, and current alert not enabled anymore, so canceling alert and resetting snooze");
						myTrace("cancel any existing alert for ID_FOR_MISSED_READING_ALERT");
						Notifications.service.cancel(NotificationService.ID_FOR_MISSED_READING_ALERT);
						_missedReadingAlertLatestSnoozeTimeInMs = Number.NaN;
						_missedReadingAlertLatestNotificationTime = Number.NaN;
						_missedReadingAlertSnoozePeriodInMinutes = 0;
					}
					
				} else {
					//snoozed no need to do anything
					myTrace("in checkMissedReadingAlert, missed reading snoozed, _missedReadingAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_missedReadingAlertLatestSnoozeTimeInMs)) + ", _missedReadingAlertSnoozePeriodInMinutes = " + _missedReadingAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
				}
			}
		}
		
		private static function checkCalibrationRequestAlert(now:Date):void {
			var listOfAlerts:FromtimeAndValueArrayCollection;
			var alertValue:Number;
			var alertName:String;
			var alertType:AlertType;
			
			listOfAlerts = FromtimeAndValueArrayCollection.createList(
				CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CALIBRATION_REQUEST_ALERT), false);
			alertValue = listOfAlerts.getValue(Number.NaN, "", now);
			alertName = listOfAlerts.getAlarmName(Number.NaN, "", now);
			alertType = Database.getAlertType(alertName);
			if (alertType.enabled) {
				if ((now.valueOf() - _calibrationRequestLatestSnoozeTimeInMs) > _calibrationRequestSnoozePeriodInMinutes * 60 * 1000
					||
					isNaN(_calibrationRequestLatestSnoozeTimeInMs)) {
					myTrace("in checkAlarms, calibration request alert not snoozed ");
					if (Calibration.last() != null && BgReading.last30Minutes().length >= 2) {
						if (alertValue < ((now.valueOf() - Calibration.last().timestamp) / 1000 / 60 / 60)) {
							myTrace("in checkAlarms, calibration is necessary");
							fireAlert(
								alertType, 
								NotificationService.ID_FOR_CALIBRATION_REQUEST_ALERT, 
								ModelLocator.resourceManagerInstance.getString("alarmservice","calibration_request_alert_notification_alert_title"), 
								ModelLocator.resourceManagerInstance.getString("alarmservice","calibration_request_alert_notification_alert_title"),
								alertType.enableVibration,
								alertType.enableLights,
								NotificationService.ID_FOR_ALERT_CALIBRATION_REQUEST_CATEGORY
							); 
							_calibrationRequestLatestSnoozeTimeInMs = Number.NaN;
							_calibrationRequestSnoozePeriodInMinutes = 0;
						} else {
							myTrace("cancel any existing alert for ID_FOR_CALIBRATION_REQUEST_ALERT");
							Notifications.service.cancel(NotificationService.ID_FOR_CALIBRATION_REQUEST_ALERT);
						}
					} else {
						myTrace("cancel any existing alert for ID_FOR_CALIBRATION_REQUEST_ALERT");
						Notifications.service.cancel(NotificationService.ID_FOR_CALIBRATION_REQUEST_ALERT);
					}
				} else {
					//snoozed no need to do anything
					myTrace("in checkAlarms, alarm snoozed, _calibrationRequestLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_calibrationRequestLatestSnoozeTimeInMs)) + ", _calibrationRequestSnoozePeriodInMinutes = " + _calibrationRequestSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
				}
			} else {
				//remove calibration request notification, even if there isn't any	
				myTrace("cancel any existing alert for ID_FOR_CALIBRATION_REQUEST_ALERT");
				Notifications.service.cancel(NotificationService.ID_FOR_CALIBRATION_REQUEST_ALERT);
				_calibrationRequestLatestSnoozeTimeInMs = Number.NaN;
				_calibrationRequestLatestNotificationTime = Number.NaN;
				_calibrationRequestSnoozePeriodInMinutes = 0;
			}
		}
		
		/**
		 * returns true of alarm fired
		 */private static function checkBatteryLowAlert(now:Date):Boolean {
			 var listOfAlerts:FromtimeAndValueArrayCollection;
			 var alertValue:Number;
			 var alertName:String;
			 var alertType:AlertType;
			 var returnValue:Boolean = false;
			 
			 listOfAlerts = FromtimeAndValueArrayCollection.createList(
				 CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BATTERY_ALERT), false);
			 alertValue = listOfAlerts.getValue(Number.NaN, "", now);
			 alertName = listOfAlerts.getAlarmName(Number.NaN, "", now);
			 alertType = Database.getAlertType(alertName);
			 if (alertType.enabled) {
				 //first check if snoozeperiod is passed, checking first for value would generate multiple alarms in case the sensor is unstable
				 if (((now).valueOf() - _batteryLevelAlertLatestSnoozeTimeInMs) > _batteryLevelAlertSnoozePeriodInMinutes * 60 * 1000
					 ||
					 isNaN(_batteryLevelAlertLatestSnoozeTimeInMs)) {
					 myTrace("in checkAlarms, batteryLevel alert not snoozed ");
					 //not snoozed
					 
					 if ((!BlueToothDevice.isDexcomG5() && (new Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_G4_TRANSMITTER_BATTERY_VOLTAGE)) < alertValue) && (new Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_G4_TRANSMITTER_BATTERY_VOLTAGE)) > 0))
						 ||
						 (BlueToothDevice.isDexcomG5() && (new Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_G5_VOLTAGEA)) < alertValue) && (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_G5_VOLTAGEA) != "unknown"))) {
						 myTrace("in checkAlarms, battery level is too low");
						 fireAlert(
							 alertType, 
							 NotificationService.ID_FOR_BATTERY_ALERT, 
							 ModelLocator.resourceManagerInstance.getString("alarmservice","batteryLevel_alert_notification_alert_text"), 
							 ModelLocator.resourceManagerInstance.getString("alarmservice","batteryLevel_alert_notification_alert_text"),
							 alertType.enableVibration,
							 alertType.enableLights,
							 NotificationService.ID_FOR_ALERT_BATTERY_CATEGORY
						 ); 
						 _batteryLevelAlertLatestSnoozeTimeInMs = Number.NaN;
						 _batteryLevelAlertSnoozePeriodInMinutes = 0;
						 returnValue = true;
					 } else {
						 myTrace("cancel any existing alert for ID_FOR_BATTERY_ALERT");
						 Notifications.service.cancel(NotificationService.ID_FOR_BATTERY_ALERT);
					 }
				 } else {
					 //snoozed no need to do anything
					 myTrace("in checkAlarms, alarm snoozed, _batteryLevelAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_batteryLevelAlertLatestSnoozeTimeInMs)) + ", _batteryLevelAlertSnoozePeriodInMinutes = " + _batteryLevelAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
				 }
			 } else {
				 //remove notification, even if there isn't any
				 myTrace("cancel any existing alert for ID_FOR_BATTERY_ALERT");
				 Notifications.service.cancel(NotificationService.ID_FOR_BATTERY_ALERT);
				 _batteryLevelAlertLatestSnoozeTimeInMs = Number.NaN;
				 _batteryLevelAlertLatestNotificationTime = Number.NaN;
				 _batteryLevelAlertSnoozePeriodInMinutes = 0;
			 }
			 return returnValue;
		 }
		
		/**
		 * returns true of alarm fired
		 */private static function checkHighAlert(now:Date):Boolean {
			 var listOfAlerts:FromtimeAndValueArrayCollection;
			 var alertValue:Number;
			 var alertName:String;
			 var alertType:AlertType;
			 var returnValue:Boolean = false;
			 
			 listOfAlerts = FromtimeAndValueArrayCollection.createList(
				 CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_HIGH_ALERT), true);
			 alertValue = listOfAlerts.getValue(Number.NaN, "", now);
			 alertName = listOfAlerts.getAlarmName(Number.NaN, "", now);
			 alertType = Database.getAlertType(alertName);
			 if (alertType.enabled) {
				 //first check if snoozeperiod is passed, checking first for value would generate multiple alarms in case the sensor is unstable
				 if (((now).valueOf() - _highAlertLatestSnoozeTimeInMs) > _highAlertSnoozePeriodInMinutes * 60 * 1000
					 ||
					 isNaN(_highAlertLatestSnoozeTimeInMs)) {
					 myTrace("in checkAlarms, high alert not snoozed ");
					 //not snoozed
					 
					 if (alertValue < BgReading.lastNoSensor().calculatedValue) {
						 myTrace("in checkAlarms, reading is too high");
						 fireAlert(
							 alertType, 
							 NotificationService.ID_FOR_HIGH_ALERT, 
							 ModelLocator.resourceManagerInstance.getString("alarmservice","high_alert_notification_alert_text"), 
							 ModelLocator.resourceManagerInstance.getString("alarmservice","high_alert_notification_alert_text"),
							 alertType.enableVibration,
							 alertType.enableLights,
							 NotificationService.ID_FOR_ALERT_HIGH_CATEGORY
						 ); 
						 _highAlertLatestSnoozeTimeInMs = Number.NaN;
						 _highAlertSnoozePeriodInMinutes = 0;
						 returnValue = true;
					 } else {
						 myTrace("cancel any existing alert for ID_FOR_HIGH_ALERT");
						 Notifications.service.cancel(NotificationService.ID_FOR_HIGH_ALERT);
					 }
				 } else {
					 //snoozed no need to do anything
					 myTrace("in checkAlarms, alarm snoozed, _highAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_highAlertLatestSnoozeTimeInMs)) + ", _highAlertSnoozePeriodInMinutes = " + _highAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
				 }
			 } else {
				 //remove notification, even if there isn't any
				 resetHighAlert();
			 }
			 return returnValue;
		 }
		
		/**
		 * returns true of alarm fired or if alert is snoozed
		 */private static function checkVeryHighAlert(now:Date):Boolean {
			 var listOfAlerts:FromtimeAndValueArrayCollection;
			 var alertValue:Number;
			 var alertName:String;
			 var alertType:AlertType;
			 var returnValue:Boolean = false;
			 
			 listOfAlerts = FromtimeAndValueArrayCollection.createList(
				 CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_VERY_HIGH_ALERT), true);
			 alertValue = listOfAlerts.getValue(Number.NaN, "", now);
			 alertName = listOfAlerts.getAlarmName(Number.NaN, "", now);
			 alertType = Database.getAlertType(alertName);
			 if (alertType.enabled) {
				 //first check if snoozeperiod is passed, checking first for value would generate multiple alarms in case the sensor is unstable
				 if (((now).valueOf() - _veryHighAlertLatestSnoozeTimeInMs) > _veryHighAlertSnoozePeriodInMinutes * 60 * 1000
					 ||
					 isNaN(_veryHighAlertLatestSnoozeTimeInMs)) {
					 myTrace("in checkAlarms, veryHigh alert not snoozed ");
					 //not snoozed
					 
					 if (alertValue < BgReading.lastNoSensor().calculatedValue) {
						 myTrace("in checkAlarms, reading is too veryHigh");
						 fireAlert(
							 alertType, 
							 NotificationService.ID_FOR_VERY_HIGH_ALERT, 
							 ModelLocator.resourceManagerInstance.getString("alarmservice","veryhigh_alert_notification_alert_text"), 
							 ModelLocator.resourceManagerInstance.getString("alarmservice","veryhigh_alert_notification_alert_text"),
							 alertType.enableVibration,
							 alertType.enableLights,
							 NotificationService.ID_FOR_ALERT_VERY_HIGH_CATEGORY
						 ); 
						 _veryHighAlertLatestSnoozeTimeInMs = Number.NaN;
						 _veryHighAlertSnoozePeriodInMinutes = 0;
						 returnValue = true;
					 } else {
						 myTrace("cancel any existing alert for ID_FOR_VERY_HIGH_ALERT");
						 Notifications.service.cancel(NotificationService.ID_FOR_VERY_HIGH_ALERT);
					 }
				 } else {
					 //snoozed no need to do anything,returnvalue = true because there's no need to check for high alert
					 returnValue = true;
					 myTrace("in checkAlarms, alarm snoozed, _veryHighAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_veryHighAlertLatestSnoozeTimeInMs)) + ", _veryHighAlertSnoozePeriodInMinutes = " + _veryHighAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
				 }
			 } else {
				 //remove notification, even if there isn't any
				 resetVeryHighAlert();
			 }
			 return returnValue;
		 }
		
		/**
		 * returns true of alarm fired
		 */private static function checkLowAlert(now:Date):Boolean {
			 var listOfAlerts:FromtimeAndValueArrayCollection;
			 var alertValue:Number;
			 var alertName:String;
			 var alertType:AlertType;
			 var returnValue:Boolean = false;
			 
			 listOfAlerts = FromtimeAndValueArrayCollection.createList(
				 CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_LOW_ALERT), true);
			 alertValue = listOfAlerts.getValue(Number.NaN, "", now);
			 alertName = listOfAlerts.getAlarmName(Number.NaN, "", now);
			 alertType = Database.getAlertType(alertName);
			 if (alertType.enabled) {
				 //first check if snoozeperiod is passed, checking first for value would generate multiple alarms in case the sensor is unstable
				 if ((now.valueOf() - _lowAlertLatestSnoozeTimeInMs) > _lowAlertSnoozePeriodInMinutes * 60 * 1000
					 ||
					 isNaN(_lowAlertLatestSnoozeTimeInMs)) {
					 myTrace("in checkAlarms, low alert not snoozed ");
					 //not snoozed
					 
					 if (alertValue > BgReading.lastNoSensor().calculatedValue) {
						 myTrace("in checkAlarms, reading is too low");
						 fireAlert(
							 alertType, 
							 NotificationService.ID_FOR_LOW_ALERT, 
							 ModelLocator.resourceManagerInstance.getString("alarmservice","low_alert_notification_alert_text"), 
							 ModelLocator.resourceManagerInstance.getString("alarmservice","low_alert_notification_alert_text"),
							 alertType.enableVibration,
							 alertType.enableLights,
							 NotificationService.ID_FOR_ALERT_LOW_CATEGORY
						 ); 
						 _lowAlertLatestSnoozeTimeInMs = Number.NaN;
						 _lowAlertSnoozePeriodInMinutes = 0;
						 returnValue = true;
					 } else {
						 myTrace("cancel any existing alert for ID_FOR_LOW_ALERT");
						 Notifications.service.cancel(NotificationService.ID_FOR_LOW_ALERT);
					 }
				 } else {
					 //snoozed no need to do anything
					 myTrace("in checkAlarms, alarm snoozed, _lowAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_lowAlertLatestSnoozeTimeInMs)) + ", _lowAlertSnoozePeriodInMinutes = " + _lowAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
				 }
			 } else {
				 //remove low notification, even if there isn't any
				 resetLowAlert();
			 }
			 return returnValue;
		 }
		
		/**
		 * returns true of alarm fired or if snoozed
		 */private static function checkVeryLowAlert(now:Date):Boolean {
			 var listOfAlerts:FromtimeAndValueArrayCollection;
			 var alertValue:Number;
			 var alertName:String;
			 var alertType:AlertType;
			 var returnValue:Boolean = false;
			 
			 listOfAlerts = FromtimeAndValueArrayCollection.createList(
				 CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_VERY_LOW_ALERT), true);
			 alertValue = listOfAlerts.getValue(Number.NaN, "", now);
			 alertName = listOfAlerts.getAlarmName(Number.NaN, "", now);
			 alertType = Database.getAlertType(alertName);
			 if (alertType.enabled) {
				 //first check if snoozeperiod is passed, checking first for value would generate multiple alarms in case the sensor is unstable
				 if ((now.valueOf() - _veryLowAlertLatestSnoozeTimeInMs) > _veryLowAlertSnoozePeriodInMinutes * 60 * 1000
					 ||
					 isNaN(_veryLowAlertLatestSnoozeTimeInMs)) {
					 myTrace("in checkAlarms, veryLow alert not snoozed ");
					 //not snoozed
					 
					 if (alertValue > BgReading.lastNoSensor().calculatedValue) {
						 myTrace("in checkAlarms, reading is too veryLow");
						 fireAlert(
							 alertType, 
							 NotificationService.ID_FOR_VERY_LOW_ALERT, 
							 ModelLocator.resourceManagerInstance.getString("alarmservice","verylow_alert_notification_alert_text"), 
							 ModelLocator.resourceManagerInstance.getString("alarmservice","verylow_alert_notification_alert_text"),
							 alertType.enableVibration,
							 alertType.enableLights,
							 NotificationService.ID_FOR_ALERT_VERY_LOW_CATEGORY
						 ); 
						 _veryLowAlertLatestSnoozeTimeInMs = Number.NaN;
						 _veryLowAlertSnoozePeriodInMinutes = 0;
						 returnValue = true;
					 } else {
						 myTrace("cancel any existing alert for ID_FOR_VERY_LOW_ALERT");
						 Notifications.service.cancel(NotificationService.ID_FOR_VERY_LOW_ALERT);
					 }
				 } else {
					 //snoozed no need to do anything, set returnvalue to true because there's no need to further check
					 returnValue = true;
					 myTrace("in checkAlarms, alarm snoozed, _veryLowAlertLatestSnoozeTime = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_veryLowAlertLatestSnoozeTimeInMs)) + ", _veryLowAlertSnoozePeriodInMinutes = " + _veryLowAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
				 }
			 } else {
				 //remove veryLow notification, even if there isn't any
				 resetVeryLowAlert();
			 }
			 return returnValue;
		 }
		
		private static function resetVeryHighAlert():void {
			myTrace("cancel any existing alert for ID_FOR_VERY_HIGH_ALERT");
			Notifications.service.cancel(NotificationService.ID_FOR_VERY_HIGH_ALERT);
			_veryHighAlertLatestSnoozeTimeInMs = Number.NaN;
			_veryHighAlertLatestNotificationTime = Number.NaN;
			_veryHighAlertSnoozePeriodInMinutes = 0;
		}
		
		private static function resetVeryLowAlert():void {
			myTrace("cancel any existing alert for ID_FOR_VERY_LOW_ALERT");
			Notifications.service.cancel(NotificationService.ID_FOR_VERY_LOW_ALERT);
			_veryLowAlertLatestSnoozeTimeInMs = Number.NaN;
			_veryLowAlertLatestNotificationTime = Number.NaN;
			_veryLowAlertSnoozePeriodInMinutes = 0;
		}
		
		private static function resetHighAlert():void {
			myTrace("cancel any existing alert for ID_FOR_HIGH_ALERT");
			Notifications.service.cancel(NotificationService.ID_FOR_HIGH_ALERT);
			_highAlertLatestSnoozeTimeInMs = Number.NaN;
			_highAlertLatestNotificationTime = Number.NaN;
			_highAlertSnoozePeriodInMinutes = 0;
		}
		
		private static function resetLowAlert():void {
			myTrace("cancel any existing alert for ID_FOR_LOW_ALERT");
			Notifications.service.cancel(NotificationService.ID_FOR_LOW_ALERT);
			_lowAlertLatestSnoozeTimeInMs = Number.NaN;
			_lowAlertLatestNotificationTime = Number.NaN;
			_lowAlertSnoozePeriodInMinutes = 0;
		}
		
		private static function settingChanged(event:SettingsServiceEvent):void {
			if (event.data == CommonSettings.COMMON_SETTING_MISSED_READING_ALERT || event.data == CommonSettings.COMMON_SETTING_CURRENT_SENSOR) {
				checkMissedReadingAlert(new Date(), true);
				//need to plan missed reading alert
				//- in case the user has changed missed reading settings
				//- or user has started, stopped a sensor
				//    if It was a sensor stop, then the setting COMMON_SETTING_CURRENT_SENSOR has value "0", and in checkMissedReadingAlert, the alert will be canceled and not replanned
			} else if (event.data == CommonSettings.COMMON_SETTING_CALIBRATION_REQUEST_ALERT) {
				checkCalibrationRequestAlert(new Date());
			}
		}
		
		private static function myTrace(log:String):void {
			Trace.myTrace("AlarmService.as", log);
		}
		
	}
}