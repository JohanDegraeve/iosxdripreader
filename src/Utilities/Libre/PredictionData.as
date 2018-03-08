/**
 code ported from xdripplus 
 */
package Utilities.Libre
{
	public class PredictionData extends GlucoseData
	{
		public static const OK:String = "OK";
		public static const ERROR_NO_NFC:String = "ERROR_NO_NFC";
		public static const ERROR_NERROR_NO_NFCO_NFC:String = "ERROR_NFC_READ";
		
		public var trend:Number = -1;
		public var confidence:Number = -1;
		/**
		 * one of value OK, ERROR_NO_NFC or  ERROR_NO_NFC
		 */
		public var errorCode:String;
		public var attempt:int;

		public function PredictionData()
		{
		}
	}
}