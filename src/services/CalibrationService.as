package services
{
	import com.distriqt.extension.dialog.Dialog;
	import com.distriqt.extension.dialog.DialogView;
	import com.distriqt.extension.dialog.builders.AlertBuilder;
	import com.distriqt.extension.dialog.events.DialogViewEvent;
	import com.distriqt.extension.dialog.objects.DialogAction;
	
	import databaseclasses.Calibration;
	
	import events.TransmitterServiceEvent;
	
	import model.ModelLocator;

	/**
	 * listens for bgreadings, at each bgreading user is asked to enter bg value<br>
	 * after two bgreadings, calibration.initialcalibration will be called and then this service will stop. 
	 */
	public class CalibrationService
	{
		[ResourceBundle("calibrationservice")]
		
		private static var _instance:CalibrationService = new CalibrationService();
		private static var bgLevel1:Number;
		private static var timeStampOfFirstBgLevel:Number;

		public static function get instance():CalibrationService {
			return _instance;
		}

		public function CalibrationService() {
			if (_instance != null) {
				throw new Error("CalibrationService class constructor can not be used");	
			}
		}
		
		public static function init():void {
			bgLevel1 = Number.NaN;
			timeStampOfFirstBgLevel = new Number(0);
			TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, transmitterServiceBGReadingEventReceived);
		}
		
		private static function transmitterServiceBGReadingEventReceived(be:TransmitterServiceEvent):void {
			//we don't need to do anything with the bgreading, but we need to ask the user for a new bg metering

			if (((new Date()).valueOf() - timeStampOfFirstBgLevel) > (7 * 60 * 1000 + 100)) { //previous measurement was more than 7 minutes ago , restart
				timeStampOfFirstBgLevel = 0;
				bgLevel1 = Number.NaN;
			}
			//create alert to get the user's input
			var alert:DialogView = Dialog.service.create(
				new AlertBuilder()
				.setTitle(isNaN(bgLevel1) ? ModelLocator.resourceManagerInstance.getString("calibrationservice","enter_first_calibration_title") : ModelLocator.resourceManagerInstance.getString("calibrationservice","enter_second_calibration_title"))
				.setMessage(ModelLocator.resourceManagerInstance.getString("calibrationservice","enter_calibration"))
				.addTextField("","Level")
				.addOption("Ok", DialogAction.STYLE_POSITIVE, 0)
				.addOption("Cancel", DialogAction.STYLE_CANCEL, 1)
				.build()
			);
			alert.addEventListener(DialogViewEvent.CLOSED, valueEntered);
			alert.addEventListener(DialogViewEvent.CANCELLED, cancellation);
			DialogService.addDialog(alert, 60);
		}
		
		private static function cancellation(event:DialogViewEvent):void {
		}
		
		private static function valueEntered(event:DialogViewEvent):void {
			var asNumber:Number = new Number(event.values[0] as String);
			if (isNaN(asNumber)) {
				//add the warning message
				var alert:DialogView = Dialog.service.create(
					new AlertBuilder()
					.setTitle(isNaN(bgLevel1) ? ModelLocator.resourceManagerInstance.getString("calibrationservice","enter_first_calibration_title") : ModelLocator.resourceManagerInstance.getString("calibrationservice","enter_second_calibration_title"))
					.setMessage(ModelLocator.resourceManagerInstance.getString("calibrationservice","value_should_be_numeric"))
					.addOption("Ok", DialogAction.STYLE_POSITIVE, 0)
					.build()
				);
				DialogService.addDialog(alert);
				//and ask again a value
				transmitterServiceBGReadingEventReceived(null);
			} else {
				if (isNaN(bgLevel1)) {
					bgLevel1 = asNumber;
					timeStampOfFirstBgLevel = (new Date()).valueOf();
				} else {
					TransmitterService.instance.removeEventListener(TransmitterServiceEvent.BGREADING_EVENT, transmitterServiceBGReadingEventReceived);
					Calibration.initialCalibration(bgLevel1, asNumber);
				}
			}
		}
	}
}