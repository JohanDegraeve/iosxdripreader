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
	
	import mx.collections.ArrayCollection;
	
	import Utilities.BgGraphBuilder;
	import Utilities.Trace;
	
	import databaseclasses.BgReading;
	import databaseclasses.CommonSettings;
	
	import events.SettingsServiceEvent;
	import events.TransmitterServiceEvent;
	
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
		private static var speechLanguageCode:String;

		//private static var deepSleepTimer:Timer;
		
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
				
				if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) == "true") 
				{
					//Enable Audio Session Category for BackgroundFetch
					BackgroundFetch.setAvAudioSessionCategory(true);
					
					//Manage and Start Deep Sleep Timer
					/*if(deepSleepTimer == null)
					{	
						//Start and configure deep sleep timer
						deepSleepTimer = new Timer(10000, 0);
						deepSleepTimer.addEventListener(TimerEvent.TIMER, onDeepSleepTimer);
						deepSleepTimer.start();
					}*/
				} 
				else 
				{
					//Disable Audio Session Category for BackgroundFetch
					BackgroundFetch.setAvAudioSessionCategory(false);
				}
				
				//Set speech language
				speechLanguageCode = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEECH_LANGUAGE);
				
				//Tracing
				myTrace("TextToSpeech started. Enabled: " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) + " | Interval: " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_INTERVAL) + " | Language: " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEECH_LANGUAGE));
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
			if (((receivedReadings - 1) % speakInterval == 0))
			{	
				//Get current bg reading and format it 
				var currentBgReadingList:ArrayCollection = BgReading.latestBySize(1);
				if (currentBgReadingList.length > 0) {
					var currentBgReading:BgReading = currentBgReadingList.getItemAt(0) as BgReading;
					var currentBgReadingFormatted:String = BgGraphBuilder.unitizedString(currentBgReading.calculatedValue, CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_DO_MGDL) == "true");
					
					//Speech Output
					var currentBgReadingOutput:String;
						
					//Get trend (slope)
					var currentTrend:String = currentBgReading.slopeName() as String;
						
					//Get current delta
					var currentDelta:String = BgGraphBuilder.unitizedDeltaString(false, true);
						
					if(speechLanguageCode == "en-GB" || 
						speechLanguageCode == "en-US" || 
						speechLanguageCode == "en-ZA" || 
						speechLanguageCode == "en-IE" || 
						speechLanguageCode == "en-AU")
					{
						//If user wants trend to be spoken...
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_TREND_ON) == "true")
						{
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
							//Format current delta in case of anomalies
							if (currentDelta == "ERR" || currentDelta == "???")
								currentDelta = "non computable";
								
							if (currentDelta == "0.0")
								currentDelta = "0";
						}
							
						//Create output text
						currentBgReadingOutput = "Current blood glucose is " + currentBgReadingFormatted + ". ";
						
						//If user wants trend to be spoken...
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_TREND_ON) == "true")
							currentBgReadingOutput += "It's trending " + currentTrend + ". ";
						
						//If user wants delta to be spoken...
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_DELTA_ON) == "true")
							currentBgReadingOutput += "Difference from last reading is " + currentDelta + ".";
					}
					else if(speechLanguageCode == "pt-PT" || 
							speechLanguageCode == "pt-BR")
					{
						
						//If user wants trend to be spoken...
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_TREND_ON) == "true")
							{
							//Format trend (slope)
							if (currentTrend == "NONE" || currentTrend == "NON COMPUTABLE")
								currentTrend = "de forma não computável";
							else if (currentTrend == "DoubleDown")
								currentTrend = "para baixo de forma acentuada";
							else if (currentTrend == "SingleDown")
								currentTrend = "para baixo de forma significativa";
							else if (currentTrend == "FortyFiveDown")
								currentTrend = "para baixo";
							else if (currentTrend == "Flat")
							{
								if(speechLanguageCode == "pt-PT")
									currentTrend = "a recto";
								else if(speechLanguageCode == "pt-BR")
									currentTrend = "a reto";
							}
							else if (currentTrend == "FortyFiveUp")
								currentTrend = "para cima";
							else if (currentTrend == "SingleUp")
								currentTrend = "para cima de forma significativa";
							else if (currentTrend == "DoubleUp")
								currentTrend = "para cirma de forma acentuada";
						}
							
						//If user wants delta to be spoken...
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_DELTA_ON) == "true")
						{
							//Format current delta in case of anomalies
							if (currentDelta == "ERR" || currentDelta == "???")
								currentDelta = "não cumputável";
							
							if (currentDelta == "0.0")
								currentDelta = "0";
						}
							
						//Create output text
						if(speechLanguageCode == "pt-PT")
							currentBgReadingOutput = "A tua glicose actual é " + currentBgReadingFormatted + ". ";
						else if(speechLanguageCode == "pt-BR")
							currentBgReadingOutput = "A sua glicose atual é " + currentBgReadingFormatted + ". ";
							
						//If user wants trend to be spoken...
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_TREND_ON) == "true")
						{
							if(speechLanguageCode == "pt-PT")
								currentBgReadingOutput += "Está a tender " + currentTrend + ". ";
							else if(speechLanguageCode == "pt-BR")
								currentBgReadingOutput += "Está tendendo " + currentTrend + ". ";
						}
							
						//If user wants delta to be spoken...
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_DELTA_ON) == "true")
							currentBgReadingOutput += "A diferença desde a última leitura é de " + currentDelta + ".";
					}
					else if(speechLanguageCode == "es-ES" || 
						speechLanguageCode == "es-MX")
					{
						//If user wants trend to be spoken...
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_TREND_ON) == "true")
						{
							//Format trend (slope)
							if (currentTrend == "NONE" || currentTrend == "NON COMPUTABLE")
								currentTrend = "de forma no calculable";
							else if (currentTrend == "DoubleDown")
								currentTrend = "hacia abajo de forma acentuada";
							else if (currentTrend == "SingleDown")
								currentTrend = "hacia abajo de forma significativa";
							else if (currentTrend == "FortyFiveDown")
								currentTrend = "hacia abajo";
							else if (currentTrend == "Flat")
								currentTrend = "a recto";
							else if (currentTrend == "FortyFiveUp")
								currentTrend = "hacia arriba";
							else if (currentTrend == "SingleUp")
								currentTrend = "hacia arriba de forma significativa";
							else if (currentTrend == "DoubleUp")
								currentTrend = "hacia arriba de forma acentuada";
						}
						
						//If user wants delta to be spoken...
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_DELTA_ON) == "true")
						{
							//Format current delta in case of anomalies
							if (currentDelta == "ERR" || currentDelta == "???")
								currentDelta = "no calculable";
							
							if (currentDelta == "0.0")
								currentDelta = "0";
						}
						
						//Create output text
						if(speechLanguageCode == "es-ES")
							currentBgReadingOutput = "Tu glucosa actual es " + currentBgReadingFormatted + ". ";
						else if(speechLanguageCode == "es-MX")
							currentBgReadingOutput = "Su glucose actual es " + currentBgReadingFormatted + ". ";
						
						//If user wants trend to be spoken...
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_TREND_ON) == "true")
						{
							currentBgReadingOutput += "Está tendiendo " + currentTrend + ". ";
						}
						
						//If user wants delta to be spoken...
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_DELTA_ON) == "true")
							currentBgReadingOutput += "La diferencia desde la última lectura es de " + currentDelta + ".";
					}
			
					//Send output to TTS
					sayText(currentBgReadingOutput, speechLanguageCode);
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
				//Speak BG Reading
				speakReading();
			} 
		}
		
		/*protected static function onDeepSleepTimer(event:TimerEvent):void
		{
			if(!ModelLocator.isInForeground)
			{
				trace("in TTS onDeepSleepTimer, playing 1ms of silence to avoid deep sleep");
				
				//Play a silence audio file of 1 millisecond to avoid deep sleep
				//BackgroundFetch.playSound("../assets/1-millisecond-of-silence.mp3");
			}
		}*/
		
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
			else if (event.data == CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) 
			{
				myTrace("Settings changed! Speak readings feature is now " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON));
				
				if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEAK_READINGS_ON) == "true") 
				{
					//Enable Audio Session Category for BackgroundFetch
					BackgroundFetch.setAvAudioSessionCategory(true);
					
					//Create, configure and start the deep sleep timer
					/*deepSleepTimer = new Timer(10000, 0); //10 seconds
					deepSleepTimer.addEventListener(TimerEvent.TIMER, onDeepSleepTimer);
					deepSleepTimer.start();*/
				} 
				else 
				{
					//Disable Audio Session Category for BackgroundFetch
					BackgroundFetch.setAvAudioSessionCategory(false);
					
					//Stop and Destroy the Deep Sleep timer
					/*if(deepSleepTimer != null)
					{
						deepSleepTimer.stop();
						deepSleepTimer = null;
					}*/
				}
			}
			else if (event.data == CommonSettings.COMMON_SETTING_SPEECH_LANGUAGE) 
			{
				myTrace("Settings changed! Speak readings language is now " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEECH_LANGUAGE));
				
				speechLanguageCode = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_SPEECH_LANGUAGE);
			}
		}
	}
}