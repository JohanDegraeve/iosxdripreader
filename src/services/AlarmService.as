package services
{
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
	
	import flash.events.EventDispatcher;
	
	import Utilities.DateTimeUtilities;
	import Utilities.FromtimeAndValueArrayCollection;
	import Utilities.Trace;
	
	import databaseclasses.AlertType;
	import databaseclasses.BgReading;
	import databaseclasses.CommonSettings;
	import databaseclasses.Database;
	
	import events.NotificationServiceEvent;
	import events.TransmitterServiceEvent;
	
	import model.ModelLocator;
	
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
		
		//missed reading
		//high alert
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
		
		
		private static var snoozeValueMinutes:Array = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 75, 90, 120, 150, 180, 240, 300, 360, 420, 480, 540, 600];
		private static var snoozeValueStrings:Array = ["5 minutes", "10 minutes", "15 minutes", "20 minutes", "25 minutes", "30 minutes", "35 minutes",
			"40 minutes", "45 minutes", "50 minutes", "55 minutes", "1 hour", "1 hour 15 minutes", "1,5 hours", "2 hours", "2,5 hours", "3 hours", "4 hours",
			"5 hours", "6 hours", "7 hours", "8 hours", "9 hours", "10 hours"];
		
		private static var lastAlarmCheckTimeStamp:Number;
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
			TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, checkAlarms);
			NotificationService.instance.addEventListener(NotificationServiceEvent.NOTIFICATION_EVENT, notificationReceived);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.PERFORMREMOTEFETCH, checkAlarmsAfterPerformFetch);

			for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
				snoozeValueStrings[cntr] = (snoozeValueStrings[cntr] as String).replace("minutes", ModelLocator.resourceManagerInstance.getString("alarmservice","minutes"));
				snoozeValueStrings[cntr] = (snoozeValueStrings[cntr] as String).replace("hour", ModelLocator.resourceManagerInstance.getString("alarmservice","hour"));
				snoozeValueStrings[cntr] = (snoozeValueStrings[cntr] as String).replace("hours", ModelLocator.resourceManagerInstance.getString("alarmservice","hours"));
			}
		}
		
		private static function notificationReceived(event:NotificationServiceEvent):void {
			if (event != null) {
				var listOfAlerts:FromtimeAndValueArrayCollection;
				var alertName:String ;
				var alertType:AlertType;
				var index:int;
				var snoozePeriodPicker:DialogView;
				
				var notificationEvent:NotificationEvent = event.data as NotificationEvent;
				if (notificationEvent.id == NotificationService.ID_FOR_LOW_ALERT) {
					listOfAlerts = FromtimeAndValueArrayCollection.createList(
						CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_LOW_ALERT));
					alertName = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
					alertType = Database.getAlertType(alertName);
					myTrace("in notificationReceived with id = ID_FOR_LOW_ALERT, cancelling notification");
					Notifications.service.cancel(NotificationService.ID_FOR_LOW_ALERT);
					index = 0;
					for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
						if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
							index = cntr;
							break;
						}
					}
					if (notificationEvent.identifier == null) {
						snoozePeriodPicker = Dialog.service.create(
							new PickerDialogBuilder()
							.setTitle(ModelLocator.resourceManagerInstance.getString('alarmservice', 'snooze_picker_title'))
							.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
							.setAcceptLabel("Ok")
							.addColumn( snoozeValueStrings, index )
							.build()
						);
						snoozePeriodPicker.addEventListener( DialogViewEvent.CLOSED, lowSnoozePicker_closedHandler );
						snoozePeriodPicker.show();
					} else if (notificationEvent.identifier == NotificationService.ID_FOR_LOW_ALERT_SNOOZE_IDENTIFIER) {
						myTrace("in notificationReceived with id = ID_FOR_LOW_ALERT, snoozing the notification for " + _lowAlertSnoozePeriodInMinutes + "minutes");
						_lowAlertSnoozePeriodInMinutes = alertType.defaultSnoozePeriodInMinutes;
						_lowAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
					}
				} else if (notificationEvent.id == NotificationService.ID_FOR_HIGH_ALERT) {
					listOfAlerts = FromtimeAndValueArrayCollection.createList(
						CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_HIGH_ALERT));
					alertName = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
					alertType = Database.getAlertType(alertName);
					myTrace("in notificationReceived with id = ID_FOR_HIGH_ALERT, cancelling notification");
					Notifications.service.cancel(NotificationService.ID_FOR_HIGH_ALERT);
					index = 0;
					for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
						if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
							index = cntr;
							break;
						}
					}
					if (notificationEvent.identifier == null) {
						snoozePeriodPicker = Dialog.service.create(
							new PickerDialogBuilder()
							.setTitle(ModelLocator.resourceManagerInstance.getString('alarmservice', 'snooze_picker_title'))
							.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
							.setAcceptLabel("Ok")
							.addColumn( snoozeValueStrings, index )
							.build()
						);
						snoozePeriodPicker.addEventListener( DialogViewEvent.CLOSED, highSnoozePicker_closedHandler );
						snoozePeriodPicker.show();
					} else if (notificationEvent.identifier == NotificationService.ID_FOR_HIGH_ALERT_SNOOZE_IDENTIFIER) {
						myTrace("in notificationReceived with id = ID_FOR_HIGH_ALERT, snoozing the notification for " + _highAlertSnoozePeriodInMinutes + " minutes");
						_highAlertSnoozePeriodInMinutes = alertType.defaultSnoozePeriodInMinutes;
						_highAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
					}
				} else if (notificationEvent.id == NotificationService.ID_FOR_MISSED_READING_ALERT) {
					listOfAlerts = FromtimeAndValueArrayCollection.createList(
						CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_MISSED_READING_ALERT));
					alertName = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
					alertType = Database.getAlertType(alertName);
					myTrace("in notificationReceived with id = ID_FOR_MISSED_READING_ALERT, cancelling notification");
					Notifications.service.cancel(NotificationService.ID_FOR_MISSED_READING_ALERT);
					index = 0;
					for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
						if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
							index = cntr;
							break;
						}
					}
					if (notificationEvent.identifier == null) {
						snoozePeriodPicker = Dialog.service.create(
							new PickerDialogBuilder()
							.setTitle(ModelLocator.resourceManagerInstance.getString('alarmservice', 'snooze_picker_title'))
							.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
							.setAcceptLabel("Ok")
							.addColumn( snoozeValueStrings, index )
							.build()
						);
						snoozePeriodPicker.addEventListener( DialogViewEvent.CLOSED, missedReadingSnoozePicker_closedHandler );
						snoozePeriodPicker.show();
					} else if (notificationEvent.identifier == NotificationService.ID_FOR_MISSED_READING_ALERT_SNOOZE_IDENTIFIER) {
						myTrace("in notificationReceived with id = ID_FOR_MISSED_READING_ALERT, snoozing the notification for " + _missedReadingAlertSnoozePeriodInMinutes);
						_missedReadingAlertSnoozePeriodInMinutes = alertType.defaultSnoozePeriodInMinutes;
						_missedReadingAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
					}
				}
			}
			
			function missedReadingSnoozePicker_closedHandler(event:DialogViewEvent): void {
				myTrace("in missedReadingSnoozePicker_closedHandler snoozing the notification for " + snoozeValueStrings[event.indexes[0]]);
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
						NotificationService.ID_FOR_ALERT_MISSED_READING_CATEGORY,
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
				//low alert
				var listOfAlerts:FromtimeAndValueArrayCollection = FromtimeAndValueArrayCollection.createList(
					CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_LOW_ALERT));
				var alertValue:Number = listOfAlerts.getValue(Number.NaN, "", now);
				var alertName:String = listOfAlerts.getAlarmName(Number.NaN, "", now);
				var alertType:AlertType = Database.getAlertType(alertName);
				if (alertType.enabled) {
					//first check if snoozeperiod is passed, checking first for value would generate multiple alarms in case the sensor is unstable
					if ((now.valueOf() - _lowAlertLatestSnoozeTimeInMs) > _lowAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_lowAlertLatestSnoozeTimeInMs)) {
						myTrace("in checkAlarms, low alert not snoozed (anymore)");
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
						} else {
							Notifications.service.cancel(NotificationService.ID_FOR_LOW_ALERT);
						}
					} else {
						//snoozed no need to do anything
						myTrace("in checkAlarms, alarm snoozed, _lowAlertLatestSnoozeTimeInMs = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_lowAlertLatestSnoozeTimeInMs)) + ", _lowAlertSnoozePeriodInMinutes = " + _lowAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				} else {
					//remove low notification, even if there isn't any
					Notifications.service.cancel(NotificationService.ID_FOR_LOW_ALERT);
					_lowAlertLatestSnoozeTimeInMs = Number.NaN;
					_lowAlertLatestNotificationTime = Number.NaN;
					_lowAlertSnoozePeriodInMinutes = 0;
				}
				
				//high alert
				listOfAlerts = FromtimeAndValueArrayCollection.createList(
					CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_HIGH_ALERT));
				alertValue = listOfAlerts.getValue(Number.NaN, "", now);
				alertName = listOfAlerts.getAlarmName(Number.NaN, "", now);
				alertType = Database.getAlertType(alertName);
				if (alertType.enabled) {
					//first check if snoozeperiod is passed, checking first for value would generate multiple alarms in case the sensor is unstable
					if (((now).valueOf() - _highAlertLatestSnoozeTimeInMs) > _highAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_highAlertLatestSnoozeTimeInMs)) {
						myTrace("in checkAlarms, high alert not snoozed (anymore)");
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
						} else {
							Notifications.service.cancel(NotificationService.ID_FOR_HIGH_ALERT);
						}
					} else {
						//snoozed no need to do anything
						myTrace("in checkAlarms, alarm snoozed, _highAlertLatestSnoozeTimeInMs = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_highAlertLatestSnoozeTimeInMs)) + ", _highAlertSnoozePeriodInMinutes = " + _highAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				} else {
					//remove notification, even if there isn't any
					Notifications.service.cancel(NotificationService.ID_FOR_HIGH_ALERT);
					_highAlertLatestSnoozeTimeInMs = Number.NaN;
					_highAlertLatestNotificationTime = Number.NaN;
					_highAlertSnoozePeriodInMinutes = 0;
				}
				
				//missed reading alert
				listOfAlerts = FromtimeAndValueArrayCollection.createList(
					CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_MISSED_READING_ALERT));
				alertValue = listOfAlerts.getValue(Number.NaN, "", now);
				alertName = listOfAlerts.getAlarmName(Number.NaN, "", now);
				alertType = Database.getAlertType(alertName);
				if (alertType.enabled) {
					if (((now).valueOf() - _missedReadingAlertLatestSnoozeTimeInMs) > _missedReadingAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_missedReadingAlertLatestSnoozeTimeInMs)) {
						myTrace("in checkAlarms, missed reading alert not snoozed (anymore), canceling any planned missed reading alert");
						//not snoozed
						//cance any planned alert because it's not snoozed and we actually received a reading
						Notifications.service.cancel(NotificationService.ID_FOR_MISSED_READING_ALERT);
						//check if missed reading alert is still enabled at the time it's supposed to fire
						var dateOfFire:Date = new Date(now.valueOf() + alertValue * 60 * 1000);
						var delay:int = alertValue * 60;
						myTrace("in checkAlarms, calculated delay in minutes = " + delay/60);
						if (be == null) {
							var diffInSeconds:Number = (now.valueOf() - lastbgreading.timestamp)/1000;
							delay = delay - diffInSeconds;
							if (delay <= 0)
								delay = 0;
							myTrace("in checkAlarms, was triggered by performFetch, reducing delay with time since last bgreading, new delay value = " + delay);
						}
						if (Database.getAlertType(listOfAlerts.getAlarmName(Number.NaN, "", dateOfFire)).enabled) {
							myTrace("in checkAlarms, missed reading planned with delay in minutes = " + delay/60);
							latestAlertTypeUsedInMissedReadingNotification = alertType;
							fireAlert(
								alertType, 
								NotificationService.ID_FOR_MISSED_READING_ALERT, 
								ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"), 
								ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"),
								alertType.enableVibration,
								alertType.enableLights,
								NotificationService.ID_FOR_ALERT_MISSED_READING_CATEGORY,
								delay
							); 
							_missedReadingAlertLatestSnoozeTimeInMs = Number.NaN;
							_missedReadingAlertSnoozePeriodInMinutes = 0;
						} else {
							myTrace("in checkAlarms, current missed reading alert is enabled, but the time it's supposed to expire it is not enabled so not setting it");
						}
						
					} else {
						//snoozed no need to do anything
						myTrace("in checkAlarms, missed reading snoozed, _missedReadingAlertLatestSnoozeTimeInMs = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_missedReadingAlertLatestSnoozeTimeInMs)) + ", _missedReadingAlertSnoozePeriodInMinutes = " + _missedReadingAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				} else {// missed reading alert according to current time not enabled, but check if next period has the alert enabled
					if (((now).valueOf() - _missedReadingAlertLatestSnoozeTimeInMs) > _missedReadingAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_missedReadingAlertLatestSnoozeTimeInMs)) {
						myTrace("in checkAlarms, missed reading, current alert not enabled and also not snoozed, checking next alert");
						//get the next alertname
						alertName = listOfAlerts.getNextAlarmName(Number.NaN, "", now);
						alertValue = listOfAlerts.getNextValue(Number.NaN, "", now);
						alertType = Database.getAlertType(alertName);
						if (alertType.enabled) {
							myTrace("in checkAlarms, next alert is enabled");
							var currentHourLocal:int = now.hours;
							var currentMinuteLocal:int = now.minutes;
							var currentSecondsLocal:int = now.seconds;
							var currentTimeInSeconds:int = 3600 * currentHourLocal + 60 * currentMinuteLocal + currentSecondsLocal;
							var fromTimeNextAlertInSeconds:int = listOfAlerts.getNextFromTime(Number.NaN, "", now);
							var delay:int;
							if (fromTimeNextAlertInSeconds > currentTimeInSeconds)
								delay = fromTimeNextAlertInSeconds - currentTimeInSeconds;
							else 
								delay = 24 * 3600  - (currentTimeInSeconds - fromTimeNextAlertInSeconds);
							if (delay < alertValue * 60)
								delay = alertValue * 60;
							myTrace("in checkAlarms, missed reading planned with delay in minutes = " + delay/60);
							latestAlertTypeUsedInMissedReadingNotification = alertType;
							fireAlert(
								alertType, 
								NotificationService.ID_FOR_MISSED_READING_ALERT, 
								ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"), 
								ModelLocator.resourceManagerInstance.getString("alarmservice","missed_reading_alert_notification_alert"),
								alertType.enableVibration,
								alertType.enableLights,
								NotificationService.ID_FOR_ALERT_MISSED_READING_CATEGORY,
								delay
							); 
							_missedReadingAlertLatestSnoozeTimeInMs = Number.NaN;
							_missedReadingAlertSnoozePeriodInMinutes = 0;
						} else {
							//no need to set the notification, on the contrary just cancel any existing notification
							myTrace("in checkAlarms, missed reading, snoozed, and current alert not enabled anymore, so canceling alert and resetting snooze");
							Notifications.service.cancel(NotificationService.ID_FOR_MISSED_READING_ALERT);
							_missedReadingAlertLatestSnoozeTimeInMs = Number.NaN;
							_missedReadingAlertLatestNotificationTime = Number.NaN;
							_missedReadingAlertSnoozePeriodInMinutes = 0;
						}
						
					} else {
						//snoozed no need to do anything
						myTrace("in checkAlarms, missed reading snoozed, _missedReadingAlertLatestSnoozeTimeInMs = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_missedReadingAlertLatestSnoozeTimeInMs)) + ", _missedReadingAlertSnoozePeriodInMinutes = " + _missedReadingAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
					
				}
			}
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
				.enableLights(enableLights)
				.setCategory(categoryId);
			if (alertType.repeatInMinutes > 0)
				notificationBuilder.setRepeatInterval(NotificationRepeatInterval.REPEAT_MINUTE);
			if (delay != 0) {
				notificationBuilder.setDelay(delay);
			}
			if (alertType.sound == ModelLocator.resourceManagerInstance.getString("alerttypeview","no_sound")) {
				notificationBuilder.setSound("../assets/silence-1sec.aif");
			} else {
				for (var cntr:int = 0;cntr < soundsAsDisplayedSplitted.length;cntr++) {
					newSound = soundsAsDisplayedSplitted[cntr];
					if (newSound == alertType.sound) {
						if (cntr == 0) {
							//it's the default sound, nothing to do
						} else {
							notificationBuilder.setSound(soundsAsStoredInAssetsSplitted[cntr]);
						}
						break;
					}
				}
			}
			Notifications.service.notify(notificationBuilder.build());
		}
		
		private static function myTrace(log:String):void {
			Trace.myTrace("AlarmService.as", log);
		}
		
	}
}