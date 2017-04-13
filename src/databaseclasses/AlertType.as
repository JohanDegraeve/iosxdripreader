/**
 Copyright (C) 2017  Johan Degraeve
 
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
	public class AlertType extends SuperDatabaseClass
	{
		private var _alarmName:String;

		public function get alarmName():String
		{
			return _alarmName;
		}
		
		private var _enableLights:Boolean;

		public function get enableLights():Boolean
		{
			return _enableLights;
		}

		private var _enabled:Boolean;
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		private var _enableVibration:Boolean;

		public function get enableVibration():Boolean
		{
			return _enableVibration;
		}

		private var _snoozeFromNotification:Boolean;

		public function get snoozeFromNotification():Boolean
		{
			return _snoozeFromNotification;
		}

		private var _overrideSilentMode:Boolean;

		public function get overrideSilentMode():Boolean
		{
			return _overrideSilentMode;
		}
	
		private var _sound:String;

		public function get sound():String
		{
			return _sound;
		}
		
		private var _defaultSnoozePeriod:int;

		public function get defaultSnoozePeriod():int
		{
			return _defaultSnoozePeriod;
		}


		/**
		 * uniqueId and lastmodifiedtimestamp can be null, value will be assigned 
		 */
		public function AlertType(uniqueId:String, lastmodifiedtimestamp:Number, alarmName:String, enableLights:Boolean, enableVibration:Boolean, snoozeFromNotification:Boolean, enabled:Boolean, overrideSilentMode:Boolean, sound:String, defaultSnoozePeriod:int)
		{
			super(uniqueId, lastmodifiedtimestamp);
			this._alarmName = alarmName;
			this._defaultSnoozePeriod = defaultSnoozePeriod;
			this._enableLights = enableLights;
			this._enableVibration = enableVibration;
			this._overrideSilentMode = overrideSilentMode;
			this._snoozeFromNotification = snoozeFromNotification;
			this._sound = sound;
			this._enabled = enabled;
		}
		
		public function storeInDatabase():void {
			Database.insertAlertTypeSychronous(this);
		}
		
		public function deleteFromDatabase():void {
			Database.deleteAlertTypeSynchronous(this);
		}
		
		public function updateInDatabase():void {
			Database.updateAlertTypeSynchronous(this);
		}
		
	}
}