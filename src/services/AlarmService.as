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
		
		private static var snoozeValueMinutes:Array = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 75, 90, 120, 150, 180, 240, 300, 360, 420, 480, 540, 600];
		private static var snoozeValueStrings:Array = ["5 minutes", "10 minutes", "15 minutes", "20 minutes", "25 minutes", "30 minutes", "35 minutes",
			"40 minutes", "45 minutes", "50 minutes", "55 minutes", "1 hour", "1 hour 15 minutes", "1,5 hours", "2 hours", "2,5 hours", "3 hours", "4 hours",
			"5 hours", "6 hours", "7 hours", "8 hours", "9 hours", "10 hours"];
		
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
			for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
				snoozeValueStrings[cntr] = (snoozeValueStrings[cntr] as String).replace("minutes", ModelLocator.resourceManagerInstance.getString("alarmservice","minutes"));
				snoozeValueStrings[cntr] = (snoozeValueStrings[cntr] as String).replace("hour", ModelLocator.resourceManagerInstance.getString("alarmservice","hour"));
				snoozeValueStrings[cntr] = (snoozeValueStrings[cntr] as String).replace("hours", ModelLocator.resourceManagerInstance.getString("alarmservice","hours"));
			}
		}
		
		private static function notificationReceived(event:NotificationServiceEvent):void {
			if (event != null) {
				var notificationEvent:NotificationEvent = event.data as NotificationEvent;
				var listOfAlerts:FromtimeAndValueArrayCollection = FromtimeAndValueArrayCollection.createList(
					CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_LOW_ALERT));
				var alertName:String = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
				var alertType:AlertType = Database.getAlertType(alertName);
				if (notificationEvent.id == NotificationService.ID_FOR_LOW_ALERT) {
					myTrace("in notificationReceived with id = ID_FOR_LOW_ALERT, cancelling notification");
					Notifications.service.cancel(NotificationService.ID_FOR_LOW_ALERT);
					var index:int = 0;
					for (var cntr:int = 0;cntr < snoozeValueMinutes.length;cntr++) {
						if ((snoozeValueMinutes[cntr]) >= alertType.defaultSnoozePeriodInMinutes) {
							index = cntr;
							break;
						}
					}
					if (notificationEvent.identifier == null) {
						var snoozePeriodPicker:DialogView = Dialog.service.create(
							new PickerDialogBuilder()
							.setTitle(ModelLocator.resourceManagerInstance.getString('alarmservice', 'snooze_picker_title'))
							.setCancelLabel(ModelLocator.resourceManagerInstance.getString("general","cancel"))
							.setAcceptLabel("Ok")
							.addColumn( snoozeValueStrings, index )
							.build()
						);
						snoozePeriodPicker.addEventListener( DialogViewEvent.CLOSED, picker_closedHandler );
						snoozePeriodPicker.show();
					} else if (notificationEvent.identifier == NotificationService.ID_FOR_LOW_ALERT_SNOOZE_IDENTIFIER) {
						myTrace("in notificationReceived with id = ID_FOR_LOW_ALERT, snoozing the notification");
						_lowAlertSnoozePeriodInMinutes = alertType.defaultSnoozePeriodInMinutes;
						_lowAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
					}
				}
			}
			
			function picker_closedHandler(event:DialogViewEvent): void {
				myTrace("in picker_closedHandler snoozing the notification for " + snoozeValueStrings[event.indexes[0]]);
				_lowAlertSnoozePeriodInMinutes = snoozeValueMinutes[event.indexes[0]];
				_lowAlertLatestSnoozeTimeInMs = (new Date()).valueOf();
			}
		}
		
		private static function checkAlarms(be:TransmitterServiceEvent):void {
			myTrace("in checkAlarms");
			var lastbgreading:BgReading = BgReading.lastNoSensor();
			//low alert
			if (lastbgreading != null) {
				var listOfAlerts:FromtimeAndValueArrayCollection = FromtimeAndValueArrayCollection.createList(
					CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_LOW_ALERT));
				var alertValue:Number = listOfAlerts.getValue(Number.NaN, "", new Date());
				var alertName:String = listOfAlerts.getAlarmName(Number.NaN, "", new Date());
				var alertType:AlertType = Database.getAlertType(alertName);
				if (alertType.enabled) {
					//first check if snoozeperiod is passed, checking first for value would generate multiple alarms in case the sensor is unstable
					if (((new Date()).valueOf() - _lowAlertLatestSnoozeTimeInMs) > _lowAlertSnoozePeriodInMinutes * 60 * 1000
						||
						isNaN(_lowAlertLatestSnoozeTimeInMs)) {
						myTrace("in checkAlarms, alarm not snoozed (anymore)");
						//not snoozed

						if (alertValue > BgReading.lastNoSensor().calculatedValue) {
							myTrace("in checkAlarms, alertvalue to low");
							var notificationBuilder:NotificationBuilder = new NotificationBuilder()
								.setId(NotificationService.ID_FOR_LOW_ALERT)
								.setAlert(ModelLocator.resourceManagerInstance.getString("alarmservice","low_alert_notification_alert_text"))
								.setTitle(ModelLocator.resourceManagerInstance.getString("alarmservice","low_alert_notification_alert_text"))
								.setBody(" ")
								.enableVibration(alertType.enableVibration)
								.enableLights(alertType.enableLights)
								.setCategory(NotificationService.ID_FOR_LOW_ALERT_CATEGORY);
							if (alertType.repeatInMinutes > 0)
								notificationBuilder.setRepeatInterval(NotificationRepeatInterval.REPEAT_MINUTE);
							if (alertType.sound == ModelLocator.resourceManagerInstance.getString("alerttypeview","no_sound")) {
								notificationBuilder.setSound("");
							} else {
								var soundsAsDisplayed:String = ModelLocator.resourceManagerInstance.getString("alerttypeview","sound_names_as_displayed_can_be_translated_must_match_above_list");
								var soundsAsStoredInAssets:String = ModelLocator.resourceManagerInstance.getString("alerttypeview","sound_names_as_in_assets_no_translation_needed_comma_seperated");
								var soundsAsDisplayedSplitted:Array = soundsAsDisplayed.split(',');
								var soundsAsStoredInAssetsSplitted:Array = soundsAsStoredInAssets.split(',');
								for (var cntr:int = 0;cntr < soundsAsDisplayedSplitted.length;cntr++) {
									var newSound:String = soundsAsDisplayedSplitted[cntr];
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
							_lowAlertLatestSnoozeTimeInMs = Number.NaN;
							_lowAlertSnoozePeriodInMinutes = 0;
						}
					} else {
						//snoozed no need to do anything
						myTrace("in checkAlarms, alarm snoozed, _lowAlertLatestSnoozeTimeInMs = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(_lowAlertLatestSnoozeTimeInMs)) + ", _lowAlertSnoozePeriodInMinutes = " + _lowAlertSnoozePeriodInMinutes + ", actual time = " + DateTimeUtilities.createNSFormattedDateAndTime(new Date()));
					}
				} else {
					//remove notification, even if there isn't any
					Notifications.service.cancel(NotificationService.ID_FOR_LOW_ALERT);
					_lowAlertLatestSnoozeTimeInMs = Number.NaN;
					_lowAlertLatestNotificationTime = Number.NaN;
					_lowAlertSnoozePeriodInMinutes = 0;
				}
			}
		}
		
		private static function myTrace(log:String):void {
			Trace.myTrace("AlarmService.as", log);
		}

	}
}