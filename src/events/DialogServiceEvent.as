package events
{
	import flash.events.Event;

	public class DialogServiceEvent extends Event
	{
		[Event(name="DialogServiceInitiatedEvent",type="events.DialogServiceEvent")]
		
		/**
		 * event to inform that dialogservice is initiated.<br>
		 */
		public static const DIALOG_SERVICE_INITIATED_EVENT:String = "DialogServiceInitiatedEvent";
		
		public var data:*;
		
		public function DialogServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}