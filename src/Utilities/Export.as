package Utilities
{
	import com.distriqt.extension.message.Message;
	import com.distriqt.extension.message.MessageAttachment;
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import databaseclasses.BgReading;
	import databaseclasses.BlueToothDevice;
	import databaseclasses.Calibration;
	import databaseclasses.LocalSettings;
	
	import model.ModelLocator;
	
	import services.DialogService;

	public class Export
	{
		[ResourceBundle("export")]
		
		private static var filePath:String = "";
		private static var fileName:String = "";

		public function Export()
		{
		}
		
		public static function exportSiDiary():void {
				var lastExportTimeStamp:Number = new Number(LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_TIMESTAMP_SINCE_LAST_EXPORT_SIDIARY));
				
				//export bgreadings
				var cntr:int = ModelLocator.bgReadings.length - 1;
				while (cntr > -1) {
					var bgReading:BgReading = ModelLocator.bgReadings.getItemAt(cntr) as BgReading;
					if (bgReading.timestamp > lastExportTimeStamp) {
						if (bgReading.calculatedValue != 0) {
							BackgroundFetch.writeStringToFile(DateTimeUtilities.createSiDiaryEntryFormattedDateAndTime(new Date(bgReading.timestamp)) + ";" + Math.round(bgReading.calculatedValue) + ";;;;;;", getFilePath());
						}
					} else {
						break;
					}
					cntr--;
				}
				
				//export calibrations
				var calibrations:ArrayCollection = Calibration.allForSensor();
				cntr = calibrations.length - 1;
				while (cntr > -1) {
					var calibration:Calibration = calibrations.getItemAt(cntr) as Calibration;
					if (calibration.timestamp > lastExportTimeStamp) {
						BackgroundFetch.writeStringToFile(DateTimeUtilities.createSiDiaryEntryFormattedDateAndTime(new Date(calibration.timestamp)) + ";;" + Math.round(calibration.bg) + ";;;;;", getFilePath());
					}
					cntr--;
				}			
				
				if (filePath != "") {
					//there's readings written to the file, send it
					var f:File = File.applicationStorageDirectory.resolvePath(fileName);
					var attachment:MessageAttachment = new MessageAttachment(f.nativePath, "", "", "");
					var body:String = "Attached export in SiDiary format.";
					Message.service.sendMailWithOptions("SiDiary export", body, "","","",[attachment],false);
					f.deleteFileAsync();
					filePath = "";
					LocalSettings.setLocalSetting(LocalSettings.LOCAL_SETTING_TIMESTAMP_SINCE_LAST_EXPORT_SIDIARY, (new Date()).valueOf().toString());
				} else {
					DialogService.openSimpleDialog(ModelLocator.resourceManagerInstance.getString("export","info"),
						ModelLocator.resourceManagerInstance.getString("export","now_values_to_export_for_sidiary"));
				}
		}
		
		private static function getFilePath():String {
			if (filePath == "") {//file not yet created, create it now
				fileName ="export" + DateTimeUtilities.createSiDiaryFileNameFormattedDateAndTime(new Date()) + ".csv";//exportyyyyMMdd-kkmmsscsv
				filePath = File.applicationStorageDirectory.resolvePath(fileName).nativePath;
				BackgroundFetch.writeStringToFile("DAY;TIME;UDT_CGMS;BG_LEVEL;CH_GR;BOLUS;REMARK", filePath);
			}
			return filePath;
		}
	}
}