package model
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	public class TransmitterDataMiaoMiaoPacket extends TransmitterData
	{
		private var _packet:ByteArray;
		
		public function TransmitterDataMiaoMiaoPacket(packet:ByteArray)
		{
			_packet = packet;
			_packet.endian = Endian.LITTLE_ENDIAN;
			_packet.position = 0;
		}

		public function get packet():ByteArray
		{
			return _packet;
		}

	}
}