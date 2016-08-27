package events
{
	import flash.events.Event;
	
	public class NotificationServiceEvent extends Event
	{
		/**
		 * event to inform about a notifiation event.<br>
		 * When a user selects a notification, notificationservice is actually going to receive that event, and just redispatches it so that
		 * it can be processed by those who are interested<br>
		 * <br>
		 * data will be the notification ie an object of type NotificationEvent
		 */
		public static const NOTIFICATION_EVENT:String = "NotificationEvent";
		
		public var data:*;
		
		public function NotificationServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}