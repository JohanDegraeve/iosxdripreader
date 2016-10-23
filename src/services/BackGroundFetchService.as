package services
{
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
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
			NightScoutService.instance.addEventListener(NightScoutServiceEvent.UPLOAD_SUCCEEDED, nightScoutServiceUploadSucceeded);
			BackgroundFetch.init();
			BackgroundFetch.instance.addEventListener(BackgroundFetch.PERFORM_FETCH, performFetch);
		}
		
		private static function performFetch(event:Event):void {
			trace("BackGroundFetchService.as performFetch");
			nightScoutUploadResultAwaiting = true;
			NightScoutService.sync();
		}
		
		private static function nightScoutServiceNoData(event:NightScoutServiceEvent):void {
			trace("BackGroundFetchService.as received nightScoutServiceNoData and nightScoutUploadResultAwaiting = " + nightScoutUploadResultAwaiting);
			if (nightScoutUploadResultAwaiting) {
				nightScoutUploadResultAwaiting = false;
				BackgroundFetch.callCompletionHandler(BackgroundFetch.NO_DATA);
			}
		}

		private static function nightScoutServiceUploadFailed(event:NightScoutServiceEvent):void {
			trace("BackGroundFetchService.as received nightScoutServiceUploadFailed and nightScoutUploadResultAwaiting = " + nightScoutUploadResultAwaiting);
			if (nightScoutUploadResultAwaiting) {
				nightScoutUploadResultAwaiting = false;
				BackgroundFetch.callCompletionHandler(BackgroundFetch.FETCH_FAILED);
			}
		}

		private static function nightScoutServiceUploadSucceeded(event:NightScoutServiceEvent):void {
			trace("BackGroundFetchService.as received nightScoutServiceUploadSucceded and nightScoutUploadResultAwaiting = " + nightScoutUploadResultAwaiting);
			if (nightScoutUploadResultAwaiting) {
				nightScoutUploadResultAwaiting = false;
				BackgroundFetch.callCompletionHandler(BackgroundFetch.NEW_DATA);
			}
		}
	}
}