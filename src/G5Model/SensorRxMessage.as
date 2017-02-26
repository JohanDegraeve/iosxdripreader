package G5Model
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import Utilities.Trace;
	import Utilities.UniqueId;
	
	public class SensorRxMessage extends TransmitterMessage
	{
		var opcode:int = 0x2f;
		public var timestamp:Number;
		public var unfiltered:Number;
		public var filtered:Number;
		
		public function SensorRxMessage(packet:ByteArray) {
			myTrace("SensorRX dbg: " + UniqueId.bytesToHex(packet));
			if (packet.length >= 14) {
				byteSequence = new ByteArray();
				byteSequence.endian = Endian.LITTLE_ENDIAN;
				byteSequence = packet.readBytes(packet);
				if (byteSequence.readByte() == opcode) {
					
					byteSequence.readByte();//status = TransmitterStatus.getBatteryLevel(data.get(1));
					timestamp = byteSequence.readInt();
					unfiltered = byteSequence.readInt();
					filtered = byteSequence.readInt();
					myTrace("SensorRX dbg: timestamp = " + timestamp + ", unfiltered = " + unfiltered + ", filtered = " + filtered);
				}
			}
		}
		
		private static function myTrace(log:String):void {
			Trace.myTrace("SensorRxMessage.as", log);
		}
	}
}