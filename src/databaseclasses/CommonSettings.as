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
		 * we'll remember the name of the bluetoothe peripheral, empty string means we haven't set yet any (or erase the value of) 
		  */
		 public const COMMON_SETTING_ID_BLUETOOTHNAME:String = 0; 

		 private var commonSettings:Array = [
			 ""//COMMON_SETTING_ID_BLUETOOTHNAME
		 ];
		 
		 public function CommonSettings()
		 {
			 if (instance != null) {
				 throw new Error("CommonSettings class can only be accessed through CommonSettings.getInstance()");	
			 }
		 }
		 
		 public static function getInstance():CommonSettings {
			 if (instance == null) instance = new CommonSettings();
			 return instance;
		 }

		 public function getCommonSetting(commonSettingId:int):String {
			 return commonSettings[commonSettingId];
		 }
		 
		 public function setCommonSetting(commonSettingId:int, newValue:String) {
			 commonSettings[commonSettingId] = newValue;
		 }
	 }
 }