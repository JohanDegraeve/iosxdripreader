package model
{
	import com.freshplanet.ane.AirBackgroundFetch.BackgroundFetch;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	
	import Utilities.Crc;
	import Utilities.Trace;
	import Utilities.UniqueId;
	import Utilities.Libre.LibreAlarmReceiver;
	import Utilities.Libre.ReadingData;
	import Utilities.Libre.TransferObject;
	
	import databaseclasses.CommonSettings;
	
	import events.TransmitterServiceEvent;
	
	import services.TransmitterService;
	
	public class Tomato extends EventDispatcher
	{
		/**
		 * possible status miaomiao 
		 */
		private static const TOMATO_STATES_REQUEST_DATA_SENT:String = "REQUEST_DATA_SENT";
		/**
		 * possible status miaomiao 
		 */
		private static const TOMATO_STATES_RECIEVING_DATA:String = "RECIEVING_DATA";
		public static const MINIMUM_TIME_BETWEEN_TWO_MIAO_MIAO_READINGS_IN_SECONDS:int = 10;
		public static const MAXIMUM_AMOUNT_OF_PACKETS_NEEDED:int = 19;
		/**
		 * miaomiao status, one of  TOMATO_STATES_REQUEST_DATA_SENT or TOMATO_STATES_RECIEVING_DATA or empty string
		 */
		private static var s_state:String;
		private static var TOMATO_HEADER_LENGTH:int = 18;
		//other Tomato Variables
		private static var s_lastReceiveTimestamp:Number = 0;
		
		private static var resendPakcetTimer:Timer;
		
		private static var _instance:Tomato = new Tomato();
		public static function get instance():Tomato
		{
			return _instance;
		}

		public function Tomato()
		{
		}
		
		private static function sendStartReadingCommandToMiaoMiao():void {
			myTrace("in sendStartReadingCommandToMiaoMiao");
			BackgroundFetch.sendStartReadingCommmandToMiaoMia();
		}
		
		public static function decodeTomatoPacket(s_full_data:ByteArray):void {
			if (resendPakcetTimer != null) {
				if (resendPakcetTimer.running) {
					resendPakcetTimer.stop();
				}
				resendPakcetTimer = null;
			}
			
			s_full_data.position = 0;
			myTrace("in decodeTomatoPacket, received packet ");
			
			////
			var data:ByteArray = new ByteArray();
			data.endian = Endian.LITTLE_ENDIAN;
			s_full_data.position = TOMATO_HEADER_LENGTH;
			s_full_data.readBytes(data, 0, 344);
			var checksum_ok:Boolean = Crc.LibreCrc(data);
			myTrace("in decodeTomatoPacket,  checksum_ok = " + checksum_ok);
			
			if (!checksum_ok) {
				myTrace("in decodeTomatoPacket, checksum not ok. Start timer of 60 seconds to send start reading command");
				resendPakcetTimer = new Timer(60 * 1000, 1);
				resendPakcetTimer.addEventListener(TimerEvent.TIMER, sendStartReadingCommandToMiaoMiao);
				resendPakcetTimer.start();
				return;
			}
			
			CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_MIAOMIAO_BATTERY_LEVEL, (new Number(getByteAt(s_full_data,13))).toString());
			
			s_full_data.position = 14;
			var temp:ByteArray = new ByteArray();s_full_data.readBytes(temp, 0,2);
			CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_MIAOMIAO_HARDWARE, Utilities.UniqueId.bytesToHex(temp));
			
			s_full_data.position = 16;
			temp = new ByteArray();s_full_data.readBytes(temp, 0, 2);
			CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_MIAOMIAO_FW,Utilities.UniqueId.bytesToHex(temp));
			myTrace("in decodeTomatoPacket, COMMON_SETTING_MIAOMIAO_HARDWARE = " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_MIAOMIAO_HARDWARE) + ", COMMON_SETTING_MIAOMIAO_FW = " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_MIAOMIAO_FW) + ", battery level  " + CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_MIAOMIAO_BATTERY_LEVEL)); 
			
			var mResult:ReadingData = LibreAlarmReceiver.parseData(0, "tomato", data);
			if (LibreAlarmReceiver.CalculateFromDataTransferObject(new TransferObject(1, mResult), true)) {
				TransmitterService.dispatchBgReadingEvent();
			}
		}
		
		private static function InitBuffer():void {
		}
		
		private static function myTrace(log:String):void {
			Trace.myTrace("Tomato.as", log);
		}
		
		private static function getByteAt(buffer:ByteArray, position:int):int {
			buffer.position = position;
			return buffer.readByte();
		}
	}
}