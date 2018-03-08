/**
 code ported from xdripplus 
 */
package Utilities.Libre
{
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;

	public class ReadingData
	{
		public var prediction:PredictionData;
		/**
		 * GlucoseData
		 */
		public var trend:ArrayCollection;
		/**
		 * GlucoseData
		 */
		public var history:ArrayCollection;
		
		public var raw_data:ByteArray;
		
		/**
		 * one of value PredictionData.OK, PredictionData.ERROR_NO_NFC or PredictionData.ERROR_NO_NFC
		 */
		public function ReadingData(result:String) {
			this.prediction = new PredictionData();
			this.prediction.realDate = (new Date()).valueOf();
			this.prediction.errorCode = result;
			this.trend = new ArrayCollection();
			this.history = new ArrayCollection();
			
			// The two bytes are needed here since some components don't like a null pointer.
			//this.raw_data = var value:ByteArray = new ByteArray();
		}
		
		public static function createReadingData(prediction:PredictionData, trend:ArrayCollection, history:ArrayCollection):ReadingData {
			var returnValue:ReadingData = new ReadingData("");//doesn't matter what value is used for result becaues prediction will be overwritten
			returnValue.prediction = prediction;
			returnValue.trend = trend;
			returnValue.history = history;
			return returnValue;
		}
	}
}