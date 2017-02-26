package G5Model
{
	public class TransmitterStatus
	{
		public static const BRICKED:String = "BRICKED";
		public static const LOW:String = "LOW";
		public static const OK:String = "OK";
		public static const UNKNOWN:String = "UNKNOWN";
		
		private var _batteryLevel:String;

		public function get batteryLevel():String
		{
			return _batteryLevel;
		}
		
		public function toString() : String 
		{
			return _batteryLevel;
		}
		
		public function TransmitterStatus():void {
			_batteryLevel = UNKNOWN;
		}
		
		public static function getBatteryLevel(b:int):TransmitterStatus {
			var returnValue:TransmitterStatus = new TransmitterStatus();
			if (b > 0x81) {
				returnValue._batteryLevel = BRICKED;
			}
			else {
				if (b == 0x81) {
					returnValue._batteryLevel = LOW;
				}
				else if (b == 0x00) {
					returnValue._batteryLevel = OK;
				}
				else {
					returnValue._batteryLevel = UNKNOWN;
				}
			}
			return returnValue;
		}
	}
}