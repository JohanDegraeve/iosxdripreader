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
	import com.fabricemontfort.air.ezSpeech;
	import com.fabricemontfort.air.ezspeech.languages;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import Utilities.BgGraphBuilder;
	import databaseclasses.BgReading;
	import databaseclasses.CommonSettings;
	import events.SettingsServiceEvent;
	import events.TransmitterServiceEvent;
	import model.ModelLocator;
	import services.TransmitterService;
	import Utilities.Trace;
	
	/**
	 * Class responsible for managing text to speak functionallity. 
	 */
	public class TextToSpeech
	{
		//Define objects
		private static var tts:ezSpeech;
		
		//Define variables
		private static var initiated:Boolean = false;
		private static var appInBackground:Boolean = false;
		private static var lockEnabled:Boolean = false;
		private static var speakInterval:int = 1;
		private static var receivedReadings:int = 0;
		
		//Define constants
		private static const VOICE_PITCH:Number = 1;
		private static const VOICE_SPEED:Number = 0.51;
		
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
				tts = ezSpeech.instance;
				speakInterval = int(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_INTERVAL));
				
				//Register event listener for changed settings
				CommonSettings.instance.addEventListener(SettingsServiceEvent.SETTING_CHANGED, onSettingsChanged);
				
				//If speak glucose readings is enabled in the app...
				if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) == "true")
				{
					//Register event listener for new blood glucose readings
					TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, onBgReadingReceived);
				}
				
				//Tracing
				myTrace("TextToSpeech Initiated. BG readings enabled: " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) + " | BG readings interval: " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_INTERVAL));
			}
		}
		
		/*
		Feature functions
		*/
		
		public static function sayText(text:String):void 
		{
			//Tracing
			myTrace("Text to speak: " + text);
			
			//Check if text to speech is enabled and device is supported
			if (tts != null && tts.isSupported() && !ModelLocator.isInForeground)
			{
				//Define text to speech parameters
				//tts.debug = false;
				tts.setSpeed(VOICE_SPEED);
				tts.setPitch(VOICE_PITCH);
				tts.setLanguage(languages.US);
				//tts.forceLanguage("en_US");
				
				//Speak text
				tts.say(text);
				
				//Tracing
				myTrace("Text spoken!");
			}
			else
			{
				if (!tts.isSupported())
				{
					//Tracing
					myTrace("Can't speak. Device not supported");
				}
				else if (ModelLocator.isInForeground)
				{
					//Tracing
					myTrace("Can't speak. Device is in foreground");
				}
					
			}
				
		}
		
		public static function isSpeaking():Boolean 
		{
			return tts.isSpeaking() as Boolean;
		}
		
		public static function stopSpeaking():void
		{
			tts.stop();
		}
		
		/*
		Utility functions
		*/
		
		private static function myTrace(log:String):void 
		{
			Trace.myTrace("TextToSpeech.as", log);
		}
		
		/*
		Event Handlers
		*/
		
		//Event fired after new blood glucose value is sent by the transmitter
		private static function onBgReadingReceived(event:Event = null):void 
		{
			//Update received readings counter
			receivedReadings += 1
			
			//Only speak blood glucose reading if app is in the background or phone is locked
			//if ((appInBackground || lockEnabled) && ((receivedReadings - 1) % speakInterval == 0))
			if (!ModelLocator.isInForeground && ((receivedReadings - 1) % speakInterval == 0))
			{	
				//Get current bg reading and format it 
				var currentBgReading:BgReading = BgReading.lastNoSensor();
				var currentBgReadingFormatted:String = BgGraphBuilder.unitizedString(currentBgReading.calculatedValue, CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_DO_MGDL) == "true");
				
				//Get current delta
				var currentDelta:String = BgGraphBuilder.unitizedDeltaString(false, true);
				
				//format delta in case of anomalies
				if (currentDelta == "0.0")
					currentDelta = "0";
				
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
				
				//Format current delta in case of anomalies
				if (currentDelta == "ERR" || currentDelta == "???")
					currentDelta = "non computable";
				
				//Create output text
				var currentBgReadingOutput:String = "Current blood glucose is " + currentBgReadingFormatted + ". It's trending " + currentTrend + ". Difference from last reading is " + currentDelta + ".";
				
				//Send output to TTS
				sayText(currentBgReadingOutput);
			}
		}
		
		//Event fired when app settings are changed
		private static function onSettingsChanged(event:SettingsServiceEvent):void 
		{
			//Enable/Disable speaking glucose readings
			if (event.data == CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) 
			{
				//Tracing
				myTrace("Settings changed! Speak readings is now " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON));
				
				//bgReadingsEnabled = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) == "true";
				if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) == "true")
				{
					//First remove any previous glucose reading event listener
					TransmitterService.instance.removeEventListener(TransmitterServiceEvent.BGREADING_EVENT, onBgReadingReceived);
					
					//Reenable glucose reading event listener
					TransmitterService.instance.addEventListener(TransmitterServiceEvent.BGREADING_EVENT, onBgReadingReceived);
					
					//Reset glucose readings
					receivedReadings = 0;
				}
				else
				{
					//Remove any previous glucose reading event listener
					TransmitterService.instance.removeEventListener(TransmitterServiceEvent.BGREADING_EVENT, onBgReadingReceived);
					
					//Reset glucose readings
					receivedReadings = 0;
				}
			}
			//Update internal interval
			else if (event.data == CommonSettings.COMMON_SETTING_SPEAK_READINGS_INTERVAL) 
			{
				myTrace("Settings changed! Speak readings interval is now " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_INTERVAL));
				
				speakInterval = int(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_INTERVAL));
				
				//Reset glucose readings
				receivedReadings = 0;
			}
			
		}
	}
}