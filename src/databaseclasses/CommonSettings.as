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
 	import flash.events.EventDispatcher;
 	
 	import events.SettingsServiceEvent;
 	
 	import services.BluetoothService;

	 /**
	  * common settings are settings that are shared with other devices, ie settings that will be synchronized
	  */
	 public class CommonSettings extends EventDispatcher
	 {
		 private static var _instance:CommonSettings = new CommonSettings();

		 public static function get instance():CommonSettings
		 {
			 return _instance;
		 }
		 
		 /**
		 * Witout https:// and without /api/v1/treatments<br>
		  */
		 public static const DEFAULT_SITE_NAME:String = "YOUR_SITE.azurewebsites.net";
		 public static const DEFAULT_API_SECRET:String = "API_SECRET";
		 
		 //LIST OF SETTINGID's
		 /**
		  * Unique Id of the currently active sensor<br>
		  * value "0" means there's no sensor active
		  *  
		  */
		 public static const COMMON_SETTING_CURRENT_SENSOR:int = 0; 
		 /**
		  * transmitter battery level (ie 215, 214,...)<br>
		  * 0 means level not known
		  */
		 public static const COMMON_SETTING_TRANSMITTER_BATTERY_VOLTAGE:int = 1;
		 /**
		  * bridge battery level<br>
		  * 0 means level not known
		  */
		 public static const COMMON_SETTING_BRIDGE_BATTERY_PERCENTAGE:int = 2;
		 public static const COMMON_SETTING_INITIAL_INFO_SCREEN_1_SHOWN:int = 3;
		 /**
		  * Witout https:// and without /api/v1/treatments<br>
		  */
		 public static const COMMON_SETTING_AZURE_WEBSITE_NAME:int = 4;
		 public static const COMMON_SETTING_API_SECRET:int = 5;
		 public static const COMMON_SETTING_URL_AND_API_SECRET_TESTED:int = 6; 
		 /**
		 * 0 = never synced 
		  */
		 public static const COMMON_SETTING_NIGHTSCOUT_SYNC_TIMESTAMP:int = 7;
		 /**
		 * value true or false, default true
		  */
		 public static const COMMON_SETTING_ADDITIONAL_CALIBRATION_REQUEST_ALERT:int = 8;
		 /**
		 * true or false, if true unit is mg/dl 
		  */
		 public static const COMMON_SETTING_DO_MGDL:int = 9;
		 /**
		 * low bg value, in mgdl, should be converted each time it is used or displayed
		  */
		 public static const COMMON_SETTING_LOW_MARK:int = 10;
		 /**
		 * high bg value, in mgdl, should be converted each time it is used or displayed
		  */
		 public static const COMMON_SETTING_HIGH_MARK:int = 11;
		 /**
		 * transmitter id, 00000 is not set 
		 */
		 public static const COMMON_SETTING_TRANSMITTER_ID:int = 12;
		 /**
		 * last update TRANSMITTER_BATTERY_VOLTAGE in ms since 1 1 1970<br>
		 * updated automatically when the setting COMMON_SETTING_TRANSMITTER_BATTERY_VOLTAGE
		  */
		 public static const COMMON_SETTING_UNUSED:int = 13;
		 public static const COMMON_SETTING_G5_BATTERY_MARKER:int = 14;
		 public static const COMMON_SETTING_G5_BATTERY_FROM_MARKER:int = 15;
			
		 private static var commonSettings:Array = [
			 "0",//COMMON_SETTING_CURRENT_SENSOR
			 "0",//COMMON_SETTING_TRANSMITTER_BATTERY_VOLTAGE
			 "0",//COMMON_SETTING_BRIDGE_BATTERY_PERCENTAGE
			 "false",//COMMON_SETTING_INITIAL_INFO_SCREEN_1_SHOWN
			 DEFAULT_SITE_NAME,//COMMON_SETTING_AZURE_WEBSITE_NAME
			 DEFAULT_API_SECRET,//COMMON_SETTING_API_SECRET
			 "false",//COMMON_SETTING_URL_AND_API_SECRET_TESTED
			 "0",//COMMON_SETTING_NIGHTSCOUT_SYNC_TIMESTAMP
			 "true",//COMMON_SETTING_ADDITIONAL_CALIBRATION_REQUEST_ALERT
			 "true",//COMMON_SETTING_DO_MGDL
			 "70",//COMMON_SETTING_LOW_MARK
			 "170",//COMMON_SETTING_HIGH_MARK
			 "00000",//COMMON_SETTING_TRANSMITTER_ID
			 "0",//COMMON_SETTING_UNUSED
			 "",//COMMON_SETTING_G5_BATTERY_MARKER
			 "0",//COMMON_SETTING_G5_BATTERY_FROM_MARKER
		 ];
		 
		 public function CommonSettings()
		 {
			 if (_instance != null) {
				 throw new Error("CommonSettings class  constructor can not be used");	
			 }
		 }
		 
		 public static function getCommonSetting(commonSettingId:int):String {
			 return commonSettings[commonSettingId];
		 }
		 
		 public static function setCommonSetting(commonSettingId:int, newValue:String, updateDatabase:Boolean = true):void {
			 if (commonSettings[commonSettingId] != newValue) {
				 if (commonSettingId == COMMON_SETTING_TRANSMITTER_ID) {
					 newValue = newValue.toUpperCase();
				 }
				 if (commonSettingId == COMMON_SETTING_G5_BATTERY_MARKER) {
					 commonSettings[COMMON_SETTING_G5_BATTERY_FROM_MARKER] = (new Date()).valueOf();
				 }
				 commonSettings[commonSettingId] = newValue;
				 if (updateDatabase)
					 Database.updateCommonSetting(commonSettingId, newValue);
				 var settingChangedEvent:SettingsServiceEvent = new SettingsServiceEvent(SettingsServiceEvent.SETTING_CHANGED);
				 settingChangedEvent.data = commonSettingId;
				 _instance.dispatchEvent(settingChangedEvent);
			 }
		 }
		 
		 public static function getNumberOfSettings():int {
			 return commonSettings.length;
		 }
	 }
 }