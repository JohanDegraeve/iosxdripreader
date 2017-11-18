package services
{
	import com.distriqt.extension.notifications.Notifications;
	import com.distriqt.extension.notifications.builders.NotificationBuilder;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import databaseclasses.LocalSettings;
	
	import events.BackGroundFetchServiceEvent;
	
	import model.ModelLocator;
	
	public class UpdateService extends EventDispatcher
	{
		//Instance
		private static var _instance:UpdateService = new UpdateService();
		
		//Function events for load url requests
		private static var functionToCallAtUpOrDownloadSuccess:Function = null;
		private static var functionToCallAtUpOrDownloadFailure:Function = null;
		
		private static const GITHUB_REPO_API_URL:String = "https://api.github.com/repos/JohanDegraeve/iosxdripreader/releases/latest";
		
		public static function get instance():UpdateService {
			return _instance;
		}
		
		public function UpdateService(target:IEventDispatcher=null)
		{
			if (_instance != null) {
				throw new Error("UpdateService class constructor can not be used");	
			}
		}
		
		public static function init():void
		{
			/*BackGroundFetchService.instance.addEventListener(BackGroundFetchServiceEvent.LOAD_REQUEST_ERROR, defaultErrorFunction);
			BackGroundFetchService.instance.addEventListener(BackGroundFetchServiceEvent.LOAD_REQUEST_RESULT, defaultSuccessFunction);
			BackGroundFetchService.createAndLoadUrlRequest(GITHUB_REPO_API_URL, URLRequestMethod.GET, null, null, null); */
			
			checkUpdate();
		}
		
		private static function checkUpdate():void
		{
			//Create and configure loader and request
			var request:URLRequest = new URLRequest(GITHUB_REPO_API_URL);
			request.method = URLRequestMethod.GET;
			var loader:URLLoader = new URLLoader(); 
			loader.dataFormat = URLLoaderDataFormat.TEXT;
				
			//Make connection and define listener
			loader.addEventListener(Event.COMPLETE, onLoadSuccess);
			try 
			{
				loader.load(request);
			}
			catch (error:Error) 
			{
				trace("Unable to load GitHub repo API: " + error);
			}
		}
		
		protected static function onLoadSuccess(event:Event):void
		{
			//Parse response
			var loader:URLLoader = URLLoader(event.target);
			var data:Object = JSON.parse(loader.data as String);
			
			//Handle App Version
			//var currentAppVersion:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_APPLICATION_VERSION);
			var currentAppVersion:String = "0.5";
			var latestAppVersion:String = data.tag_name;
			var updateAvailable:Boolean = ModelLocator.versionAIsSmallerThanB(currentAppVersion, latestAppVersion);
			
			//Handle User Update
			if(updateAvailable)
			{
				//Check if assets are available for download
				var assets:Array = data.assets as Array;
				if(assets.length > 0)
				{
					//Assets are available
					//Define variables
					var userGroup:int = int("2");
					var userUpdateAvailable:Boolean = false;
					
					//Check if there is an update available for the current user's group
					for(var i:int = 0; i < (data.assets as Array).length; i++)
					{
						//Get asset name and type
						var fileName:String = (data.assets as Array)[i].name;
						var fileType:String = (data.assets as Array)[i].content_type;
						
						if (fileType == "application/x-itunes-ipa")
						{
							//Asset is an ipa, let's check what group it belongs
							if(fileName.indexOf("group") >= 0)
							{
								//Get group
								var firstIndex:int = fileName.indexOf("group") + 5;
								var lastIndex:int = fileName.indexOf(".ipa");
								var ipaGroup:int = int(fileName.slice(firstIndex, lastIndex));
								
								//Does the ipa group match the user group?
								if(userGroup == ipaGroup)
								{
									userUpdateAvailable = true;
									break;
								}
							}
							else
							{
								//No group associated. This is the main ipa
								if(userGroup == 0)
								{
									//The user has no group associated so and update is available
									userUpdateAvailable = true;
									break;
								}
							}
						}
					}
					
					//If there's an update available to the user, display a notification
					if(userUpdateAvailable)
					{
						trace("App update is available for user's group. Sending notification");
						
						//Send a notification to the user
						Notifications.service.cancel(NotificationService.ID_FOR_APP_UPDATE);
						Notifications.service.notify(
							new NotificationBuilder()
							.setId(NotificationService.ID_FOR_APP_UPDATE)
							.setAlert("Update Available")
							.setTitle("Update Available")
							.setBody("Version " + latestAppVersion + " is available for download. Please visit GitHub to install.")
							.enableLights(true)
							.enableVibration(true)
							.build());
					}
					else
						trace("App update is available but not ipa for user's group is ready for download");
				}
			}
		}	
		
		/*protected static function defaultSuccessFunction(event:BackGroundFetchServiceEvent):void
		{
			trace("------ LOAD SUCCESS ------");
			trace("------ DATA: " + event.data.information + " ------");
			
		}
		
		protected static function defaultErrorFunction(event:BackGroundFetchServiceEvent):void
		{
			trace("------ LOAD ERROR ------");
			
		}*/
	}
}