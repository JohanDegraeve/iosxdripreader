package events
{
	import flash.events.Event;

	[Event(name="NightScoutServiceInformation",type="events.NightScoutServiceEvent")]
	[Event(name="UploadFailedEvent",type="events.NightScoutServiceEvent")]
	[Event(name="UploadSucceededEvent",type="events.NightScoutServiceEvent")]
	[Event(name="UploadNoData",type="events.NightScoutServiceEvent")]
	
	public class NightScoutServiceEvent extends Event
	{
		/**
		 * To pass status information, this is just text that can be shown to the user to display progress info<br>
		 * data.information will be a string with this info. 
		 */
		public static const NIGHTSCOUT_SERVICE_INFORMATION_EVENT:String = "NightScoutServiceInformation";
		
		/**
		 * there was data to upload, and an attempt was done to get data but that failed
		 */
		public static const UPLOAD_FAILED:String = "UploadFailedEvent";
		/**
		 * there was data to upload, and an attempt was done to get data which succeded
		 */
		public static const UPLOAD_SUCCEEDED:String = "UploadSucceededEvent";
		/**
		 * there was no data to upload
		 */
		public static const UPLOAD_NO_DATA:String = "UploadNoData";
		
		public var data:*;
		
		public function NightScoutServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}