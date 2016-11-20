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
	
	import events.SettingsServiceEvent;

	/**
	 * local settings are settings specific to this device, ie settings that will not be synchronized among different devices.
	 */
	 public class LocalSettings extends EventDispatcher
	{
		private static var _instance:LocalSettings = new LocalSettings();

		public static function get instance():LocalSettings
		{
			return _instance;
		}

		/**
		 * detailed tracing enabled or not
		 */
		public static const LOCAL_SETTING_DETAILED_TRACING_ENABLED:int = 0; 
		/**
		 * filename for local tracing, empty string if currently no tracing 
		 */
		public static const LOCAL_SETTING_TRACE_FILE_NAME:int = 1;
		/**
		 * When user configures nightscout url and api secret, a test is done.<br>
		 * If that fails a dialog is shown<br>
		 * This indicates if that dialog has already been shown before or not, to avoid multiple pop ups.
		 */
		public static const LOCAL_SETTING_WARNING_THAT_NIGHTSCOUT_URL_AND_SECRET_IS_NOT_OK_ALREADY_GIVEN:int = 2;

		private static var localSettings:Array = [
			"false",//LOCAL_SETTING_DETAILED_TRACING_ENABLED
			"",//LOCAL_SETTING_TRACE_FILE_NAME
			"false"//LOCAL_SETTING_WARNING_THAT_NIGHTSCOUT_URL_AND_SECRET_IS_NOT_OK_ALREADY_GIVEN
		];
		
		public function LocalSettings() {
			if (_instance != null) {
				throw new Error("LocalSettings class constructor can not be used");	
			}
		}
		
		public static function getLocalSetting(localSettingId:int):String {
			return localSettings[localSettingId];
		}

		public static function setLocalSetting(localSettingId:int, newValue:String, updateDatabase:Boolean = true):void {
			if (localSettings[localSettingId] != newValue) {
				localSettings[localSettingId] = newValue;
				if (updateDatabase)
					Database.updateLocalSetting(localSettingId, newValue);
				var settingChangedEvent:SettingsServiceEvent = new SettingsServiceEvent(SettingsServiceEvent.SETTING_CHANGED);
				settingChangedEvent.data = localSettingId;
				_instance.dispatchEvent(settingChangedEvent);
			}
		}
		
		public static function getNumberOfSettings():int {
			return localSettings.length;
		}
	}
}