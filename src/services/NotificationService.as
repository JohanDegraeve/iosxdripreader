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
	import com.distriqt.extension.core.Core;
	import com.distriqt.extension.notifications.AuthorisationStatus;
	import com.distriqt.extension.notifications.NotificationRepeatInterval;
	import com.distriqt.extension.notifications.Notifications;
	import com.distriqt.extension.notifications.Service;
	import com.distriqt.extension.notifications.builders.NotificationBuilder;
	import com.distriqt.extension.notifications.events.AuthorisationEvent;
	import com.distriqt.extension.notifications.events.NotificationEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import distriqtkey.DistriqtKey;
	
	import events.NotificationServiceEvent;
	
	
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

		private static var _instance:NotificationService = new NotificationService();

		[ResourceBundle("notificationservice")]
		public static function get instance():NotificationService
		{
			return _instance;
		}

		
		private static var initialStart:Boolean = true;
		
		/*//categories
		private static const IDENTIFIER_STRING_FOR_WAKEUP_CATEGORY:String = "WAKE_UP_CATEGORY";
		public static const IDENTIFIER_STRING_FOR_CALIBRATION_REQUEST_CATEGORY:String = "CALIBRATION_REQUEST_CATEGORY";*/
		
		//Notification ID's
		/**
		 * For wakeup notification - still under test<br>
		 * This is the kind of notification that will be fired when the app has been killed - at least that's the aim 
		 */
		private static const ID_FOR_WAKEUP:int = 1;
		/**
		 * To request extra calibration 
		 */
		public static const ID_FOR_EXTRA_CALIBRATION_REQUEST:int = 2;
		private static const debugMode:Boolean = true;
		/**
		* time in minutes, after which notification will fire<br>
		* If application was killed in between setting the notification and the firing of it, it will effectively fire, and so the user can click it which will cause the 
		* application to launch again 
		*/
		private static const DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES:int = 1;
		/**
		 * when this timer fires, the wakeup notification will be reset to a later timestamp 
		 */
		private static var wakeUpTimer:Timer;
		/**
		 * last time the wakeup notification was being set, means not the fireDate of the notification<br>
		 * in ms 
		 */
		private static var timeOfLastWakeUpNotificationBeingSet:Number;
		/**
		 * timer will be set a numbe rof seconds before notification would fire<br> 
		 */
		private static const timeDifferenceBetweenWakeUpTimerAndWakeUpNotificationInMilliSeconds:int = 5000
		
		public function NotificationService()
		{
			if (_instance != null) {
				throw new Error("RestartNotificationService class constructor can not be used");	
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
					Notifications.service.addEventListener( AuthorisationEvent.CHANGED, authorisationChangedHandler );
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
				Notifications.service.register();
				
				timeOfLastWakeUpNotificationBeingSet = (new Date()).valueOf();
				//setupWakeUpNotification(new Date(timeOfLastWakeUpNotificationBeingSet + DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES * 60 * 1000));
				//setupWakeUpTimer(new Date(timeOfLastWakeUpNotificationBeingSet + DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES * 60 * 1000 - timeDifferenceBetweenWakeUpTimerAndWakeUpNotificationInMilliSeconds));//5 seconds sooner
			}
			
			function notificationHandler(event:NotificationEvent):void {
				if (debugMode) trace("in Notificationservice notificationHandler at " + (new Date()).toLocaleTimeString());
				var notificationServiceEvent:NotificationServiceEvent = new NotificationServiceEvent(NotificationServiceEvent.NOTIFICATION_EVENT);
				notificationServiceEvent.data = event;
				_instance.dispatchEvent(notificationServiceEvent);
			}
			
		}
		
		/**
		 * time should be later than now, otherwise it will be set to now, which means the timer will fire immediately ? 
		 */
		private static function setupWakeUpTimer(time:Date):void {
			if (wakeUpTimer != null) {
				if (wakeUpTimer.running)
					wakeUpTimer.stop();
			}
			
			var delayToSet:Number = time.valueOf() - (new Date()).valueOf();
			if (delayToSet < 0)
				delayToSet = 0;
			
			if (debugMode) trace("setting wakeuptimer with delay of (ms) " + delayToSet);
			wakeUpTimer = new Timer(delayToSet, 1);
			wakeUpTimer.addEventListener(TimerEvent.TIMER, handleWakeUpTimerEvent);
			wakeUpTimer.start();
		}
		
		private static function handleWakeUpTimerEvent(event:Event):void {
			if (debugMode) trace("in handleWakeUpTimerEvent at " + (new Date()).toLocaleTimeString()); 
			
			//normally (the time now) = timeOfLastWakeUpNotificationBeingSet + DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES * 60 * 1000 - 5 seconds
			// so (the time now) + 5 seconds = timeOfLastWakeUpNotificationBeingSet + DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES * 60 * 1000
			// or timeOfLastWakeUpNotificationBeingSet + DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES * 60 * 1000  = (the time now) + 5 seconds
			timeOfLastWakeUpNotificationBeingSet = timeOfLastWakeUpNotificationBeingSet + (DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES * 60 * 1000);
			//so no timeOfLastWakeUpNotificationBeingSet = the time now + 5 seconds
			//so not setting timeOfLastWakeUpNotificationBeingSet to now, but setting it exactly DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES further then previous wake up notification
			
			setupWakeUpNotification(new Date(timeOfLastWakeUpNotificationBeingSet +  (DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES * 60 * 1000)));
			setupWakeUpTimer(new Date(timeOfLastWakeUpNotificationBeingSet + DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES * 60 * 1000 - timeDifferenceBetweenWakeUpTimerAndWakeUpNotificationInMilliSeconds * 2));//two times -5000 because timeOfLastWakeUpNotificationBeingSet = the time now + 5 seconds
		}
		
		private static function setupWakeUpNotification(fireDate:Date):void {
			if (debugMode) trace("in setupWakeUpNotification at " + (new Date()).toLocaleTimeString());
		 	if (debugMode) trace("setting notification at " + fireDate.toLocaleTimeString());
			Notifications.service.notify(
				new NotificationBuilder()
				.setId(ID_FOR_WAKEUP)
				.setAlert("notification alert")
				.setTitle("notification title")
				.setBody("notification body")
				.setFireDate(fireDate)
				.setRepeatInterval(NotificationRepeatInterval.REPEAT_NONE)
				.build());
		}
	}
}