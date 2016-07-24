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
	  * common settings are settings that are shared with other devices, ie settings that will be synchronized
	  */
	 public class CommonSettings
	 {
		 private static var instance:CommonSettings = new CommonSettings();
		 
		 //LIST OF SETTINGID's
		 /**
		  * Unique Id of the currently active sensor<br>
		  * value "0" means there's no sensor active
		  *  
		  */
		 public static const COMMON_SETTING_ID_CURRENT_SENSOR_ID:int = 0; 
		 /**
		  * transmitter battery level (ie 215, 214,...)<br>
		  * 0 means level not known
		  */
		 public static const COMMON_SETTING_TRANSMITTER_BATTERY_VOLTAGE_ID:int = 1;
		 /**
		  * bridge battery level<br>
		  * 0 means level not known
		  */
		 public static const COMMON_SETTING_BRIDGE_BATTERY_PERCENTAGE_ID:int = 2;
		 
		 private static var commonSettings:Array = [
			 "0",//COMMON_SETTING_ID_CURRENT_SENSOR_ID
			 "0",//COMMON_SETTING_TRANSMITTER_BATTERY_VOLTAGE_ID
			 "0"//COMMON_SETTING_BRIDGE_BATTERY_PERCENTAGE_ID
		 ];
		 
		 public function CommonSettings()
		 {
			 if (instance != null) {
				 throw new Error("CommonSettings class  constructor can not be used");	
			 }
		 }
		 
		 public static function getCommonSetting(commonSettingId:int):String {
			 return commonSettings[commonSettingId];
		 }
		 
		 public static function setCommonSetting(commonSettingId:int, newValue:String, updateDatabase:Boolean = true):void {
			 commonSettings[commonSettingId] = newValue;
			 if (updateDatabase)
			 	Database.updateCommonSetting(commonSettingId, newValue);
		 }
		 
		 public static function getNumberOfSettings():int {
			 return commonSettings.length;
		 }
	 }
 }