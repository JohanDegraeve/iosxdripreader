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
package services
{
	import com.distriqt.extension.application.Application;
	import com.distriqt.extension.application.events.ApplicationStateEvent;
	import com.distriqt.extension.core.Core;
	import com.distriqt.extension.notifications.AuthorisationStatus;
	import com.distriqt.extension.notifications.Notifications;
	import com.distriqt.extension.notifications.Service;
	import com.distriqt.extension.notifications.builders.NotificationBuilder;
	import com.distriqt.extension.notifications.events.AuthorisationEvent;
	import com.distriqt.extension.notifications.events.NotificationEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import Utilities.BgGraphBuilder;
	
	import databaseclasses.BgReading;
	import databaseclasses.Calibration;
	import databaseclasses.CalibrationRequest;
	import databaseclasses.CommonSettings;
	
	import distriqtkey.DistriqtKey;
	
	import events.CalibrationServiceEvent;
	import events.NotificationServiceEvent;
	import events.TimerServiceEvent;
	import events.TransmitterServiceEvent;
	
	import model.ModelLocator;
	
	/**
	 * This service<br>
	 * - registers for notifications<br>
	 * - defines id's<br>
	 * At the same time this service will at regular intervals set a notification for the end-user<br>
	 * each time again (period to be defined - probably in the settings) the notification will be reset later<br>
	 * Goal is that whenevever the application stops, also this service will not run anymore, hence the notification will expire, the user
	 * will know the application stopped and by just clicking it it will re-open and restart.
	 * 
	 * It also dispatches the notifications as NotificationServiceEvent 
	 */
	public class NotificationService extends EventDispatcher
	{
		
		[ResourceBundle("notificationservice")]
		[ResourceBundle("calibrationservice")]
		
		private static var _instance:NotificationService = new NotificationService();
		
		public static function get instance():NotificationService
		{
			return _instance;
		}
		
		
		private static var initialStart:Boolean = true;
		
		//Notification ID's
		/**
		 * To request extra calibration 
		 */
		public static const ID_FOR_EXTRA_CALIBRATION_REQUEST:int = 1;
		/**
		 * for the notification with currently measured bg value<br>
		 * this is the always on notification
		 */
		public static const ID_FOR_BG_VALUE:int = 2;
		/**
		 * to request initial calibration
		 */
		public static const ID_FOR_REQUEST_CALIBRATION:int = 3;
		
		private static const debugMode:Boolean = false;
		
		public function NotificationService()
		{
			if (_instance != null) {
				throw new Error("NotificationService class constructor can not be used");	
			}
		}
		
		
		
		public static function init():void {
			if (!initialStart)
				return;
			else
				initialStart = false;
			
			Core.init();
			Notifications.init(DistriqtKey.distriqtKey);
			if (!Notifications.isSupported) {
				return;
			}
			
			var service:Service = new Service();
			service.enableNotificationsWhenActive = true;
			
			Notifications.service.setup(service);
			
			switch (Notifications.service.authorisationStatus())
			{
				case AuthorisationStatus.AUTHORISED:
					// This device has been authorised.
					// You can register this device and expect to display notifications
					register();
					break;
				
				case AuthorisationStatus.NOT_DETERMINED:
					// You are yet to ask for authorisation to display notifications
					// At this point you should consider your strategy to get your user to authorise
					// notifications by explaining what the application will provide
					Notifications.service.addEventListener(AuthorisationEvent.CHANGED, authorisationChangedHandler);
					Notifications.service.requestAuthorisation();
					break;
				
				case AuthorisationStatus.DENIED:
					// The user has disabled notifications
					// TODO Advise your user of the lack of notifications as you see fit
					break;
			}
			
			function authorisationChangedHandler(event:AuthorisationEvent):void
			{
				switch (event.status) {
					case AuthorisationStatus.AUTHORISED:
						// This device has been authorised.
						// You can register this device and expect to display notifications
						register();
						break;
				}
			}
			
			/**
			 * will obviously register and also add eventlisteners
			 */
			function register():void {
				Notifications.service.addEventListener(NotificationEvent.NOTIFICATION_SELECTED, notificationHandler);
				Notifications.service.addEventListener(NotificationEvent.NOTIFICATION, notificationHandler);
				TimerService.instance.addEventListener(TimerServiceEvent.BG_READING_NOT_RECEIVED_ON_TIME, bgReadingNotReceivedOnTime);
				CalibrationService.instance.addEventListener(CalibrationServiceEvent.INITIAL_CALIBRATION_EVENT, updateAllNotifications);
				TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, bgReadingEventReceived);
				if (Application.isSupported) {
					Application.service.addEventListener(ApplicationStateEvent.DEACTIVATE, application_deactivateHandler);
				}
				Notifications.service.register();
				_instance.dispatchEvent(new NotificationServiceEvent(NotificationServiceEvent.NOTIFICATION_SERVICE_INITIATED_EVENT));
				
			}
			
			function application_deactivateHandler(event:ApplicationStateEvent):void {
				trace("in application_deactivateHandler, event.code = " + event.code);
				switch (event.code) 
				{
					case ApplicationStateEvent.CODE_LOCK:
					//if user locks the device, then immediately (in case the sensor is already calibrated), the always on notification will again be shown
					if (Calibration.allForSensor().length >= 2) {
						var lastBgReading:BgReading = BgReading.lastNoSensor();
						if (lastBgReading != null) {
							if (lastBgReading.calculatedValue != 0) {
								if ((new Date().getTime()) - (60000 * 11) - lastBgReading.timestamp > 0) {
								} else {
									updateAllNotifications(null);
								}
							}
						} else {
						}
					}
					break;
				}
			}
			
			function initialCalibrationEventReceived(event:CalibrationServiceEvent):void {
				updateAllNotifications(null);
			}
			
			function bgReadingEventReceived(event:TransmitterServiceEvent):void {
				if (Calibration.allForSensor().length >= 2) {
					updateAllNotifications(null);
				}
			}
			
			function bgReadingNotReceivedOnTime(event:TimerServiceEvent):void {
				if (Calibration.allForSensor().length >= 2) {
					updateAllNotifications(null);
				}
			}
			
			function notificationHandler(event:NotificationEvent):void {
				if (debugMode) trace("in Notificationservice notificationHandler at " + (new Date()).toLocaleTimeString());
				var notificationServiceEvent:NotificationServiceEvent = new NotificationServiceEvent(NotificationServiceEvent.NOTIFICATION_EVENT);
				notificationServiceEvent.data = event;
				_instance.dispatchEvent(notificationServiceEvent);
			}
		}
		
		private static function dispatchInformation(information:String):void {
			var notificationserviceEvent:NotificationServiceEvent = new NotificationServiceEvent(NotificationServiceEvent.LOG_INFO);
			notificationserviceEvent.data = new Object();
			notificationserviceEvent.data.information = information;
			_instance.dispatchEvent(notificationserviceEvent);
		}
		
		/**
		 * simply clears all notifications 
		 */
		public static function clearAllNotifications():void {
			Notifications.service.cancelAll();
		}
		
		/**
		 * will clear all existing notifications and recreate<br>
		 * - notification with bloodglucose level, on the condition that there's a least two calibrations for the current sensor<br>
		 * - check calibrationrequest notification<br>
		 * 
		 */
		public static function updateAllNotifications(be:Event, loginfo:String = null):void {
			if (loginfo != null) {
				dispatchInformation("log info received from " + loginfo);
			}
			Notifications.service.cancelAll();
			
			//start with bgreading notification
			if (Calibration.allForSensor().length >= 2) {
				var lastBgReading:BgReading = BgReading.lastNoSensor(); 
				var valueToShow:String = "";
				if (lastBgReading != null) {
					if (lastBgReading.calculatedValue != 0) {
						if ((new Date().getTime()) - (60000 * 11) - lastBgReading.timestamp > 0) {
							valueToShow = "---"
						} else {
							valueToShow = BgGraphBuilder.unitizedString(lastBgReading.calculatedValue, true);
							if (!lastBgReading.hideSlope) {
								valueToShow += " " + lastBgReading.slopeArrow();
							}
						}
					}
				} else {
					valueToShow = "---"
				}
				
				Notifications.service.notify(
					new NotificationBuilder()
					.setId(NotificationService.ID_FOR_BG_VALUE)
					.setAlert("")
					.setTitle(valueToShow)
					.setSound("")
					.enableVibration(false)
					.enableLights(false)
					.build());
			}
			
			//next is the calibrationrequest notification
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_ADDITIONAL_CALIBRATION_REQUEST_ALERT) == "true") {
				if (Calibration.allForSensor().length >= 2 && BgReading.last30Minutes().length >= 2) {
					if (CalibrationRequest.shouldRequestCalibration(ModelLocator.bgReadings.getItemAt(ModelLocator.bgReadings.length - 1) as BgReading)) {
						Notifications.service.notify(
							new NotificationBuilder()
							.setId(NotificationService.ID_FOR_EXTRA_CALIBRATION_REQUEST)
							.setAlert(ModelLocator.resourceManagerInstance.getString("calibrationservice","calibration_request_alert"))
							.setTitle(ModelLocator.resourceManagerInstance.getString("calibrationservice","calibration_request_title"))
							.setBody(ModelLocator.resourceManagerInstance.getString("calibrationservice","calibration_request_body"))
							.enableLights(true)
							.enableVibration(true)
							.build());
					}
				}
			}
		}
	}
}