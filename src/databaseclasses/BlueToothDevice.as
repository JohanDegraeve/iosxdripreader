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
	public class BlueToothDevice extends SuperDatabaseClass
	{
		private static var instance:BlueToothDevice = new BlueToothDevice();
		
		private static var _name:String;

		/**
		 * name of the device, empty string means not yet assigned to a bluetooth peripheral
		 */
		public static function get name():String
		{
			return _name;
		}

		/**
		 * @private
		 */
		public static function set name(value:String):void
		{
			_name = value;
			if (_name == null)
				_name = "";
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
		 * @private
		 */
		public static function set address(value:String):void
		{
			_address = value;
			if (_address == null)
				_address = "";
		}

		private static var _connected:Boolean;

		/**
		 * connected or not to a peripheral
		 */
		public static function get connected():Boolean
		{
			return _connected;
		}

		/**
		 * @private
		 */
		public static function set connected(value:Boolean):void
		{
			_connected = value;
		}

		
		private static var _uniqueId:String;

		public static function get uniqueId():String
		{
			return _uniqueId;
		}

		public static function deviceKnown():Boolean {
			return _name != "";
		}
		
		public function BlueToothDevice()
		{	
			if (instance != null) {
				throw new Error("BlueToothDevice class  constructor can not be used");	
			}
			_name = "";
			_address = "";
			_connected = false;
			//see if a bluetooth device already exists in the database
			
		}
		
	}
}