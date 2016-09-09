package events
{
	import flash.events.Event;
	
	public class TimerServiceEvent extends Event
	{
		[Event(name="BGReadingNotReceivedOnTime",type="events.TimerServiceEvent")]
		
		/**
		 * new BGReading was not received on time<br>
		 *  
		 * Bg reading is expected every 5 minutes<br>
		 * xbridge holds data for 1 minute, so it could be that bgreading arrives 6 minutes before previous one<br>
		 * adding 10 seconds<br>
		 * This will only start once the first bgreading is received. So it can not be used as long as the xdrip is not scanned and a first reading is received<br>
		 *  
		 */
		public static const BG_READING_NOT_RECEIVED_ON_TIME:String = "BGReadingNotReceivedOnTime";

		public function TimerServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}