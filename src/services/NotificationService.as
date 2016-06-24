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
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import model.ModelLocator;
	
	/**
	 * This service registers notifications as required.<br>
	 * At the same time this service will at regular intervals set a notification for the end-user<br>
	 * each time again (period to be defined - probably in the settings) the notification will be reset later<br>
	 * Goal is that whenevever the application stops, also this service will not run anymore, hence the notification will expire, the user
	 * will know the application stopped and by just clicking it it will re-open and restart. 
	 */
	public class NotificationService
	{
		public static var instance:NotificationService = new NotificationService();
		
		private static var initialStart:Boolean = true;
		
		private static const IDENTIFIER_STRING_FOR_WAKEUP_CATEGORY:String = "WAKE_UP_CATEGORY";
		private static const ID_FOR_WAKEUP_CATEGORY:int = 1;
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
			if (instance != null) {
				throw new Error("RestartNotificationService class constructor can not be used");	
			}
			if (!initialStart)
				return;
			else
				initialStart = false;
			
			Core.init();
			Notifications.init(ModelLocator.resourceManagerInstance.getString('secrets','distriqt-key'));
			if (Notifications.isSupported) {
				init();
			}
		}
		
		public static function instantiate():void {
		}
		
		private static function init():void {
			var service:Service = new Service();
			
			//Create and add category for wake up notification, ie the notification that will be fired when the app didn't run for more than x minutes
			/*var wakeupCategory:Category = new CategoryBuilder()
				.setIdentifier("IDENTIFIER_FOR_WAKEUP_CATEGORY")
				.build();
			service.categories.push(wakeupCategory);*/
			
			//do the same as above example for alarm categories
			//then store the integer that is returned, needed for future remove for example
			
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
					// Advise your user of the lack of notifications as you see fit
					break;
			}
			
			function authorisationChangedHandler(event:AuthorisationEvent):void
			{
				switch (event.status) {
					case AuthorisationStatus.AUTHORISED:
						// This device has been authorised.
						// You can register this device and expect to display notifications
						register();
						timeOfLastWakeUpNotificationBeingSet = (new Date()).valueOf();
						setupWakeUpNotification(new Date(timeOfLastWakeUpNotificationBeingSet + DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES * 60 * 1000));
						setupWakeUpTimer(new Date(timeOfLastWakeUpNotificationBeingSet + DELAY_FOR_WAKEUP_CATEGORY_IN_MINUTES * 60 * 1000 - timeDifferenceBetweenWakeUpTimerAndWakeUpNotificationInMilliSeconds));//5 seconds sooner
						break;
				}
			}
			
			/**
			 * will obviously register and also add eventlisteners
			 */
			function register():void {
				Notifications.service.addEventListener(NotificationEvent.NOTIFICATION, notificationHandler);
				Notifications.service.addEventListener(NotificationEvent.NOTIFICATION_SELECTED, notificationHandler);
				Notifications.service.addEventListener(NotificationEvent.ACTION, actionHandler);
				
				Notifications.service.register();
			}
			
			function notificationHandler(event:NotificationEvent):void {
				trace("in notificationHandler at " + (new Date()).toLocaleTimeString());
			}
			
			function actionHandler(event:NotificationEvent):void {
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
			
			trace("setting wakeuptimer with delay of (ms) " + delayToSet);
			wakeUpTimer = new Timer(delayToSet, 1);
			wakeUpTimer.addEventListener(TimerEvent.TIMER, handleWakeUpTimerEvent);
			wakeUpTimer.start();
		}
		
		private static function handleWakeUpTimerEvent(event:Event):void {
			trace("in handleWakeUpTimerEvent at " + (new Date()).toLocaleTimeString()); 
			
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
			trace("in setupWakeUpNotification at " + (new Date()).toLocaleTimeString());
		 	trace("setting notification at " + fireDate.toLocaleTimeString());
			Notifications.service.notify(
				new NotificationBuilder()
				.setId(ID_FOR_WAKEUP_CATEGORY)
				.setAlert("notification alert")
				.setTitle("notification title")
				.setBody("notification body")
				.setCategory(IDENTIFIER_STRING_FOR_WAKEUP_CATEGORY)
				.setFireDate(fireDate)
				.setRepeatInterval(NotificationRepeatInterval.REPEAT_QUARTER)
				.build());
		}
	}
}