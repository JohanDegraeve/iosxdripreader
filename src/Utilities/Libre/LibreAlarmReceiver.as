/**
 code ported from xdripplus 
 */
package Utilities.Libre
{
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	
	import Utilities.DateTimeUtilities;
	import Utilities.Trace;
	
	import databaseclasses.BgReading;
	import databaseclasses.CommonSettings;
	
	import events.TransmitterServiceEvent;
	
	public class LibreAlarmReceiver extends EventDispatcher
	{
		private static var sensorAge:Number = 0;
		private static var timeShiftNearest:Number = -1;
		private static var oldest_cmp:Number = -1;
		private static var newest_cmp:Number = -1;
		private static var oldest:Number = -1;
		private static var newest:Number = -1;
		
		public function LibreAlarmReceiver()
		{
		}
		
		/**
		 * returns true if a new reading is created
		 */
		public static function CalculateFromDataTransferObject(object:TransferObject, use_raw:Boolean):Boolean {
			// insert any recent data we can
			//mTrend is list of glucosedata
			var mTrend:ArrayCollection = object.data.trend;
			var newReadingCreated:Boolean = false;
			if (mTrend != null) {
				if (mTrend.length > 0) {
					//looks like mTrend.size() - 1 needs to be the most recent reading
					mTrend.sort = GlucoseData.dataSort;
					myTrace("in CalculateFromDataTransferObject");
					mTrend.refresh();
					var thisSensorAge:Number = (mTrend.getItemAt(mTrend.length - 1) as GlucoseData).sensorTime;//mTrend.get(mTrend.size() - 1).sensorTime;
					sensorAge = new Number(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_FSL_SENSOR_AGE));
					if (thisSensorAge > sensorAge) {
						sensorAge = thisSensorAge;
						CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_FSL_SENSOR_AGE, thisSensorAge.toString());
						CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_NFC_AGE_PROBEM, "false");
						myTrace("in CalculateFromDataTransferObject, Sensor age advanced to: " + thisSensorAge);
					} else if (thisSensorAge == sensorAge) {
						myTrace("in CalculateFromDataTransferObject, Sensor age has not advanced: " + sensorAge);
						CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_NFC_AGE_PROBEM, "true");
					} else {
						myTrace("in CalculateFromDataTransferObject, Sensor age has gone backwards!!! " + sensorAge);
						CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_FSL_SENSOR_AGE, thisSensorAge.toString());
						CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_NFC_AGE_PROBEM, "true");
					}
					myTrace("in CalculateFromDataTransferObject, Oldest cmp: " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(oldest_cmp)) + " Newest cmp: " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(newest_cmp)));
					var shiftx:Number = 0;
					if (mTrend.length > 0) {
						
						shiftx = getTimeShift(mTrend);
						if (shiftx != 0) 
							myTrace("in CalculateFromDataTransferObject, Lag Timeshift: " + shiftx);
						//applyTimeShift(mTrend, shiftx);
						for (var cntr:int = 0; cntr < mTrend.length ;cntr ++) {
							var gd:GlucoseData = mTrend.getItemAt(cntr) as GlucoseData;
							myTrace("in CalculateFromDataTransferObject, DEBUG: sensor time: " + gd.sensorTime);
							if ((timeShiftNearest > 0) && ((timeShiftNearest - gd.realDate) < 4.5 * 60 * 1000) && (timeShiftNearest - gd.realDate != 0)) {
								myTrace("in CalculateFromDataTransferObject, Skipping record due to closeness: " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(gd.realDate)));
								continue;
							}
							myTrace("in CalculateFromDataTransferObject createbgd, trend : " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(gd.realDate)) + " " + gd.glucose(0, false));
							if (use_raw) {
								newReadingCreated = createBGfromGD(gd, false, "trend");
							} else {
								//assuming this will not happen as ios version uses only raw data
								myTrace("in CalculateFromDataTransferObject, in CalculateFromDataTransferObject, use_raw = " + use_raw + ", VERIFY THE CODE");
								//BgReading.bgReadingInsertFromInt(gd.glucoseLevel, gd.realDate, true);
							}
						}
					} else {
						myTrace("in CalculateFromDataTransferObject, Trend data was empty!");
					}
					
					// munge and insert the history data if any is missing
					var mHistory:ArrayCollection = object.data.history;
					if ((mHistory != null) && (mHistory.length > 1)) {
						mHistory.sort = GlucoseData.dataSort;
						mHistory.refresh();
						//applyTimeShift(mTrend, shiftx);
						//var polyxList:ArrayCollection = new ArrayCollection();
						//var polyyList:ArrayCollection = new ArrayCollection();
						for (var cntr2:int = 0; cntr2 < mHistory.length ;cntr2 ++) {
							var gd2:GlucoseData = mHistory.getItemAt(cntr2) as GlucoseData;
							myTrace("in CalculateFromDataTransferObject createbgd, history : " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(gd2.realDate)) + " " + gd2.glucose(0, false));
							//polyxList.addItem(gd2.realDate);
							if (use_raw) {
								//polyyList.addItem(gd2.glucoseLevelRaw);
								newReadingCreated = createBGfromGD(gd2, true, "history") || newReadingCreated;
							} else {
								//polyyList.add((double) gd.glucoseLevel);
								// add in the actual value
								//BgReading.bgReadingInsertFromInt(gd.glucoseLevel, gd.realDate, false);
								myTrace("in CalculateFromDataTransferObject, in CalculateFromDataTransferObject, use_raw = " + use_raw + ", VERIFY THE CODE");
							}
						}
					} else {
						myTrace("in CalculateFromDataTransferObject, no librealarm history data");
					}
				} else {
					myTrace("in CalculateFromDataTransferObject, Trend data has no elements")
				}
			} else {
				myTrace("in CalculateFromDataTransferObject, Trend data is null!");
			}
			return newReadingCreated;
		}
		
		private static function getTimeShift(gds:ArrayCollection):Number {
			var nearest:Number = -1;
			var cntr:int;
			for (cntr = 0; cntr < gds.length ;cntr ++) {
				if (((gds.getItemAt(cntr) as GlucoseData).realDate > nearest))
					nearest = (gds.getItemAt(cntr) as GlucoseData).realDate;
			}
			timeShiftNearest = nearest;
			if (nearest > 0) {
				var since:Number = (new Date()).valueOf() - nearest;
				if ((since > 0) && (since < 60 * 1000 * 5)) {
					return since;
				}
			}
			return 0;
		}
		
		private static function applyTimeShift(gds:ArrayCollection, timeshift:Number):void {
			if (timeshift == 0) return;
			for (var cntr:int = 0; cntr < gds.length ;cntr ++) {
				myTrace("in applyTimeShift, REMOVE THIS IF RESULT IS OK");
				myTrace("in applyTimeShift, (gds[cntr] as GlucoseData).realDate = " + (gds[cntr] as GlucoseData).realDate);
				myTrace("in applyTimeShift, timeshift = " + timeshift);
				myTrace("in applyTimeShift, value of (gds[cntr] as GlucoseData).realDate should change to " + new Number((gds[cntr] as GlucoseData).realDate  + timeshift));
				(gds[cntr] as GlucoseData).realDate += timeshift;		
				myTrace("in applyTimeShift, value = " + (gds[cntr] as GlucoseData).realDate);
			}
		}
		
		/**
		 * return true if a new reading is created 
		 */
		private static function createBGfromGD(gd:GlucoseData, quick:Boolean, type:String):Boolean {
			var converted:Number;
			var bgReading:BgReading = null;
			var newReadingCreated:Boolean = false;
			if (gd.glucoseLevelRaw > 0) {
				converted = getGlucose(gd.glucoseLevelRaw);
			} else {
				converted = 12; // RF error message - might be something else like unconstrained spline
			}
			if (gd.realDate > 0) {
				if ((newest_cmp == -1) || (oldest_cmp == -1) || (gd.realDate < oldest_cmp) || (gd.realDate > newest_cmp)) {
					// if (BgReading.readingNearTimeStamp(gd.realDate) == null) {
					if ((gd.realDate < oldest) || (oldest == -1)) oldest = gd.realDate;
					if ((gd.realDate > newest) || (newest == -1)) newest = gd.realDate;
					
					if (BgReading.getForPreciseTimestamp(gd.realDate, 4.5 * 60 * 1000) == null) {
						bgReading = BgReading.create(converted, converted, gd.realDate, quick); // quick lite insert
						myTrace("in createBGfromGD, Creating bgreading of type " + type + " at: " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(gd.realDate)) + ", with value " + bgReading.calculatedValue);
						bgReading.saveToDatabaseSynchronous();
						newReadingCreated = true;
					} else {
						myTrace("in createBGfromGD, Ignoring duplicate timestamp for: " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(gd.realDate)));
					}
				} else {
					myTrace("in createBGfromGD, Already processed from date range: " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(gd.realDate)));
				}
			} else {
				myTrace("in createBGfromGD, Fed a zero or negative date");
			}
			myTrace("in createBGfromGD, Oldest : " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(oldest_cmp)) + " Newest : " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(newest_cmp)));
			return newReadingCreated;
		}
		
		public static function getGlucose(rawGlucose:Number):Number {
			//LIBRE_MULTIPLIER
			return (rawGlucose * 117.64705);
		}
		
		/**
		 * comes from xdripplus NFCReaderX.java 
		 */
		public static function parseData(attempt:int, tagId:String, data:ByteArray):ReadingData {
			var index:int;
			var i:int;
			var glucoseData:GlucoseData;
			var byte:ByteArray;
			var time:Number;
			
			var ourTime:Number = (new Date()).valueOf();
			
			var indexTrend:int = getByteAt(data, 26) & 0xFF;
			
			var indexHistory:int = getByteAt(data, 27) & 0xFF; // double check this bitmask? should be lower?
			
			var sensorTime:int = 256 * (getByteAt(data, 317) & 0xFF) + (getByteAt(data, 316) & 0xFF);
			
			var sensorStartTime:Number = ourTime - sensorTime * 60 * 1000;
			
			// option to use 13 bit mask
			var thirteen_bit_mask:Boolean = true;//Pref.getBooleanDefaultFalse("testing_use_thirteen_bit_mask");
			
			var historyList:ArrayCollection = new ArrayCollection();//arraylist of glucosedata
			
			// loads history values (ring buffer, starting at index_trent. byte 124-315)
			for (index = 0; index < 32; index++) {
				i = indexHistory - index - 1;
				if (i < 0) i += 32;
				glucoseData = new GlucoseData();
				// glucoseData.glucoseLevel =
				//       getGlucose(new byte[]{data[(i * 6 + 125)], data[(i * 6 + 124)]});
				
				byte = new ByteArray();
				byte.writeByte(getByteAt(data, (i * 6 + 125)));
				byte.writeByte(getByteAt(data, (i * 6 + 124)));
				glucoseData.glucoseLevelRaw = getGlucoseRaw(byte, thirteen_bit_mask);
				
				time = Math.max(0,(int)(Math.abs(sensorTime - 3)/15)*15 - index*15);
				
				glucoseData.realDate = sensorStartTime + time * 60 * 1000;
				glucoseData.sensorId = tagId;
				glucoseData.sensorTime = time;
				//myTrace("add history with realDate = " + glucoseData.realDate + ", sensorTime = " + glucoseData.sensorTime + ", glucoselevelRaw = " + glucoseData.glucoseLevelRaw);
				historyList.addItem(glucoseData);
			}
			
			var trendList:ArrayCollection = new ArrayCollection();//arraylist of glucosedata
			
			// loads trend values (ring buffer, starting at index_trent. byte 28-123)
			for (index = 0; index < 16; index++) {
				i = indexTrend - index - 1;
				if (i < 0) i += 16;
				glucoseData = new GlucoseData();
				// glucoseData.glucoseLevel =
				//         getGlucose(new byte[]{data[(i * 6 + 29)], data[(i * 6 + 28)]});
				
				byte = new ByteArray();
				byte.writeByte(getByteAt(data, (i * 6 + 29)));
				byte.writeByte(getByteAt(data, (i * 6 + 28)));
				glucoseData.glucoseLevelRaw = getGlucoseRaw(byte, thirteen_bit_mask);
				time = Math.max(0, sensorTime - index);
				
				glucoseData.realDate = sensorStartTime + time * 60 * 1000;
				glucoseData.sensorId = tagId;
				glucoseData.sensorTime = time;
				//myTrace("in parseData trendlist, glucoselevelraw = " + glucoseData.glucoseLevelRaw + ", realdata = " + glucoseData.realDate + ", glucoseData.sensorId = " + glucoseData.sensorId + ", sensorTime = " + glucoseData.sensorTime);
				//myTrace("add trend with realDate = " + glucoseData.realDate + ", sensorTime = " + glucoseData.sensorTime + ", glucoselevelRaw = " + glucoseData.glucoseLevelRaw);
				trendList.addItem(glucoseData);
			}
			return ReadingData.createReadingData(null, trendList, historyList);
		}
		
		private static function getGlucoseRaw(bytes:ByteArray, thirteenBitMask:Boolean):int {
			if (thirteenBitMask) {
				return ((256 * (getByteAt(bytes, 0) & 0xFF) + (getByteAt(bytes, 1) & 0xFF)) & 0x1FFF);
			} else {
				return ((256 * (getByteAt(bytes, 0) & 0xFF) + (getByteAt(bytes, 1) & 0xFF)) & 0x0FFF);
			}
		}
		
		private static function getByteAt(buffer:ByteArray, position:int):int {
			buffer.position = position;
			return buffer.readByte();
		}
		
		/**
		 * gds : gluosedata
		 */
		private static function myTrace(log:String):void {
			Trace.myTrace("LibreAlarmReceiver.as", log);
		}
	}
}