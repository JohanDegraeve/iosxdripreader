package services
{
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetchEvent;
	
	import flash.events.EventDispatcher;
	import flash.net.URLVariables;
	
	import events.BackGroundFetchServiceEvent;
	
	import model.ModelLocator;
	
	/**
	 * controls all services that need up or download<br>
	 * 
	 * up- or downloads can not be done in parallel<br>
	 * 
	 * Services that need up or download, need to call createandloadurlrequest and listen for events BackgroundFetchServiceEvent.LOAD_REQUEST_RESULT
	 * and BackgroundFetchServiceEvent.LOAD_REQUEST_ERROR<br>
	 * Failing to do so will not give the chance to BackGroundFetchService to keep control, ie to launch other services that need up or download and to call callcompletionhandler resulting in 
	 * timeout in BackGroundFetch (which is 20 seconds)  
	 * 
	 */
	public class BackGroundFetchService extends EventDispatcher
	{
		private static var _instance:BackGroundFetchService = new BackGroundFetchService(); 
		private static var initialStart:Boolean = true;
		private static var parameters:Array 
		
		public static function get instance():BackGroundFetchService {
			return _instance;
		}
		
		public function BackGroundFetchService() {
			if (_instance != null) {
				throw new Error("BackGroundFetchService class constructor can not be used");	
			}
		}
		
		public static function init():void {
			if (!initialStart)
				return;
			else
				initialStart = false;
			
			BackgroundFetch.init();
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.LOG_INFO, logInfoReceived);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.LOAD_REQUEST_RESULT, loadRequestSuccess);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.LOAD_REQUEST_ERROR, loadRequestError);
			BackgroundFetch.instance.addEventListener(BackgroundFetchEvent.LOAD_REQUEST_PERFORMFETCH, performFetch);
		}
		
		private static function performFetch(event:BackgroundFetchEvent):void {
			trace("BackGroundFetchService.as performFetch");
			if (parameters != null) {
				BackgroundFetch.createAndLoadUrlRequest.apply(null, parameters);
			} else {
				BackgroundFetch.callCompletionHandler("NO_DATA");
			}
		}
		
		private static function loadRequestSuccess(event:BackgroundFetchEvent):void {
			trace("BackGroundFetchService.as loadRequestSuccess");
			trace("result = " + (event.data.result as String)); 
			parameters = null;
			
			var backgroundfetchserviceLogInfo:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceLogInfo.data = new Object();
			backgroundfetchserviceLogInfo.data.information = event.data.result as String;
			_instance.dispatchEvent(backgroundfetchserviceLogInfo);
			
			var backgroundFetchServiceResult:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOAD_REQUEST_RESULT);
			backgroundFetchServiceResult.data = new Object();
			backgroundFetchServiceResult.data.information = event.data.result as String;
			_instance.dispatchEvent(backgroundFetchServiceResult);
			
		}
		
		private static function loadRequestError(event:BackgroundFetchEvent):void {
			trace("BackGroundFetchService.as loadRequestError");
			trace("error = " + (event.data.error as String));
			parameters = null;
			
			var backgroundfetchserviceLogInfo:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceLogInfo.data = new Object();
			backgroundfetchserviceLogInfo.data.information = event.data.error as String;
			_instance.dispatchEvent(backgroundfetchserviceLogInfo);
			
			var backgroundFetchServiceResult:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOAD_REQUEST_ERROR);
			backgroundFetchServiceResult.data = new Object();
			backgroundFetchServiceResult.data.information = event.data.error as String;
			_instance.dispatchEvent(backgroundFetchServiceResult);
		}
		
		/**
		 * url is the url and should not be null<br>
		 * <br>
		 * if requestMethod is null then "GET" will be done<br>
		 * <br>
		 * urlVariables or data can be null, if urlVariables is not null, then urlVariables are added in the body, not the data<br>
		 * if urlVariables is null, then data is added in the body<br
		 * <br>
		 * urlvariables or data are url encoded within the ANE itself<br>
		 * <br>
		 * contentType can be null, if null it will get the value "application/x-www-form-urlencoded"
		 * <br>
		 * args parameter is to pass additional header name value pairs, must always be by two.<br>
		 */
		public static function createAndLoadUrlRequest(url: String, requestMethod:String, urlVariables:URLVariables, data:String, contentType:String, ... args): void {
			//return;
			parameters = new Array(6 + args.length);
			parameters[0] = url;
			parameters[1] = requestMethod;
			parameters[2] = urlVariables;
			parameters[3] = ModelLocator.isInForeground;
			parameters[4] = data;
			parameters[5] = contentType;
			for (var i:int = 0;i < args.length;i++) {
				parameters[6 + i] = args[i];
			}
			
			if (ModelLocator.isInForeground)
				BackgroundFetch.createAndLoadUrlRequest.apply(null, parameters);
		}
		
		private static function logInfoReceived(event:BackgroundFetchEvent):void {
			var backgroundfetchserviceEvent:BackGroundFetchServiceEvent = new BackGroundFetchServiceEvent(BackGroundFetchServiceEvent.LOG_INFO);
			backgroundfetchserviceEvent.data = new Object();
			backgroundfetchserviceEvent.data.information = event.data.information;
			backgroundfetchserviceEvent.timeStamp = event.timeStamp;
			_instance.dispatchEvent(backgroundfetchserviceEvent);
		}
	}
}