package events
{
	import flash.events.Event;
	
	public class DeepSleepServiceEvent extends Event
	{
		[Event(name="DeepSleepServiceTimerEvent",type="events.DeepSleepServiceEvent")]
		
		/**
		 * event to inform that dialogservice is initiated.<br>
		 */
		public static const DEEP_SLEEP_SERVICE_TIMER_EVENT:String = "DeepSleepServiceTimerEvent";
		
		public var data:*;
		
		public function DeepSleepServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}