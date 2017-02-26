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
package Utilities
{
	/**
	 * same definition as in xdrip Android 
	 */
	public class HM10Attributes
	{
		public static const HM_10_SERVICE_G4:String = "0000ffe0-0000-1000-8000-00805f9b34fb"; 
		public static const HM_10_SERVICE_G5:String = "F8083532-849E-531C-C594-30F1F86A4EA5"; 
		public static const HM_RX_TX_G4:String = "0000ffe1-0000-1000-8000-00805f9b34fb";
		public static const G5_Communication_Characteristic_UUID:String = "F8083533-849E-531C-C594-30F1F86A4EA5";
		public static const G5_Control_Characteristic_UUID:String = "F8083534-849E-531C-C594-30F1F86A4EA5";
		public static const G5_Authentication_Characteristic_UUID:String = "F8083535-849E-531C-C594-30F1F86A4EA5";
		/**
		 * only to be used in tracing, to get the name of a UUID 
		 */
		public var UUIDMap:Object;

		private static var _instance:HM10Attributes = new HM10Attributes();
		
		public static function get instance():HM10Attributes
		{
			return _instance;
		}
		

		public function HM10Attributes()
		{
			UUIDMap = new Object();
			UUIDMap.HM_10_SERVICE_G4 = "HM_10_SERVICE_G4";
			UUIDMap.HM_10_SERVICE_G5 = "HM_10_SERVICE_G5";
			UUIDMap.HM_RX_TX_G4 = "HM_RX_TX_G4";
			UUIDMap.G5_Communication_Characteristic_UUID = "G5_Communication_Characteristic_UUID";
			UUIDMap.G5_Control_Characteristic_UUID = "G5_Control_Characteristic_UUID";
			UUIDMap.G5_Authentication_Characteristic_UUID = "G5_Authentication_Characteristic_UUID";
		}
	}
}