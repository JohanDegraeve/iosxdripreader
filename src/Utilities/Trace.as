package Utilities
{
	import com.distriqt.extension.message.Message;
	import com.distriqt.extension.message.MessageAttachment;
	import com.distriqt.extension.notifications.NotificationRepeatInterval;
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import mx.collections.ArrayCollection;
	
	import spark.formatters.DateTimeFormatter;
	
	import databaseclasses.AlertType;
	import databaseclasses.BlueToothDevice;
	import databaseclasses.Calibration;
	import databaseclasses.CommonSettings;
	import databaseclasses.Database;
	import databaseclasses.LocalSettings;
	import databaseclasses.Sensor;
	
	import events.SettingsServiceEvent;
	
	import model.ModelLocator;
	
	import services.DialogService;
	
	
	public class Trace
	{
		private static var dateFormatter:DateTimeFormatter;
		//private static var writeFileStream:FileStream;
		private static const debugMode:Boolean = true;
		private static var initialStart:Boolean = true;
		private static var filePath:String = "";
		
		public function Trace()
		{
		}
		
		public static function init():void {
			if (initialStart) {
				initialStart = false;
				LocalSettings.instance.addEventListener(SettingsServiceEvent.SETTING_CHANGED, localSettingChanged);
				filePath = "";
			}
		}
		
		private static function localSettingChanged(event:SettingsServiceEvent):void {
			if (event.data == LocalSettings.LOCAL_SETTING_DETAILED_TRACING_ENABLED) {
				if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_DETAILED_TRACING_ENABLED) == "true") {
					getSaveStream(); 
				}
			}
		}
		
		/**
		 * tag usually the name of the class that generates the log<br>
		 * log is the actually log<br>
		 * <br>
		 * dontWriteToFile : if true, then even if  LOCAL_SETTING_DETAILED_TRACING_ENABLED = true, the log will not be written to file<br>
		 * Useful for instance to avoid that personal data is written to the file (and afterwards send via e-mail).
		 * It will however still be logged with NSLog, which means to view such logs, the only way is with phone connected to Mac and cfgutil
		 */
		public static function myTrace(tag:String, log:String, dontWriteToFile:Boolean = false):void {
			if (dateFormatter == null) {
				dateFormatter = new DateTimeFormatter();
				dateFormatter.dateTimePattern = "yyyy-MM-dd HH:mm:ss";
				dateFormatter.useUTC = false;
				//dateFormatter.setStyle("locale",Capabilities.language.substr(0,2));
			}
			var nowMilliSecondsAsString:String = (new Date()).milliseconds.toString();
			while (nowMilliSecondsAsString.length < 3)
				nowMilliSecondsAsString = "0" + nowMilliSecondsAsString
			var traceText:String = dateFormatter.format(new Date()) + "." + nowMilliSecondsAsString + " xdripreadertrace " + tag + " : " + log;
			if (debugMode)
				trace(traceText);
			
			if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_NSLOG) == "true") {
				BackgroundFetch.traceNSLog(traceText);
			}
			
			if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_DETAILED_TRACING_ENABLED) == "false" || dontWriteToFile) {
				
			} else {
				if (filePath == "")
					getSaveStream();
				BackgroundFetch.writeTraceToFile(filePath, traceText.replace(" xdripreadertrace ", " "));			
			}
		}
		
		public static function sendTraceFile():void {
			///will send the current file via e-mail
			///after sending deletes the current file,removes the current name
			var fileName:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_TRACE_FILE_NAME);
			if (fileName != "") {
				var f:File = File.applicationStorageDirectory.resolvePath(fileName);
				var attachment:MessageAttachment = new MessageAttachment(f.nativePath, "", "", "");
				var body:String = "Hi,\n\nFind attached trace file " + fileName + "\n\nregards.";
				Message.service.sendMailWithOptions("Trace file", body, "johan.degraeve@gmail.com","","",[attachment],false);
				f.deleteFileAsync();
				BackgroundFetch.resetTraceFilePath();
				LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_TRACE_FILE_NAME, "");
				fileName = "";
				LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_TRACE_FILE_PATH_NAME, "");
				filePath = "";
			} else {
				
			}
		}
		
		/**
		 * Get a FileStream for writing the the log. 
		 * @return A FileStream instance we can read or write with. Don't forget to close it!
		 * also stores the new filename in the settings
		 */
		private static function getSaveStream():void {
			var fileName:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_TRACE_FILE_NAME);
			if (fileName == "") {
				var dateFormatter:DateTimeFormatter = new DateTimeFormatter();
				dateFormatter.dateTimePattern = "yyyy-MM-dd-HH-mm-ss";
				dateFormatter.useUTC = false;
				dateFormatter.setStyle("locale",Capabilities.language.substr(0,2));
				fileName = "xdrip-" + dateFormatter.format(new Date()) + ".log";
				LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_TRACE_FILE_NAME, fileName);
				filePath = File.applicationStorageDirectory.resolvePath(fileName).nativePath;
				LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_TRACE_FILE_PATH_NAME, filePath);
				BackgroundFetch.writeTraceToFile(filePath, "New file created with name " + fileName);
				BackgroundFetch.writeTraceToFile(filePath, "Application version = " + LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_APPLICATION_VERSION));
				BackgroundFetch.writeTraceToFile(filePath, "BackgroundFetch ANE version = " + BackgroundFetch.getANEVersion());
				var additionalInfoToWrite:String = "";
				additionalInfoToWrite += "Device type = " + BlueToothDevice.deviceType() + ".\n";
				additionalInfoToWrite += "Transmitterid = " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID) + ".\n";
				additionalInfoToWrite += "Sensor " + (Sensor.getActiveSensor() == null ? "not":"") + " started ";
				additionalInfoToWrite += (Sensor.getActiveSensor() == null ? ".\n": dateFormatter.format(new Date(Sensor.getActiveSensor().startedAt)) + ".\n" + "\n");
				if (Sensor.getActiveSensor() != null) {
					additionalInfoToWrite += "Numer of calibrations for this sensor = " + Calibration.allForSensor().length + ".\n";
					if (Calibration.allForSensor().length > 0) {
						additionalInfoToWrite += "Last calibration = " + dateFormatter.format(new Date(Calibration.last().timestamp))  + ".\n";
					}
				}
				additionalInfoToWrite += "\nReadings in notification = " + LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_ALWAYS_ON_NOTIFICATION) + "\n";
				additionalInfoToWrite += "\nHealthkit on  = " + LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_HEALTHKIT_STORE_ON) + "\n";
				additionalInfoToWrite += "Battery alert = " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_BATTERY_ALERT) + "\n";
				additionalInfoToWrite += "Low alert = " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_LOW_ALERT) + "\n";
				additionalInfoToWrite += "Very Low alert = " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_VERY_LOW_ALERT) + "\n";
				additionalInfoToWrite += "High alert = " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_HIGH_ALERT) + "\n";
				additionalInfoToWrite += "Very High alert = " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_VERY_HIGH_ALERT) + "\n";
				additionalInfoToWrite += "Phone Muted alert = " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_PHONE_MUTED_ALERT) + "\n";
				additionalInfoToWrite += "Missed Reading alert = " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_MISSED_READING_ALERT) + "\n";
				additionalInfoToWrite += "Calibration Request alert = " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_CALIBRATION_REQUEST_ALERT) + "\n";
				additionalInfoToWrite += "\nOverride Mute = " + LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_OVERRIDE_MUTE) + "\n\n";
				additionalInfoToWrite += "\nList of Alert Types : \n";
				var listOfAlarmname:ArrayCollection = Database.getAllAlertTypes();
				for (var i:int = 0;i < listOfAlarmname.length;i++) {
					var alertType:AlertType = listOfAlarmname.getItemAt(i) as AlertType;
					var texttoadd:String = "Alert type name = " + alertType.alarmName;
					texttoadd += ",\n   enabled = " + alertType.enabled;
					texttoadd += ",\n   default snooze = " + alertType.defaultSnoozePeriodInMinutes;
					texttoadd += ",\n   vibration = " + alertType.enableVibration;
					texttoadd += ",\n   override mute = " + alertType.overrideSilentMode;
					texttoadd += ",\n   repeat = " + (alertType.repeatInMinutes > 0 ? "true" : "false");
					texttoadd += ",\n   snooze from notification = " + alertType.snoozeFromNotification;
					texttoadd += ",\n   sound = " + alertType.sound;
					texttoadd += "\n";
					additionalInfoToWrite += texttoadd;
				}

				//zzz
				BackgroundFetch.writeTraceToFile(filePath, additionalInfoToWrite);
			} else {
				filePath = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_TRACE_FILE_PATH_NAME);
			}
		}
	}
}