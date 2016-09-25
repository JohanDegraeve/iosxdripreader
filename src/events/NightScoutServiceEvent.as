package events
{
	import flash.events.Event;

	[Event(name="NightScoutServiceInformation",type="events.NightScoutServiceEvent")]
	
	public class NightScoutServiceEvent extends Event
	{
		/**
		 * To pass status information, this is just text that can be shown to the user to display progress info<br>
		 * data.information will be a string with this info. 
		 */
		public static const NIGHTSCOUT_SERVICE_INFORMATION_EVENT:String = "NightScoutServiceInformation";
		
		public var data:*;
		
		public function NightScoutServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}