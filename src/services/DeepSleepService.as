package services
{
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import Utilities.Trace;
	
	import databaseclasses.CommonSettings;
	
	import events.IosXdripReaderEvent;

	/**
	 * deepsleep timer will start a timer that expires every 10 seconds, indefinitely<br>
	 * at expiry a short sound of 1ms without anything in it will be played.<br>
	 * to keep the app awake 
	 */
	public class DeepSleepService
	{
		private static var deepSleepTimer:Timer;

		public function DeepSleepService()
		{
			//Don't allow class to be instantiated
			throw new IllegalOperationError("DeepSleepService class is not meant to be instantiated!");
		}
		
		public static function init():void {
			startDeepSleepTimer();
			iosxdripreader.instance.addEventListener(IosXdripReaderEvent.APP_IN_FOREGROUND, checkDeepSleepTimer);
		}
		
		private static function startDeepSleepTimer():void {
			deepSleepTimer = new Timer(10000,0);
			deepSleepTimer.addEventListener(TimerEvent.TIMER, deepSleepTimerListener);
			deepSleepTimer.start();
		}
		
		private static function checkDeepSleepTimer(event:Event):void {
			if (deepSleepTimer != null) {
				if (deepSleepTimer.running) {
					return;
				} else {
					deepSleepTimer = null;										
				}
			}
			startDeepSleepTimer();
		}
		
		private static function deepSleepTimerListener(event:Event):void {
			BackgroundFetch.setAvAudioSessionCategory(true);
			BackgroundFetch.playSound("../assets/1-millisecond-of-silence.mp3");
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) == "false") {
				BackgroundFetch.setAvAudioSessionCategory(false);
			}
		}

		private static function myTrace(log:String):void 
		{
			Trace.myTrace("DeepSleepService.as", log);
		}
	}
}