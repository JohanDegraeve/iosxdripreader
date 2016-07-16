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
package databaseclasses
{
	import flash.events.EventDispatcher;
	
	import services.BluetoothService;
	
	public class BlueToothDevice extends SuperDatabaseClass
	{
		public static const DEFAULT_BLUETOOTH_DEVICE_ID:String = "1465501584186cb0d5f60b3c";
		private static var _instance:BlueToothDevice = new BlueToothDevice(DEFAULT_BLUETOOTH_DEVICE_ID, Number.NaN);//note that in HomeView.mxml, lastmodifiedtimestamp, name and address will be overwritten with values read from the database
		
		/**
		 * in case we need attributes of the superclass (like uniqueid), then we need to get an instance of this class
		 */
		public static function get instance():BlueToothDevice
		{
			return _instance;
		}
		
		private static var _name:String;
		
		/**
		 * name of the device, empty string means not yet assigned to a bluetooth peripheral
		 */
		public static function get name():String
		{
			return _name;
		}
		
		/**
		 * sets the name, also update in database will be done
		 */
		public static function set name(value:String):void
		{
			if (value == _name)
				return;
			
			_name = value;
			if (_name == null)
				_name = "";
			updateDatabase();
		}
		
		private static var _address:String;
		
		/**
		 * address of the device, empty string or null means not yet assigned to a bluetooth peripheral
		 */
		public static function get address():String
		{
			return _address;
		}
		
		/**
		 * sets the address, also update in database will be done
		 */
		public static function set address(value:String):void
		{
			if (value == _address)
				return;
			
			_address = value;
			if (_address == null)
				_address = "";
			updateDatabase();
		}
		
		public function set lastModifiedTimestamp(lastmodifiedtimestamp:Number):void
		{
			_lastModifiedTimestamp = lastmodifiedtimestamp;
		}
		
		public function BlueToothDevice(bluetoothdeviceid:String, lastmodifiedtimestamp:Number)
		{	
			super(bluetoothdeviceid, lastmodifiedtimestamp);
			if (_instance != null) {
				throw new Error("BlueToothDevice class  constructor can not be used");	
			}
			_name = "";
			_address = "";
			//see if a bluetooth device already exists in the database
		}
		
		private static function updateDatabase():void {
			var localdispatcher:EventDispatcher = new EventDispatcher();
			localdispatcher.addEventListener(DatabaseEvent.ERROR_EVENT, error);
			localdispatcher.addEventListener(DatabaseEvent.RESULT_EVENT, result);
			Database.updateBlueToothDevice(address, name, Number.NaN, localdispatcher); 
			function error(de:DatabaseEvent):void {
				localdispatcher.removeEventListener(DatabaseEvent.RESULT_EVENT,error);
				localdispatcher.removeEventListener(DatabaseEvent.ERROR_EVENT,result);
				trace("bluetoothdevice.as error updating name");
			}
			function result(de:DatabaseEvent):void {
				localdispatcher.removeEventListener(DatabaseEvent.RESULT_EVENT,error);
				localdispatcher.removeEventListener(DatabaseEvent.ERROR_EVENT,result);
				trace("bluetoothdevice.as successfully updated name");
			}
		}
		
		/**
		 * sets address and name of bluetoothdevice to empty string, ie there's no device known anymore<br>
		 * also updates database and calls bluetoothservce.forgetdevice
		 */
		public static function forgetBlueToothDevice():void {
			_address = "";
			_name = "";
			updateDatabase();
			BluetoothService.forgetBlueToothDevice();
		}
		
		/**
		 * if name contains BRIDGE (case insensitive) then returns true<br>
		 * otherwise false
		 */
		public static function isXBridge():Boolean {
			return _name.toUpperCase().indexOf("BRIDGE") >= 0;
		}
	}
}