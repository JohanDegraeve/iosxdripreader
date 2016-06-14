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
	import flash.events.Event;

	[Event(name="ResultEvent",type="events.BlueToothServiceEvent")]
	[Event(name="ErrorEvent",type="events.BlueToothServiceEvent")]
	[Event(name="BluetoothStatusChangedEvent",type="events.BlueToothServiceEvent")]
	[Event(name="BluetoothServiceInformation",type="events.BlueToothServiceEvent")]

	/**
	 * used by bluetoothservice to notify on all kinds of events : information messages like bluetooth state change, bluetooth state change,
	 * result received from transmitter, etc.. 
	 */
	public class BlueToothServiceEvent extends Event
	{
		/**
		 * generic event to inform about the result of an event, specifically for case where a dispatcher has been supplied by the client 
		 */
		public static const RESULT_EVENT:String = "ResultEvent";
		/**
		 * generic event to inform about the error that happened, specifically for case where a dispatcher has been supplied by the client 
		 */
		public static const ERROR_EVENT:String = "ErrorEvent";
		/**
		* to publish the bluetooth status and also device status change<br>
		 * data.status will be a string that contains the status which can be :<br>
		 * &nbsp&nbsp&nbsp 	STATE_ON A constant for this state is BluetoothLEState.STATE_ON<br>
		 * &nbsp&nbsp&nbsp 	STATE_OFF A constant for this state is BluetoothLEState.STATE_OFF<br>
		 * &nbsp&nbsp&nbsp 	STATE_RESETTING A constant for this state is BluetoothLEState.STATE_RESETTING<br>
		 * &nbsp&nbsp&nbsp 	STATE_UNAUTHORISED A constant for this state is BluetoothLEState.STATE_UNAUTHORISED<br>
		 * &nbsp&nbsp&nbsp 	STATE_UNSUPPORTED A constant for this state is BluetoothLEState.STATE_UNSUPPORTED<br>
		 * &nbsp&nbsp&nbsp 	STATE_UNKNOWN A constant for this state is BluetoothLEState.STATE_UNKNOWN<br>
		 * &nbsp&nbsp&nbsp 	DEVICE_DISCONNECTED A constant for this state is BluetoothService.BLUETOOTH_DEVICE_DISCONNECTED<br>
		 * &nbsp&nbsp&nbsp 	DEVICE_CONNECTED A constant for this state is BluetoothService.BLUETOOTH_DEVICE_CONNECTED<br>
		*/
		public static const BLUETOOTH_STATUS_CHANGED_EVENT:String = "BluetoothStatusChangedEvent";
		/**
		 * To pass status information, this is just text that can be shown to the user to display progress info<br>
		 * data.information will be a string with this info. 
		 */
		public static const BLUETOOTH_SERVICE_INFORMATION_EVENT:String = "BluetoothServiceInformation";
		
		public var data:*;

		public function BlueToothServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}