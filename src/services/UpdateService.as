package services
{
	import com.distriqt.extension.application.Application;
	import com.distriqt.extension.application.events.ApplicationStateEvent;
	import com.distriqt.extension.dialog.Dialog;
	import com.distriqt.extension.dialog.DialogView;
	import com.distriqt.extension.dialog.builders.AlertBuilder;
	import com.distriqt.extension.dialog.events.DialogViewEvent;
	import com.distriqt.extension.dialog.objects.DialogAction;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	
	import databaseclasses.LocalSettings;
	
	import events.IosXdripReaderEvent;
	
	import model.ModelLocator;
	
	[ResourceBundle('updateservice')]
	
	public class UpdateService extends EventDispatcher
	{
		//Instance
		private static var _instance:UpdateService = new UpdateService();
		private static var latestAppVersion:String = "";
		
		//Variables 
		private static var updateURL:String = ""; 
		
		//Constants
		private static const GITHUB_REPO_API_URL:String = "https://api.github.com/repos/JohanDegraeve/iosxdripreader/releases/latest";
		private static const IGNORE_UPDATE:int = 0;
		private static const GO_TO_GITHUB:int = 1;
		private static const REMIND_LATER:int = 2;
		
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
			checkUpdate();
			createEventListeners();
		}
		
		private static function checkTimeBetweenLastUpdateCheck(previousUpdateStamp:Number, currentStamp:Number):Number
		{
			//var oneDay:Number = 1000 * 60 * 60 * 24;
			var oneDay:Number = 1000 * 60;
			var differenceMilliseconds:Number = Math.abs(previousUpdateStamp - currentStamp);
			var daysAgo:Number =  Math.round(differenceMilliseconds/oneDay);
			
			return daysAgo;
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
		
		private static function createEventListeners():void
		{
			iosxdripreader.instance.addEventListener(IosXdripReaderEvent.APP_IN_FOREGROUND, onApplicationActivated);
		}
		
		protected static function onLoadSuccess(event:Event):void
		{
			//Parse response
			var loader:URLLoader = URLLoader(event.target);
			var data:Object = JSON.parse(loader.data as String);
			
			//Handle App Version
			//var currentAppVersion:String = LocalSettings.getLocalSetting(LocalSettings.LOCAL_SETTING_APPLICATION_VERSION);
			latestAppVersion = data.tag_name;
			var currentAppVersion:String = "0.5";
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
									updateURL = data.html_url;
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
									updateURL = data.html_url;
									break;
								}
							}
						}
					}
					
					//If there's an update available to the user, display a notification
					if(userUpdateAvailable)
					{
						trace("App update is available for user's group. Sending notification at " + (new Date()).toLocaleTimeString());
						//Warn User
						var title:String = ModelLocator.resourceManagerInstance.getString('updateservice', "update_dialog_title");
						var message:String = ModelLocator.resourceManagerInstance.getString('updateservice', "update_dialog_preversion_message") + " " + latestAppVersion + " " + ModelLocator.resourceManagerInstance.getString('updateservice', "update_dialog_postversion_message") + "."; 
						var ignore:String = ModelLocator.resourceManagerInstance.getString('updateservice', "update_dialog_ignore_update");
						var goToGitHub:String = ModelLocator.resourceManagerInstance.getString('updateservice', "update_dialog_goto_github");
						var remind:String = ModelLocator.resourceManagerInstance.getString('updateservice', "update_dialog_remind_later");
						var alert:DialogView = Dialog.service.create(
							new AlertBuilder()
							.setTitle(title)
							.setMessage(message)
							.addOption(ignore, DialogAction.STYLE_POSITIVE, 0)
							.addOption(goToGitHub, DialogAction.STYLE_POSITIVE, 1)
							.addOption(remind, DialogAction.STYLE_POSITIVE, 2)
							.build()
						);
						alert.addEventListener(DialogViewEvent.CLOSED, onDialogClosed);
						DialogService.addDialog(alert);
					}
					else
					{
						trace("App update is available but no ipa for user's group is ready for download");
						updateURL = "";
					}
				}
			}
		}
		
		private static function onDialogClosed(event:DialogViewEvent):void 
		{
			var selectedOption:int = int(event.index);
			if (selectedOption == IGNORE_UPDATE)
			{
				trace("IGNORE UPDATE");
				var ignoredUpdate:String = latestAppVersion;
				
				//Add ignored version to database settings
				
			}
			else if (selectedOption == GO_TO_GITHUB)
			{
				trace("GO TO GITHUB");
				if (updateURL != "")
				{
					navigateToURL(new URLRequest(updateURL));
					updateURL = "";
					trace("user directed to update page");
				}
			}
			else if (selectedOption == REMIND_LATER)
			{
				trace("REMIND LATER");
				
				var currentDate:Date = new Date();
				var currentTimeStamp:Number = currentDate.valueOf();
				
				//Update last check time in database
				
			}
		}
		
		protected static function onApplicationActivated(event:Event = null):void
		{
			trace("Update service is in foreground");
			var lastUpdateCheckStamp:Number = 1511014007853;
			var currentDate:Date = new Date();
			var currentTime:String = (new Date()).toLocaleTimeString();
			var currentTimeStamp:Number = currentDate.valueOf();
			//var currentTimeStamp:Number = (new Date()).valueOf();
			var daysSinceLastUpdateCheck:Number = checkTimeBetweenLastUpdateCheck(lastUpdateCheckStamp, currentTimeStamp);
			
			trace("currentTime: " + currentTime);
			trace("currentTimeStamp: " + currentTimeStamp);
			trace("time between last update: " + daysSinceLastUpdateCheck);
			if(daysSinceLastUpdateCheck > 25)
			{
				trace("Checking for new app update");
				checkUpdate();
			}
		}
	}
}