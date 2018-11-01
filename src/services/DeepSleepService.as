package services
{
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import Utilities.Trace;
	
	import databaseclasses.BlueToothDevice;
	import databaseclasses.CommonSettings;
	import databaseclasses.LocalSettings;
	
	import events.DeepSleepServiceEvent;
	import events.NightScoutServiceEvent;
	import events.SettingsServiceEvent;
	import events.TransmitterServiceEvent;

	/**
	 * deepsleep timer will start a timer that expires every 10 seconds, indefinitely<br>
	 * at expiry a short sound of 1ms without anything in it will be played.<br>
	 * to keep the app awake<br>
	 * It also dispatches an event each time the timer expires, to notify other apps that need to do something at regular intervals
	 */
	public class DeepSleepService extends EventDispatcher
	{
		private static const deepSleepIntervalMinimumValue:int = 5000;

		private static var deepSleepTimer:Timer;

		private static var _instance:DeepSleepService = new DeepSleepService();
		
		/**
		 * how often to play the 1ms sound, in ms<br>
		 * default value 0 means not initialised
		 */
		private static var deepSleepIntervalUsed:int = 0;
		private static var lastLogPlaySoundTimeStamp:Number = 0;
		
		/**
		 * battery status (charging or not charging) used to set the deepsleep interval. If charging then value will be 5000 ms
		 */
		private static var previousBatteryStatus:int = 0;

		public static function get instance():DeepSleepService
		{
			return _instance;
		}

		public function DeepSleepService()
		{
			//Don't allow class to be instantiated
			if (_instance != null) {
				throw new IllegalOperationError("DeepSleepService class is not meant to be instantiated!");
			}
		}
		
		public static function init():void {
			CommonSettings.instance.addEventListener(SettingsServiceEvent.SETTING_CHANGED, onCommonSettingsChanged);
			LocalSettings.instance.addEventListener(SettingsServiceEvent.SETTING_CHANGED, onLocalSettingsChanged);
			
			TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, BGReadingReceived);
			NightScoutService.instance.addEventListener(NightScoutServiceEvent.NIGHTSCOUT_SERVICE_BG_READING_RECEIVED, BGReadingReceived);
			
			previousBatteryStatus = BackgroundFetch.getBatteryStatus();
			
			setDeepSleepIntervalAndRestartDeepSleepTimer();
		}
		
		private static function onCommonSettingsChanged(event:SettingsServiceEvent):void {
			if (event.data == CommonSettings.COMMON_SETTING_PERIPHERAL_TYPE) {
				setDeepSleepIntervalAndRestartDeepSleepTimer();
			}
		}
		
		private static function onLocalSettingsChanged(event:SettingsServiceEvent):void {
			if (event.data == LocalSettings.LOCAL_SETTING_DEEP_SLEEP_SERVICE_INTERVAL_UNPLUGGED_IN_SECONDS) {
				setDeepSleepIntervalAndRestartDeepSleepTimer();
			}
		}
		
		/**
		 * sets  deepSleepInterval, dependent on type of peripheral<br>
		 * will also restart the deepsleep timer
		 */
		private static function setDeepSleepIntervalAndRestartDeepSleepTimer():void {
			myTrace("in setDeepSleepIntervalAndRestartDeepSleepTimer");
			if (    !BlueToothDevice.isFollower()
				 && 
				 	!(previousBatteryStatus == 2)
			   ) {
				deepSleepIntervalUsed = new Number(LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_DEEP_SLEEP_SERVICE_INTERVAL_UNPLUGGED_IN_SECONDS)) * 1000;
			} else {
				deepSleepIntervalUsed = deepSleepIntervalMinimumValue;
			}
			myTrace("in setDeepSleepIntervalAndRestartDeepSleepTimer, deepSleepIntervalUsed = " + deepSleepIntervalUsed);
			stopDeepSleepTimer();
			startDeepSleepTimer();
		}
		
		private static function startDeepSleepTimer():void {
			deepSleepTimer = new Timer(deepSleepIntervalUsed,0);
			deepSleepTimer.addEventListener(TimerEvent.TIMER, deepSleepTimerListener);
			deepSleepTimer.start();
		}
		
		private static function deepSleepTimerListener(event:Event):void {
			if (BackgroundFetch.isPlayingSound()) {
			} else {	
				if ((new Date()).valueOf() - lastLogPlaySoundTimeStamp > 1 * 1 * 1000) {
					myTrace("in deepSleepTimerListener, call playSound");
					lastLogPlaySoundTimeStamp = (new Date()).valueOf();
				}
				BackgroundFetch.playSound("../assets/1-millisecond-of-silence.mp3", 0);
			}
			//for other services that need to do something at regular intervals
			_instance.dispatchEvent(new DeepSleepServiceEvent(DeepSleepServiceEvent.DEEP_SLEEP_SERVICE_TIMER_EVENT));
		}
		
		private static function stopDeepSleepTimer():void {
			if (deepSleepTimer != null) {
				if (deepSleepTimer.running) {
					deepSleepTimer.stop();
				}
			}
		}
		
		private static function BGReadingReceived(be:Event):void {
			myTrace("batterystatus = " + BackgroundFetch.getBatteryStatus());
			if (previousBatteryStatus != BackgroundFetch.getBatteryStatus()) {
				previousBatteryStatus = BackgroundFetch.getBatteryStatus();
				setDeepSleepIntervalAndRestartDeepSleepTimer();
			}
		}

		private static function myTrace(log:String):void 
		{
			Trace.myTrace("DeepSleepService.as", log);
		}
	}
}