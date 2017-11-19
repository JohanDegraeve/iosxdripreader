/**
 Copyright (C) 2016  Johan Degraeve
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/gpl.txt>.
 
 Author: Miguel Kennedy
 
 */

package services
{
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	import Utilities.BgGraphBuilder;
	import Utilities.Trace;
	
	import databaseclasses.BgReading;
	import databaseclasses.CommonSettings;
	
	import events.SettingsServiceEvent;
	import events.TransmitterServiceEvent;
	
	import model.ModelLocator;
	
	import services.TransmitterService;
	
	/**
	 * Class responsible for managing text to speak functionallity. 
	 */
	public class TextToSpeech
	{
		//Define variables
		private static var initiated:Boolean = false;
		private static var lockEnabled:Boolean = false;
		private static var speakInterval:int = 1;
		private static var receivedReadings:int = 0;

		private static var deepSleepTimer:Timer;
		
		public function TextToSpeech()
		{
			//Don't allow class to be instantiated
			throw new IllegalOperationError("TextToSpeech class is not meant to be instantiated!");
		}
		
		public static function init():void
		{
			if (!initiated) 
			{
				//Instantiate objects and variables
				initiated = true;
				speakInterval = int(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_INTERVAL));
				
				
				//Register event listener for changed settings
				CommonSettings.instance.addEventListener(SettingsServiceEvent.SETTING_CHANGED, onSettingsChanged);
				
				//Register event listener for new blood glucose readings
				TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, onBgReadingReceived);
				
				//Enable/Disable Audio Session Category for BackgroundFetch
				if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) == "true") {
					BackgroundFetch.setAvAudioSessionCategory(true);
				} else {
					BackgroundFetch.setAvAudioSessionCategory(false);
				}
				
				//Tracing
				myTrace("TextToSpeech Initiated. BG readings enabled: " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) + " | BG readings interval: " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_INTERVAL));
			}
		}
		
		/**
		*Functionality functions
		*/
		
		public static function sayText(text:String, language:String = "en-US"):void 
		{
			//Tracing
			myTrace("Text to speak: " + text);
			
			//Start Text To Speech
			BackgroundFetch.say(text, language);		
		}
		
		private static function speakReading():void
		{
			//Update received readings counter
			receivedReadings += 1;
			
			//Only speak blood glucose reading if app is in the background or phone is locked
			if (/*!ModelLocator.isInForeground &&*/ ((receivedReadings - 1) % speakInterval == 0))
			{	
				//Get current bg reading and format it 
				var currentBgReadingList:ArrayCollection = BgReading.latestBySize(1);
				if (currentBgReadingList.length > 0) {
					var currentBgReading:BgReading = currentBgReadingList.getItemAt(0) as BgReading;
					var currentBgReadingFormatted:String = BgGraphBuilder.unitizedString(currentBgReading.calculatedValue, CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_DO_MGDL) == "true");
					
					//If user wants trend to be spoken...
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_TREND_ON) == "true")
					{
						//Get trend (slope)
						var currentTrend:String = currentBgReading.slopeName() as String;
						
						//Format trend (slope)
						if (currentTrend == "NONE" || currentTrend == "NON COMPUTABLE")
							currentTrend = "non computable";
						else if (currentTrend == "DoubleDown")
							currentTrend = "dramatically downward";
						else if (currentTrend == "SingleDown")
							currentTrend = "significantly downward";
						else if (currentTrend == "FortyFiveDown")
							currentTrend = "down";
						else if (currentTrend == "Flat")
							currentTrend = "flat";
						else if (currentTrend == "FortyFiveUp")
							currentTrend = "up";
						else if (currentTrend == "SingleUp")
							currentTrend = "significantly upward";
						else if (currentTrend == "DoubleUp")
							currentTrend = "dramatically upward";
					}
					
					//If user wants delta to be spoken...
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_DELTA_ON) == "true")
					{
						//Get current delta
						var currentDelta:String = BgGraphBuilder.unitizedDeltaString(false, true);
						
						//Format current delta in case of anomalies
						if (currentDelta == "ERR" || currentDelta == "???")
							currentDelta = "non computable";
						
						if (currentDelta == "0.0")
							currentDelta = "0";
					}
					
					//Create output text
					var currentBgReadingOutput:String = "Current blood glucose is " + currentBgReadingFormatted + ". ";
					
					//If user wants trend to be spoken...
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_TREND_ON) == "true")
						currentBgReadingOutput += "It's trending " + currentTrend + ". ";
					
					//If user wants delta to be spoken...
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_DELTA_ON) == "true")
						currentBgReadingOutput += "Difference from last reading is " + currentDelta + ".";
					
					//Send output to TTS
					sayText(currentBgReadingOutput);
				}
			}
		}
		
		/**
		*Utility functions
		*/
		
		private static function myTrace(log:String):void 
		{
			Trace.myTrace("TextToSpeech.as", log);
		}
		
		/**
		*Event Handlers
		*/
		
		private static function onBgReadingReceived(event:Event = null):void 
		{
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) == "true") 
			{
				//Manage Deep Sleep Timer
				if(deepSleepTimer == null)
				{					
					//Start and configure deep sleep timer
					deepSleepTimer = new Timer(10000, 0);
					deepSleepTimer.addEventListener(TimerEvent.TIMER, onDeepSleepTimer);
					deepSleepTimer.start();
				}
				
				//Speak BG Reading
				speakReading();
			} 
		}
		
		protected static function onDeepSleepTimer(event:TimerEvent):void
		{
			if(!ModelLocator.isInForeground)
			{
				trace("in TTS onDeepSleepTimer, playing 1ms of silence to avoid deep sleep");
				
				//Play a silence audio file of 1 millisecond to avoid deep sleep
				BackgroundFetch.playSound("../assets/1-millisecond-of-silence.mp3");
			}
		}
		
		//Event fired when app settings are changed
		private static function onSettingsChanged(event:SettingsServiceEvent):void 
		{
			//Update internal interval
			if (event.data == CommonSettings.COMMON_SETTING_SPEAK_READINGS_INTERVAL) 
			{
				myTrace("Settings changed! Speak readings interval is now " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_INTERVAL));
				
				speakInterval = int(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_INTERVAL));
				
				//Reset glucose readings
				receivedReadings = 0;
			}
			
			if (event.data == CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) 
			{
				myTrace("Settings changed! Speak readings interval is now " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON));
				
				if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) == "true") 
				{
					//Enable Audio Session Category for BackgroundFetch
					BackgroundFetch.setAvAudioSessionCategory(true);
					
					//Create, configure and start the deep sleep timer
					deepSleepTimer = new Timer(10000, 0); //10 seconds
					deepSleepTimer.addEventListener(TimerEvent.TIMER, onDeepSleepTimer);
					deepSleepTimer.start();
				} 
				else 
				{
					//Disable Audio Session Category for BackgroundFetch
					BackgroundFetch.setAvAudioSessionCategory(false);
					
					//Stop and Destroy the Deep Sleep timer
					if(deepSleepTimer != null)
					{
						deepSleepTimer.stop();
						deepSleepTimer = null;
					}
				}
			}
		}
	}
}