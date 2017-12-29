package events
{
	[Event(name="NightScoutServiceInformation",type="events.NightScoutServiceEvent")]
	[Event(name="BgReadingReceived",type="events.NightScoutServiceEvent")]
	
	public class NightScoutServiceEvent extends GenericEvent
	{
		/**
		 * To pass status information, this is just text that can be shown to the user to display progress info<br>
		 * data.information will be a string with this info. 
		 */
		public static const NIGHTSCOUT_SERVICE_INFORMATION_EVENT:String = "NightScoutServiceInformation";
		
		/**
		 * on or more bgreading received from NS. Only for Follower<br>
		 */
		public static const NIGHTSCOUT_SERVICE_BG_READING_RECEIVED:String = "BgReadingReceived";
		/**
		 * readings that were stored in modellocator by nightscoutservice, are removed
		 */
		public static const NIGHTSCOUT_SERVICE_BG_READINGS_REMOVED:String = "BgReadingsRemoved";
		
		public var data:*;
		
		public function NightScoutServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}