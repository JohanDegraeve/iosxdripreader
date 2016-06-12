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
		public static const CLIENT_CHARACTERISTIC_CONFIG:String = "00002902-0000-1000-8000-00805f9b34fb";
		public static const HM_10_SERVICE:String = "0000ffe0-0000-1000-8000-00805f9b34fb";
		public static const HM_RX_TX:String = "0000ffe1-0000-1000-8000-00805f9b34fb";

		public function HM10Attributes()
		{
		}
	}
}