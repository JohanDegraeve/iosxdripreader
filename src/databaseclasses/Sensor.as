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
	public class Sensor extends SuperDatabaseClass
	{
		private var _startedAt:Number;
		public function get startedAt():Number
		{
			return _startedAt;
		}
		
		private var _stoppedAt:Number;
		public function get stoppedAt():Number
		{
			return _stoppedAt;
		}
		
		private var _latestBatteryLevel:int;
		public function get latestBatteryLevel():int
		{
			return _latestBatteryLevel;
		}
		
		public function Sensor(startedAt:Number, stoppedAt:Number, latestBatteryLevel:int, sensorId:String, lastmodifiedtimestamp:Number)
		{
			super(sensorId, lastmodifiedtimestamp);
			_startedAt = startedAt;
			_stoppedAt = stoppedAt;
			_latestBatteryLevel = latestBatteryLevel;
		}
		
		/**
		 * if sensor is active, then returns the active sensor<br>
		 * if sensor not active, then returns null<br>
		 * to be used in stead of isActive (used in the android project) 
		 */
		public static function getActiveSensor():Sensor {
			var sensorId:String = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_ID_CURRENT_SENSOR_ID);
			if (sensorId == "0")
				return null;
			return Database.getSensor(sensorId);
		}
		
		/**
		 * starts a new sensor and inserts it in the database<br>
		 * if a sensor is currently active then it will be stopped<br> 
		 * CommonSettings.COMMON_SETTING_INITIAL_CALIBRATION_DONE_ID is not adapted !!!! 
		 */
		public static function startSensor():void {
			var currentSensor:Sensor = getActiveSensor();
			if (currentSensor != null) {
				currentSensor._stoppedAt = (new Date()).valueOf();
				currentSensor.resetLastModifiedTimeStamp();
				Database.updateSensor(currentSensor);
			}
			currentSensor = new Sensor((new Date()).valueOf(), 0, 0, null, Number.NaN);
			Database.insertSensor(currentSensor);
			CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_ID_CURRENT_SENSOR_ID, currentSensor.uniqueId);
		}
		
		/**
		 * stops the sensor and updates the database<br>
		 * CommonSettings.COMMON_SETTING_INITIAL_CALIBRATION_DONE_ID is not adapted !!!! TODO check why this is marked, compare with android version
		 */
		public static function stopSensor():void {
			var currentSensor:Sensor = getActiveSensor();
			if (currentSensor != null) {
				currentSensor._stoppedAt = (new Date()).valueOf();
				currentSensor.resetLastModifiedTimeStamp();
				Database.updateSensor(currentSensor);
			}
			CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_ID_CURRENT_SENSOR_ID, "0");
		}
	}
}