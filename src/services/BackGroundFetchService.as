package services
{
	import flash.events.EventDispatcher;
	
	import events.BackGroundFetchIntervalEvent;
	import events.NightScoutServiceEvent;

	public class BackGroundFetchService extends EventDispatcher
	{
		private static var _instance:BackGroundFetchService = new BackGroundFetchService(); 
		private static var initialStart:Boolean = true;

		private static var nightScoutUploadResultAwaiting:Boolean = false;
		
		public static function get instance():BackGroundFetchService
		{
			return _instance;
		}
		
		public function BackGroundFetchService()
		{
			if (_instance != null) {
				throw new Error("BackGroundFetchService class constructor can not be used");	
			}
		}
		
		public static function init():void {
			if (!initialStart)
				return;
			else
				initialStart = false;
			
			NightScoutService.instance.addEventListener(NightScoutServiceEvent.UPLOAD_NO_DATA, nightScoutServiceNoData);
			NightScoutService.instance.addEventListener(NightScoutServiceEvent.UPLOAD_FAILED, nightScoutServiceUploadFailed);
			NightScoutService.instance.addEventListener(NightScoutServiceEvent.UPLOAD_SUCCEEDED, nightScoutServiceUploadSucceded);
			BackGroundFetchInterval.init();
			//BackGroundFetchInterval.setFetchInterval(2);, being set to minimum in ANE
			BackGroundFetchInterval.instance.addEventListener(BackGroundFetchIntervalEvent.PERFORM_FETCH, performFetch);

		}
		
		private static function performFetch(event:BackGroundFetchIntervalEvent):void {
			trace("BackGroundFetchService.as performfetch event received");
			nightScoutUploadResultAwaiting = true;
			NightScoutService.sync();
		}
		
		private static function nightScoutServiceNoData(event:NightScoutServiceEvent):void {
			trace("BackGroundFetchService.as received nightScoutServiceNoData and nightScoutUploadResultAwaiting = " + nightScoutUploadResultAwaiting);
			if (nightScoutUploadResultAwaiting) {
				nightScoutUploadResultAwaiting = false;
				BackGroundFetchInterval.sendFetchResultNoData();
			}
		}

		private static function nightScoutServiceUploadFailed(event:NightScoutServiceEvent):void {
			trace("BackGroundFetchService.as received nightScoutServiceUploadFailed and nightScoutUploadResultAwaiting = " + nightScoutUploadResultAwaiting);
			if (nightScoutUploadResultAwaiting) {
				nightScoutUploadResultAwaiting = false;
				BackGroundFetchInterval.sendFetchResultFailed();
			}
		}

		private static function nightScoutServiceUploadSucceded(event:NightScoutServiceEvent):void {
			trace("BackGroundFetchService.as received nightScoutServiceUploadSucceded and nightScoutUploadResultAwaiting = " + nightScoutUploadResultAwaiting);
			if (nightScoutUploadResultAwaiting) {
				nightScoutUploadResultAwaiting = false;
				BackGroundFetchInterval.sendFetchResultNewData();
			}
		}
	}
}