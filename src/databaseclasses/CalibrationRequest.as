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
 
 * MOST OF THIS CODE HERE IS COPIED FROM THE xDRIP-EXPERIMENTAL PROJECT AND PORTED
 * see https://github.com/StephenBlackWasAlreadyTaken/xDrip-Experimental
 * 
 */
package databaseclasses
{
	public class CalibrationRequest extends SuperDatabaseClass
	{
		private static const MAX:int = 250;
		private static const MIN:int = 70;
		
		private var _requestIfAbove:Number;

		public function get requestIfAbove():Number
		{
			return _requestIfAbove;
		}

		private var _requestIfBelow:Number;

		public function get requestIfBelow():Number
		{
			return _requestIfBelow;
		}

		
		/**
		 * if calibrationrequestid = null, then a new value will be assigned by the constructor<br>
		 * if lastmodifiedtimestamp = Number.NaN, then current time will be assigned by the constructor<br>
		 * no database insert !
		 */
		public function CalibrationRequest(requestIfAbove:Number, requestIfBelow:Number, calibrationrequestid:String, lastmodifiedtimestamp:Number)
		{
			super(calibrationrequestid, lastmodifiedtimestamp);
			_requestIfAbove = requestIfAbove;
			_requestIfBelow = requestIfBelow;
		}
		
		public function saveToDatabaseSynchronous():CalibrationRequest {
			Database.insertCalibrationRequestSychronous(this);
			return this;
		}
		
		public function updateInDatabaseSynchronous():CalibrationRequest {
			Database.updateCalibrationRequestSynchronous(this);
			return this;
		}
		
		public function deleteInDatabaseSynchronous():CalibrationRequest {
			Database.deleteCalibrationRequestSynchronous(this);
			return this;
		}
		
		/**
		 * with database insert 
		 */
		public static function createRange(low:Number, high:Number):void {
			Database.insertCalibrationRequestSychronous(new CalibrationRequest(low, high, null, Number.NaN));
		}
		
		/**
		 * with database insert 
		 */
		public static function createOffset(center:Number, distance:Number):void {
			Database.insertCalibrationRequestSychronous(new CalibrationRequest(center + distance, MAX, null, Number.NaN));
			Database.insertCalibrationRequestSychronous(new CalibrationRequest(MIN, center + distance, null, Number.NaN));
		}
		
		/**
		 * with database update 
		 */
		public static function clearAllSynchronous():void {
			Database.deleteAllCalibrationRequestsSynchronous();
		}
		
		public static function shouldRequestCalibration(bgReading:BgReading):Boolean {
			return (Database.getCalibrationRequestsForValue(bgReading.calculatedValue).length > 0 
				&&
				Math.abs(bgReading.calculatedValueSlope * 60000) < 1);
		}
	}
}