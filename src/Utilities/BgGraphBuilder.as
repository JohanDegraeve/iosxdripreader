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
	import databaseclasses.BgReading;
	
	public class BgGraphBuilder
	{
		public static const MAX_SLOPE_MINUTES:int = 21;
		
		public function BgGraphBuilder()
		{
		}
		
		/**
		 * unitIsMgDl = true if unit as set by user is mgdl<br>
		 * value in mgdl<br>
		 */
		public static function unitizedString(value:Number, unitIsMgDl:Boolean):String {
			var returnValue:String;
			if (value >= 400) {
				returnValue = "HIGH";
			} else if (value >= 40) {
				if(unitIsMgDl) {
					returnValue = Math.round(value).toString();
				} else {
					returnValue = ((Math.round(value * BgReading.MGDL_TO_MMOLL * 10))/10).toString();
				}
			} else if (value > 12) {
				returnValue = "LOW";
			} else {
				switch(value) {
					case 0:
						returnValue = "??0";
						break;
					case 1:
						returnValue = "?SN";
						break;
					case 2:
						returnValue = "??2";
						break;
					case 3:
						returnValue = "?NA";
						break;
					case 5:
						returnValue = "?NC";
						break;
					case 6:
						returnValue = "?CD";
						break;
					case 9:
						returnValue = "?AD";
						break;
					case 12:
						returnValue = "?RF";
						break;
					default:
						returnValue = "???";
						break;
				}
			}
			return returnValue;
		}
	}
}