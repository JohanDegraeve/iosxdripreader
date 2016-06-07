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
 
 */package databaseclasses
{
	/**
	 * local settings are settings specific to this device, ie settings that will not be synchronized among different devices.
	 */
	 public class LocalSettings
	{
		private static var instance:LocalSettings = new LocalSettings();
		private var localSettings:Array = [];

		
		public function LocalSettings()
		{
			if (instance != null) {
				throw new Error("LocalSettings class can only be accessed through LocalSettings.getInstance()");	
			}
		}
		
		public static function getInstance():LocalSettings {
			if (instance == null) instance = new LocalSettings();
			return instance;
		}
		
		public function getLocalSetting(localSettingId:int):String {
			return localSettings[localSettingId];
		}

		public function setLocalSetting(localSettingId:int, newValue:String) {
			localSettings[localSettingId] = newValue;
		}
	}
}