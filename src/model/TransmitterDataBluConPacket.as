package model
{
	public class TransmitterDataBluConPacket extends TransmitterData
	{
		private var _rawData:Number;
		
		public function get rawData():Number
		{
			return _rawData;
		}
		
		private var _filteredData:Number;
		
		public function get filteredData():Number
		{
			return _filteredData;
		}
		
		private var _timeStamp:Number;
		
		public function get timeStamp():Number
		{
			return _timeStamp;
		}
		
		private var _sensorBatteryLevel:Number;
		
		public function get sensorBatteryLevel():Number
		{
			return _sensorBatteryLevel;
		}
		
		private var _bridgeBatteryLevel:Number;
		
		public function get bridgeBatteryLevel():Number
		{
			return _bridgeBatteryLevel;
		}
		
		private var _sensorAge:Number;
		
		public function get sensorAge():Number
		{
			return _sensorAge;
		}
		
		
		public function TransmitterDataBluConPacket(rawData:Number, filteredData:Number, sensorBatteryLevel:Number, bridgeBatteryLevel:Number, sensorAge:Number, timestamp:Number)
		{
			_rawData = rawData;
			_filteredData = filteredData;
			_sensorBatteryLevel = sensorBatteryLevel;
			_bridgeBatteryLevel = bridgeBatteryLevel;
			_timeStamp = timestamp;
			_sensorAge = sensorAge;
		}
	}
}