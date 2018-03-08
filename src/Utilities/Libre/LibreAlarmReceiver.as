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
		
		private static var _instance:LibreAlarmReceiver = new LibreAlarmReceiver();
		public static function get instance():LibreAlarmReceiver
		{
			return _instance;
		}
		
		public function LibreAlarmReceiver()
		{
		}
		
		public static function CalculateFromDataTransferObject(object:TransferObject, use_raw:Boolean):void {
			// insert any recent data we can
			//mTrend is list of glucosedata
			var mTrend:ArrayCollection = object.data.trend;
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
						//return; // do not try to insert again
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
							if (use_raw) {
								createBGfromGD(gd, false);
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
						var polyxList:ArrayCollection = new ArrayCollection();
						var polyyList:ArrayCollection = new ArrayCollection();
						for (var cntr2:int = 0; cntr2 < mHistory.length ;cntr2 ++) {
							var gd2:GlucoseData = mHistory.getItemAt(cntr2) as GlucoseData;
							myTrace("in CalculateFromDataTransferObject, history : " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(gd2.realDate)) + " " + gd2.glucose(0, false));
							polyxList.addItem(gd2.realDate);
							if (use_raw) {
								polyyList.addItem(gd2.glucoseLevelRaw);
								createBGfromGD(gd2, true);
							} else {
								//polyyList.add((double) gd.glucoseLevel);
								// add in the actual value
								//BgReading.bgReadingInsertFromInt(gd.glucoseLevel, gd.realDate, false);
								myTrace("in CalculateFromDataTransferObject, in CalculateFromDataTransferObject, use_raw = " + use_raw + ", VERIFY THE CODE");
							}
						}
						
						//NEEDED ?
						//ConstrainedSplineInterpolator splineInterp = new ConstrainedSplineInterpolator();
						/*final SplineInterpolator splineInterp = new SplineInterpolator();
						
						try {
						PolynomialSplineFunction polySplineF = splineInterp.interpolate(
						Forecast.PolyTrendLine.toPrimitiveFromList(polyxList),
						Forecast.PolyTrendLine.toPrimitiveFromList(polyyList));
						
						final long startTime = mHistory.get(0).realDate;
						final long endTime = mHistory.get(mHistory.size() - 1).realDate;
						
						for (long ptime = startTime; ptime <= endTime; ptime += 300000) {
						if (d)
						myTrace("in CalculateFromDataTransferObject, Spline: " + JoH.dateTimeText((long) ptime) + " value: " + (int) polySplineF.value(ptime));
						if (use_raw) {
						createBGfromGD(new GlucoseData((int) polySplineF.value(ptime), ptime), true);
						} else {
						BgReading.bgReadingInsertFromInt((int) polySplineF.value(ptime), ptime, false);
						}
						}
						} catch (org.apache.commons.math3.exception.NonMonotonicSequenceException e) {
						myTrace("in CalculateFromDataTransferObject, NonMonotonicSequenceException: " + e);
						}*/
						
					} else {
						myTrace("in CalculateFromDataTransferObject, no librealarm history data");
					}
				} else {
					myTrace("in CalculateFromDataTransferObject, Trend data has no elements")
				}
			} else {
				myTrace("in CalculateFromDataTransferObject, Trend data is null!");
			}
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
		
		private static function createBGfromGD(gd:GlucoseData, quick:Boolean):void {
			var converted:Number;
			var bgReading:BgReading = null;
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
						myTrace("in createBGfromGD, in createBGfromGD, Creating bgreading at: " + DateTimeUtilities.createNSFormattedDateAndTime(new Date(gd.realDate)));
						bgReading = BgReading.create(converted, converted, gd.realDate, quick); // quick lite insert
						bgReading.saveToDatabaseSynchronous();
						_instance.dispatchEvent(new TransmitterServiceEvent(TransmitterServiceEvent.BGREADING_EVENT));
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
				if (i * 6 + 125 < data.length - 1 && i * 6 + 124 < data.length - 1) {
					byte.writeByte(getByteAt(data, (i * 6 + 125)));
					byte.writeByte(getByteAt(data, (i * 6 + 124)));
					glucoseData.glucoseLevelRaw = getGlucoseRaw(byte, thirteen_bit_mask);
					
					time = Math.max(0, Math.abs(Math.round((sensorTime - 3) / 15)) * 15 - index * 15);
					
					glucoseData.realDate = sensorStartTime + time * 60 * 1000;
					glucoseData.sensorId = tagId;
					glucoseData.sensorTime = time;
					historyList.addItem(glucoseData);
					//myTrace("in parseData history, glucoselevelraw = " + glucoseData.glucoseLevelRaw + ", realdata = " + glucoseData.realDate + ", glucoseData.sensorId = " + glucoseData.sensorId + ", sensorTime = " + glucoseData.sensorTime); 
				} else {
					//while testing and connected to Flash Builder I had one occurrence off end of file reached, that's why a check and a log is added
					myTrace("in parseData, i  " + i + ", i * 6 + 125 = " + (i * 6 + 125) + ". Max value is 343 ignoring a glucose Data");
				}
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
				if (i * 6 + 29 < data.length - 1 && i * 6 + 28 < data.length - 1) {
					byte.writeByte(getByteAt(data, (i * 6 + 29)));
					byte.writeByte(getByteAt(data, (i * 6 + 28)));
					glucoseData.glucoseLevelRaw = getGlucoseRaw(byte, thirteen_bit_mask);
					time = Math.max(0, sensorTime - index);
					
					glucoseData.realDate = sensorStartTime + time * 60 * 1000;
					glucoseData.sensorId = tagId;
					glucoseData.sensorTime = time;
					//myTrace("in parseData trendlist, glucoselevelraw = " + glucoseData.glucoseLevelRaw + ", realdata = " + glucoseData.realDate + ", glucoseData.sensorId = " + glucoseData.sensorId + ", sensorTime = " + glucoseData.sensorTime); 
					trendList.addItem(glucoseData);
				} else {
					//while testing and connected to Flash Builder I had one occurrence off end of file reached, that's why a check and a log is added
					myTrace("in parseData, i  " + i + "indexTrend = " + indexTrend + ", i * 6 + 29 = " + (i * 6 + 29) + ". Max value is 343 ignoring a glucose Data");
				}
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