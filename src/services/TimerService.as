package services
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import events.TimerServiceEvent;
	import events.TransmitterServiceEvent;

	public class TimerService extends EventDispatcher
	{
		private static var _instance:TimerService = new TimerService();
		private static var bgReadingCheckTimer:Timer;
		/**
		 * Bg reading is expected every 5 minutes<br>
		 * xbridge holds data for 1 minute, so it could be that bgreading arrives 6 minutes before previous one<br>
		 * adding 10 seconds 
		 */
		private static const DELAY_FOR_CHECKING_BGREADING_IN_SECONDS:int = (5 + 1) * 60 + 10;
		
		public static function get instance():TimerService
		{
			return _instance;
		}

		public function TimerService()
		{
			if (_instance != null) {
				throw new Error("RestartNotificationService class constructor can not be used");	
			}
		}
		
		public static function init():void {
			TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, bgReadingReceived);
		}
		
		private static function bgReadingReceived(be:TransmitterServiceEvent):void {
			if (bgReadingCheckTimer != null) {
				if (bgReadingCheckTimer.running) {
					bgReadingCheckTimer.stop();
				}
			}
			bgReadingCheckTimer = new Timer(DELAY_FOR_CHECKING_BGREADING_IN_SECONDS * 1000, 1);
			bgReadingCheckTimer.addEventListener(TimerEvent.TIMER, bgReadingNotReceivedOnTime);
			bgReadingCheckTimer.start();
		}
		
		/**
		 * it's just dispatch an event that bgreading delivery is delayed. 
		 */
		private static function bgReadingNotReceivedOnTime(event:Timer):void {
			_instance.dispatchEvent(new TimerServiceEvent(TimerServiceEvent.BG_READING_NOT_RECEIVED_ON_TIME));
		}
	}
}