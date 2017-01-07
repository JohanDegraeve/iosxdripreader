package services
{
	import flash.events.Event;
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
		 * adding 10 seconds<br>
		 * This will only start once the first bgreading is received. So it can not be used as long as the xdrip is not scanned and a first reading is received<br>
		 *  
		 */
		public static const DELAY_FOR_CHECKING_BGREADING_IN_SECONDS:int = (5 + 1) * 60 + 10;
		
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
			
			//immediately after launch of application, start setting that timer
			bgReadingReceived(null);
		}
		
		private static function bgReadingReceived(be:TransmitterServiceEvent = null):void {
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
		private static function bgReadingNotReceivedOnTime(event:Event):void {
			trace("Timerservice.as bgReadingNotReceivedOnTime");
			if (bgReadingCheckTimer != null) {
				if (bgReadingCheckTimer.running) {
					bgReadingCheckTimer.stop();
				}
			}
			
			//this is a situation where it's been more than 6 minutes that a bgreading was received
			//now we wait only 5 minutes
			bgReadingCheckTimer = new Timer(5 * 60 * 1000, 1);
			bgReadingCheckTimer.addEventListener(TimerEvent.TIMER, bgReadingNotReceivedOnTime);
			bgReadingCheckTimer.start();
			_instance.dispatchEvent(new TimerServiceEvent(TimerServiceEvent.BG_READING_NOT_RECEIVED_ON_TIME));
		}
	}
}