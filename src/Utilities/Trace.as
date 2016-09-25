package Utilities
{
	import com.distriqt.extension.message.Message;
	import com.distriqt.extension.message.MessageAttachment;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	
	import spark.formatters.DateTimeFormatter;
	
	import databaseclasses.Database;
	import databaseclasses.LocalSettings;
	
	import events.BlueToothServiceEvent;
	import events.DatabaseEvent;
	import events.SettingsServiceEvent;
	
	import services.BluetoothService;
	
	public class Trace
	{
		private static var dateFormatter:DateTimeFormatter;
		private static var writeFileStream:FileStream;
		private static const debugMode:Boolean = true;
		private static var initialStart:Boolean = true;
		
		public function Trace()
		{
		}
		
		public static function init():void {
			if (initialStart) {
				initialStart = false;
				Database.instance.addEventListener(DatabaseEvent.DATABASE_INFORMATION_EVENT, databaseInformationReceived);
				BluetoothService.instance.addEventListener(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT, bluetoothServiceInformationReceived);
				LocalSettings.instance.addEventListener(SettingsServiceEvent.SETTING_CHANGED, localSettingChanged);
			}
		}
		
		private static function localSettingChanged(event:SettingsServiceEvent):void {
			if (event.data == LocalSettings.LOCAL_SETTING_DETAILED_TRACING_ENABLED) {
				if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_DETAILED_TRACING_ENABLED) == "true") {
					writeFileStream = getSaveStream(); 
				}
			}
		}
		
		public static function myTrace(tag:String, log:String):void {
			if (dateFormatter == null) {
				dateFormatter = new DateTimeFormatter();
				dateFormatter.dateTimePattern = "HH-mm-ss-SSS";
				dateFormatter.useUTC = false;
				dateFormatter.setStyle("locale",Capabilities.language.substr(0,2));
			}
			var traceText:String = dateFormatter.format(new Date()) + " " + tag +  ": " + log;
			if (debugMode)
				trace(traceText);
			
			if (LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_DETAILED_TRACING_ENABLED) == "false") {
			} else {
				if (writeFileStream == null) {
					writeFileStream = getSaveStream();
				}
				if (writeFileStream != null) {
					traceText += "\n";
					writeFileStream.writeUTFBytes(traceText);
				} else {
					trace("Trace.as : file creation failed");
				}
			}
		}
		
		private static function bluetoothServiceInformationReceived(event:BlueToothServiceEvent):void {
			myTrace("BT-INFO", event.data.information);
		}
		
		private static function databaseInformationReceived(event:DatabaseEvent):void {
			myTrace("DB-INFO", event.data.information);
		}
		
		public static function sendTraceFile():void {
			///will send the current file via e-mail
			///after sending deletes the current file,removes the current name
			var fileName:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_TRACE_FILE_NAME);
			if (fileName != "") {
				if (writeFileStream != null) {
					writeFileStream.close();
				}
				var f:File = File.applicationStorageDirectory.resolvePath(fileName);
				var attachment:MessageAttachment = new MessageAttachment(f.nativePath, "", "", "");
				var body:String = "Hi,\n\nFind attached trace file " + fileName + "\n\nregards.";
				Message.service.sendMailWithOptions("Trace file", body, "johan.degraeve@gmail.com","","",[attachment],false);
				f.deleteFileAsync();
				LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_TRACE_FILE_NAME, "");
			}
		}
		
		/**
		 * Get a FileStream for writing the the log. 
		 * @return A FileStream instance we can read or write with. Don't forget to close it!
		 * also stores the new filename in the settings
		 */
		private static function getSaveStream():FileStream {
			var fileName:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_TRACE_FILE_NAME);
			var newFile:Boolean = false;
			if (fileName == "") {
				newFile = true;
				var dateFormatter:DateTimeFormatter = new DateTimeFormatter();
				dateFormatter.dateTimePattern = "yyyy-MM-dd-HH-mm-ss";
				dateFormatter.useUTC = false;
				dateFormatter.setStyle("locale",Capabilities.language.substr(0,2));
				fileName = "xdrip-" + dateFormatter.format(new Date()) + ".log";
			}
			
			var f:File = File.applicationStorageDirectory.resolvePath(fileName);
			var fs:FileStream = new FileStream();
			try
			{
				fs.open(f, FileMode.APPEND);
				if (newFile) {
					fs.writeUTFBytes(new String("New file created with name " + fileName + "\n"));
				}
				LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_TRACE_FILE_NAME, fileName);
			}
			catch(e:Error) {
				return null;
			}
			return fs;
		}
	}
}