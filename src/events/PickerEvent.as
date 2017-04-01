	/*
	copied from franto.com
	*/										  
package events
{
	import flash.events.Event;
	
	/**
	 * event used by pickers like timepicker, datapicker, eventpicket
	 */
	public class PickerEvent extends Event
	{
		/**
		 * dispatched when user has set a value via picker 
		 */
		public static const PICKER_SET: String = 'PickerSet';
		/**
		 * dispatched when user has canceled the picker
		 */
		public static const PICKER_CANCEL: String = 'PickerCancel';
		
		/**
		 * the value set, type depends on what it's used for, so when using a picker, you need to know what value will be in the event object so you can cast it
		 */
		public var newValue: Object;
		
		/**
		 * the event constructor 
		 */
		public function PickerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}