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
	import com.hurlant.crypto.hash.SHA1;
	import com.hurlant.util.Hex;
	
	import flash.utils.ByteArray;

	public class UniqueId
	{
		public static var ALPHA_CHAR_CODES:Array = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"];
		
		public function UniqueId()
		{
		}
		
		/**
		 * creates an event id of 24 chars, compliant with the way Nightscout expects it
		 */
		public static function createEventId():String {
			var eventId:Array = new Array(24);
			var date:String = (new Date()).valueOf().toString();
			for (var i:int = 0; i < date.length; i++) {
				eventId[i] = date.charAt(i);
			}
			for (; i < eventId.length;i++) {
				eventId[i] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  16)];
			}
			var returnValue:String = "";
			for (i = 0; i < eventId.length; i++)
				returnValue += eventId[i];
			return returnValue;
		}
		
		/**
		 * creates random string of digits only, length 
		 */
		public static function createNonce(length:int):String {
			var nonce:Array = new Array(length);
			for (var i:int = 0; i < length; i++) {
				nonce[i] = ALPHA_CHAR_CODES[Math.floor(Math.random() *  10)];
			}
			var returnValue:String = "";
			for (i = 0; i < nonce.length; i++)
			returnValue += nonce[i];
			return returnValue;
		}
		
	}
}