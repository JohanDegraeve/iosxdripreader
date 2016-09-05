package events
{
	import flash.events.Event;
	
	public class TimerServiceEvent extends Event
	{
		[Event(name="BGReadingNotReceivedOnTime",type="events.TimerServiceEvent")]
		
		/**
		 * new BGReading was not received on time<br> 
		 */
		public static const BG_READING_NOT_RECEIVED_ON_TIME:String = "BGReadingNotReceivedOnTime";

		public function TimerServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}