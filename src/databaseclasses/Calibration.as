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
 
 * MOST OF THIS CODE HERE IS COPIED FROM THE xDRIP-EXPERIMENTAL PROJECT AND PORTED
 * see https://github.com/StephenBlackWasAlreadyTaken/xDrip-Experimental
 * 
 */
package databaseclasses
{
	import mx.collections.ArrayCollection;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	
	import Utilities.UniqueId;

	public class Calibration extends SuperDatabaseClass
	{
		private var _timestamp:Number;
		
		/**
		 * ms sinds 1 jan 1970 
		 */
		public function get timestamp():Number
		{
			return _timestamp;
		}
		
		private var _sensorAgeAtTimeOfEstimation:Number;

		/**
		 * in ms 
		 */
		public function get sensorAgeAtTimeOfEstimation():Number
		{
			return _sensorAgeAtTimeOfEstimation;
		}

		private var _sensor:Sensor;

		public function get sensor():Sensor
		{
			return _sensor;
		}

		private var _bg:Number;

		public function get bg():Number
		{
			return _bg;
		}

		private var _rawValue:Number;

		public function get rawValue():Number
		{
			return _rawValue;
		}

		private var _adjustedRawValue:Number;

		public function get adjustedRawValue():Number
		{
			return _adjustedRawValue;
		}

		private var _sensorConfidence:Number;

		public function set sensorConfidence(value:Number):void
		{
			_sensorConfidence = value;
			resetLastModifiedTimeStamp();
		}


		public function get sensorConfidence():Number
		{
			return _sensorConfidence;
		}

		private var _slopeConfidence:Number;

		public function set slopeConfidence(value:Number):void
		{
			_slopeConfidence = value;
			resetLastModifiedTimeStamp();
		}


		public function get slopeConfidence():Number
		{
			return _slopeConfidence;
		}

		private var _rawTimestamp:Number;

		public function get rawTimestamp():Number
		{
			return _rawTimestamp;
		}

		private var _slope:Number;

		public function set slope(value:Number):void
		{
			_slope = value;
			resetLastModifiedTimeStamp();
		}


		public function get slope():Number
		{
			return _slope;
		}

		private var _intercept:Number;

		public function set intercept(value:Number):void
		{
			_intercept = value;
			resetLastModifiedTimeStamp();
		}


		public function get intercept():Number
		{
			return _intercept;
		}

		private var _distanceFromEstimate:Number;

		public function get distanceFromEstimate():Number
		{
			return _distanceFromEstimate;
		}

		private var _estimateRawAtTimeOfCalibration:Number;

		public function get estimateRawAtTimeOfCalibration():Number
		{
			return _estimateRawAtTimeOfCalibration;
		}

		private var _estimateBgAtTimeOfCalibration:Number;

		public function get estimateBgAtTimeOfCalibration():Number
		{
			return _estimateBgAtTimeOfCalibration;
		}

		private var _possibleBad:Boolean;

		public function set possibleBad(value:Boolean):void
		{
			_possibleBad = value;
			resetLastModifiedTimeStamp();
		}


		public function get possibleBad():Boolean
		{
			return _possibleBad;
		}

		private var _checkIn:Boolean;

		public function get checkIn():Boolean
		{
			return _checkIn;
		}

		private var _firstDecay:Number;

		public function get firstDecay():Number
		{
			return _firstDecay;
		}

		private var _secondDecay:Number;

		public function get secondDecay():Number
		{
			return _secondDecay;
		}

		private var _firstSlope:Number;

		public function get firstSlope():Number
		{
			return _firstSlope;
		}

		private var _secondSlope:Number;

		public function get secondSlope():Number
		{
			return _secondSlope;
		}

		private var _firstIntercept:Number;

		public function get firstIntercept():Number
		{
			return _firstIntercept;
		}

		private var _secondIntercept:Number;

		public function get secondIntercept():Number
		{
			return _secondIntercept;
		}

		private var _firstScale:Number;

		public function get firstScale():Number
		{
			return _firstScale;
		}

		private var _secondScale:Number;

		public function get secondScale():Number
		{
			return _secondScale;
		}
		
		
	
		/**
		 * if calibrationid = null, then a new value will be assigned by the constructor<br>
		 * if lastmodifiedtimestamp = Number.NaN, then current time will be assigned by the constructor 
		 */
		public function Calibration(
			timestamp:Number,
			sensorAgeAtTimeOfEstimation:Number,
			sensor:Sensor,
			bg:Number,
			rawValue:Number,
			adjustedRawValue:Number,
			sensorConfidence:Number,
			slopeConfidence:Number,
			rawTimestamp:Number,
			slope:Number,
			intercept:Number,
			distanceFromEstimate:Number,
			estimateRawAtTimeOfCalibration:Number,
			estimateBgAtTimeOfCalibration:Number,
			possibleBad:Boolean,
			checkIn:Boolean,
			firstDecay:Number,
			secondDecay:Number,
			firstSlope:Number,
			secondSlope:Number,
			firstIntercept:Number,
			secondIntercept:Number,
			firstScale:Number,
			secondScale:Number,
			lastmodifiedtimestamp:Number,
			calibrationid:String
		)
		{
			super(calibrationid, lastmodifiedtimestamp);
			_timestamp = timestamp;
			_sensorAgeAtTimeOfEstimation = sensorAgeAtTimeOfEstimation;
			_sensor = sensor;
			_bg = bg;
			_rawValue = rawValue;
			_adjustedRawValue = adjustedRawValue;
			_sensorConfidence = sensorConfidence;
			_slopeConfidence = slopeConfidence;
			_rawTimestamp = rawTimestamp;
			_slope = slope,
			_intercept = intercept;
			_distanceFromEstimate = distanceFromEstimate;
			_estimateRawAtTimeOfCalibration = estimateRawAtTimeOfCalibration;
			_estimateBgAtTimeOfCalibration = estimateBgAtTimeOfCalibration;
			_possibleBad = possibleBad;
			_checkIn = checkIn;
			_firstDecay = firstDecay;
			_secondDecay = secondDecay;
			_firstSlope = firstSlope;
			_secondSlope = secondSlope;
			_firstIntercept = firstIntercept;
			_secondIntercept = secondIntercept;
			_firstScale = firstScale;
			_secondScale = secondScale;
		}
		
		/**
		 * with database update of the cleared calibrations
		 */
		public static function clearAllExistingCalibrations():void {
			Database.deleteAllCalibrationRequestsSynchronous();
			var pastCalibrations:ArrayCollection = allForSensor();
			for (var i:int = 0; i < pastCalibrations.length; i++) {
				var calibration:Calibration = pastCalibrations.getItemAt(i) as Calibration;
				calibration.slopeConfidence = 0;
				calibration.sensorConfidence = 0;
				calibration.updateInDatabaseSynchronous();
			}
		}
		
		/**
		 * returns all calibrations for the ative sensor<br>
		 * if no sensor active then the return value is an empty arraycollection (size = 0)<br> 
		 * the calibrations will be order in descending order by timestamp
		 */
		public static function allForSensor():ArrayCollection {
			if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_ID_CURRENT_SENSOR_ID) == "0")
				return new ArrayCollection();//an empty arraycollection
			
			var returnValue:ArrayCollection = Database.getCalibrationForSensorId(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_ID_CURRENT_SENSOR_ID));
			for (var i:int = 0; i < returnValue.length; i++) {
				var calibration:Calibration = returnValue.getItemAt(i) as Calibration;
				if (calibration.slopeConfidence == 0 || calibration.sensorConfidence == 0) {
					returnValue.removeItemAt(i);
					i--;
				}
				i++;
				if (i == returnValue.length)
					break;
			}
			var dataSortFieldForReturnValue:SortField = new SortField();
			dataSortFieldForReturnValue.name = "timestamp";
			dataSortFieldForReturnValue.numeric = true;
			dataSortFieldForReturnValue.descending = true;//ie from large to small
			var dataSortForBGReadings:Sort = new Sort();
			dataSortForBGReadings.fields=[dataSortFieldForReturnValue];
			returnValue.sort = dataSortForBGReadings;
			returnValue.refresh();
			return returnValue;
		}
		
		public static function initialCalibration(bg1:Number, bg2:Number):void {
			//TODO take unit from settings
			var unit:String = "mgdl";
			if (unit != "mgdl") {
				bg1 = bg1 * BgReading.MMOLL_TO_MGDL;
				bg2 = bg2 * BgReading.MMOLL_TO_MGDL;
			}
			
			clearAllExistingCalibrations();
			
			var sensorId:String = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_ID_CURRENT_SENSOR_ID);
			var sensor:Sensor = Database.getSensor(sensorId);
			var bgReadings:ArrayCollection = BgReading.latestBySize(2);
			var bgReading1:BgReading = bgReadings.getItemAt(0) as BgReading;
			var bgReading2:BgReading = bgReadings.getItemAt(1) as BgReading;
			var highBgReading:BgReading;
			var lowBgReading:BgReading;
			var higherBg:Number = Math.max(bg1, bg2);
			var lowerBg:Number = Math.min(bg1,bg2);
			
			if (bgReading1.rawData > bgReading2.rawData) {
				highBgReading = bgReading1;
				lowBgReading = bgReading2;
			} else {
				highBgReading = bgReading2;
				lowBgReading = bgReading1;
			}
			
			//create and save high calibration
			var higherCalibration:Calibration = new Calibration(
				(new Date()).valueOf(),//timestamp
				(new Date()).valueOf() - sensor.startedAt,//sensor age at time of estimation
				sensor,
				higherBg,//bg
				highBgReading.rawData,//rawvalue
				highBgReading.ageAdjustedRawValue,//adjustedrawvalue
				((-0.0018 * higherBg * higherBg) + (0.6657 * higherBg) + 36.7505) / 100,//sensorconfidence,
				0.5,//slopeconfidence,
				highBgReading.timestamp,//rawtimestamp
				1,//slope
				higherBg,//intercept
				0,//distancefromestimate,
				highBgReading.ageAdjustedRawValue,//estimaterawattimeofcalibration
				0,//estimatebgattimeofcalibration - default value, it seems never assigned a value in the android project
				false,//possible bad defualt value
				false,//checkin
				new Number(0),//firstdecay
				new Number(0),//seconddecay
				new Number(0),//firstslope
				new Number(0),//secondslope
				new Number(0),//firstintercept
				new Number(0),//secondintercept
				new Number(0),//firstscale
				new Number(0),//secondscale
				(new Date()).valueOf(),
				Utilities.UniqueId.createEventId()
			);
			higherCalibration.saveToDatabaseSynchronous();

			//create and save low calibration
			var lowerCalibration:Calibration = new Calibration(
				(new Date()).valueOf(),//timestamp
				(new Date()).valueOf() - sensor.startedAt,//sensor age at time of estimation
				sensor,
				lowerBg,//bg
				lowBgReading.rawData,//rawvalue
				lowBgReading.ageAdjustedRawValue,//adjustedrawvalue
				((-0.0018 * lowerBg * lowerBg) + (0.6657 * lowerBg) + 36.7505) / 100,//sensorconfidence,
				0.5,//slopeconfidence,
				lowBgReading.timestamp,//rawtimestamp
				1,//slope
				lowerBg,//intercept
				0,//distancefromestimate,
				lowBgReading.ageAdjustedRawValue,//estimaterawattimeofcalibration
				0,//estimatebgattimeofcalibration - default value, it seems never assigned a value in the android project
				false,//possible bad defualt value
				false,//checkin
				new Number(0),//firstdecay
				new Number(0),//seconddecay
				new Number(0),//firstslope
				new Number(0),//secondslope
				new Number(0),//firstintercept
				new Number(0),//secondintercept
				new Number(0),//firstscale
				new Number(0),//secondscale
				(new Date()).valueOf(),
				Utilities.UniqueId.createEventId()
			);
			lowerCalibration.saveToDatabaseSynchronous();
			
			highBgReading.calculatedValue = higherBg;
			highBgReading.calibrationFlag = true;
			highBgReading.calibration = higherCalibration;
			
			lowBgReading.calculatedValue = lowerBg;
			lowBgReading.calibrationFlag = true;
			lowBgReading.calibration = lowerCalibration;
			
			highBgReading.findNewCurve();
			highBgReading.findNewRawCurve();
			lowBgReading.findNewCurve();
			lowBgReading.findNewCurve();

			highBgReading.updateInDatabaseSynchronous();
			lowBgReading.updateInDatabaseSynchronous();

			calculateWLS();
			adjustRecentBgReadings(5);
			CalibrationRequest.createOffset(lowerBg, 35);
		}
		
		/**
		 * no database insert of the new calibration !
		 */
		public static function create(bg:Number):Calibration {
			//TODO take unit from settings
			var unit:String = "mgdl";
			if (unit != "mgdl") {
				bg = bg * BgReading.MMOLL_TO_MGDL;
			}
			
			CalibrationRequest.clearAllSynchronous();
			var sensor:Sensor = Sensor.getActiveSensor();
			if (sensor != null) {
				var bgReading:BgReading = BgReading.latest(1) as BgReading;//TODO geeft dit wel degelijk de laatste ?
				if (bgReading != null) {
					var estimatedRawBg:Number = BgReading.estimatedRawBg((new Date()).valueOf());
					var calibration:Calibration = new Calibration(
						(new Date()).valueOf(),//timestamp
						(new Date()).valueOf() - sensor.startedAt,//sensorageattimeofestimation
						sensor,//sensor
						bg,//bg
						bgReading.rawData,//rawvalue
						bgReading.ageAdjustedRawValue,//ajustedrawvalue
						Math.max(((-0.0018 * bg * bg) + (0.6657 * bg) + 36.7505) / 100, 0),//sensorconfidence
						Math.min(Math.max(((4 - Math.abs((bgReading.calculatedValueSlope) * 60000))/4), 0), 1),//slopeconfidence,
						bgReading.timestamp,//rawtimestamp
						new Number(0),//slope
						new Number(0),//intercept
						Math.abs(calibration.bg - bgReading.calculatedValue),//distance from estimate
						Math.abs(estimatedRawBg - bgReading.ageAdjustedRawValue) > 20 ? bgReading.ageAdjustedRawValue : estimatedRawBg,//estimaterawattimeofcalibration
						new Number(0),//estimatebgattimeofcalibration
						false,//possiblebad
						false,//checkin
						new Number(0),//firstdecay
						new Number(0),//seconddecay
						new Number(0),//firstslope
						new Number(0),//secondslope
						new Number(0),//firstintercept
						new Number(0),//secondintercept
						new Number(0),//firstscale
						new Number(0),//second scale
						(new Date()).valueOf(),//lastmodifiedtimestamp
						Utilities.UniqueId.createEventId()//eventid
						);
					bgReading.calibration = calibration;
					bgReading.calibrationFlag = true;
					bgReading.updateInDatabaseSynchronous();
					calculateWLS();
					adjustRecentBgReadings(1);//TODO to align with android version, make it configurable to adjust up to 30 days
					Calibration.requestCalibrationIfRangeTooNarrow();
				}
			}
			return Calibration.last();
		}
		
		/**
		 * with database update 
		 */
		private static function calculateWLS():void {
		 	var sParams:SlopeParameters = new DexParameters();
			if (Sensor.getActiveSensor()) {
				var l:Number = 0;
				var m:Number = 0;
				var n:Number = 0;
				var p:Number = 0;
				var q:Number = 0;
				var w:Number;
				var calibrations:ArrayCollection = allForSensorInLastXDays(4);
				if (calibrations.length <= 1) {
					var calibration:Calibration = Calibration.last();
					calibration.slope = 1;
					calibration.intercept = calibration.bg - (calibration.rawValue * calibration.slope);
					calibration.updateInDatabaseSynchronous();
					CalibrationRequest.createOffset(calibration.bg, 25);
				} else {
					for each (var calibration:Calibration in calibrations) {
						w = calibration.calculateWeight();
						l += (w);
						m += (w * calibration.estimateRawAtTimeOfCalibration);
						n += (w * calibration.estimateRawAtTimeOfCalibration * calibration.estimateRawAtTimeOfCalibration);
						p += (w * calibration.bg);
						q += (w * calibration.estimateRawAtTimeOfCalibration * calibration.bg);
					}
					var lastCalibration:Calibration = last();
					w = (lastCalibration.calculateWeight() * (calibrations.length * 0.14));
					l += (w);
					m += (w * lastCalibration.estimateRawAtTimeOfCalibration);
					n += (w * lastCalibration.estimateRawAtTimeOfCalibration * lastCalibration.estimateRawAtTimeOfCalibration);
					p += (w * lastCalibration.bg);
					q += (w * lastCalibration.estimateRawAtTimeOfCalibration * lastCalibration.bg);

					var d:Number = (l * n) - (m * m);
					var calibration:Calibration = last();
					calibration.intercept = ((n * p) - (m * q)) / d;
					calibration.slope = ((l * q) - (m * p)) / d;
					if ((calibrations.length == 2 && calibration.slope < sParams.LOW_SLOPE_1) || (calibration.slope < sParams.LOW_SLOPE_2)) { // I have not seen a case where a value below 7.5 proved to be accurate but we should keep an eye on this
						calibration.slope = calibration.slopeOOBHandler(0);
						if(calibrations.length > 2) { calibration.possibleBad = true; }
						calibration.intercept = calibration.bg - (calibration.estimateRawAtTimeOfCalibration * calibration.slope);
						CalibrationRequest.createOffset(calibration.bg, 25);
					}
					if ((calibrations.length == 2 && calibration.slope > sParams.HIGH_SLOPE_1) || (calibration.slope > sParams.HIGH_SLOPE_2)) {
						calibration.slope = calibration.slopeOOBHandler(1);
						if(calibrations.length > 2) { calibration.possibleBad = true; }
						calibration.intercept = calibration.bg - (calibration.estimateRawAtTimeOfCalibration * calibration.slope);
						CalibrationRequest.createOffset(calibration.bg, 25);
					}
					calibration.updateInDatabaseSynchronous();					
				}
			}
		}
		
		/**
		 * arraycollection with latest number of calibrations, descending<br>
		 * if there's none then empty arraycollection is returned 
		 */
		private static function latest(number:int):ArrayCollection {
			var sensorId:String = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_ID_CURRENT_SENSOR_ID);
			if (sensorId == "0")
				return new ArrayCollection();
			return Database.getLatestCalibrations(number,sensorId);
		}
		
		private function slopeOOBHandler(status:int):Number {
			var sParams:SlopeParameters = new DexParameters();
			
			// If the last slope was reasonable and reasonably close, use that, otherwise use a slope that may be a little steep, but its best to play it safe when uncertain
			var calibrations:ArrayCollection = Calibration.latest(3);
			var thisCalibration:Calibration = calibrations.getItemAt(0) as Calibration;
			if(status == 0) {
				if (calibrations.length == 3) {
					if ((Math.abs(thisCalibration.bg - thisCalibration.estimateBgAtTimeOfCalibration) < 30) && (calibrations.getItemAt(1).possible_bad != null && calibrations.getItemAt(1).possible_bad == true)) {
						return calibrations.getItemAt(1).slope;
					} else {
						return Math.max(((-0.048) * (thisCalibration.sensorAgeAtTimeOfEstimation / (60000 * 60 * 24))) + 1.1, sParams.DEFAULT_LOW_SLOPE_LOW);
					}
				} else if (calibrations.length == 2) {
					return Math.max(((-0.048) * (thisCalibration.sensorAgeAtTimeOfEstimation / (60000 * 60 * 24))) + 1.1, sParams.DEFAULT_LOW_SLOPE_HIGH);
				}
				return sParams.DEFAULT_SLOPE;
			} else {
				if (calibrations.length == 3) {
					if ((Math.abs(thisCalibration.bg - thisCalibration.estimateBgAtTimeOfCalibration) < 30) && (calibrations.getItemAt(1).possible_bad != null && calibrations.getItemAt(1).possible_bad == true)) {
						return calibrations.getItemAt(1).slope;
					} else {
						return sParams.DEFAULT_HIGH_SLOPE_HIGH;
					}
				} else if (calibrations.length == 2) {
					return sParams.DEFAUL_HIGH_SLOPE_LOW;
				}
			}
			return sParams.DEFAULT_SLOPE;
		}
		
		/**
		 * gets the last calibration for the current active sensor<br>
		 * returns null if there's none
		 */
		public static function last():Calibration {
			var sensorId:String = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_ID_CURRENT_SENSOR_ID);
			return Database.getLastOrFirstCalibration(sensorId, false);
		}
		
		/**
		 * gets the first calibration for the current active sensor<br>
		 * returns null if there's none
		 */
		public static function first():Calibration {
			var sensorId:String = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_ID_CURRENT_SENSOR_ID);
			return Database.getLastOrFirstCalibration(sensorId, true);
		}
		
		/**
		 * same as  allForSensorInLastFiveDays in android version, but taking days as a parameter<br>
		 * returnvalue will never be null but can have size 0 if there's no calibration matching
		 */
		public static function allForSensorInLastXDays(days:int):ArrayCollection {
			var sensorId:String = CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_ID_CURRENT_SENSOR_ID);
			if (sensorId == "0")
				return new ArrayCollection();
			return Database.getCalibrationForSensorInLastXDays(days, sensorId);
		}
		
		private function calculateWeight():Number {
			var firstTimeStarted:Number = Calibration.first().sensorAgeAtTimeOfEstimation;
			var lastTimeStarted:Number = Calibration.last().sensorAgeAtTimeOfEstimation;
			var timePercentage:Number = Math.min(((sensorAgeAtTimeOfEstimation - firstTimeStarted) / (lastTimeStarted - firstTimeStarted)) / (0.85), 1);
			timePercentage = (timePercentage + 0.01);
			return Math.max((((((slopeConfidence + sensorConfidence) * (timePercentage))) / 2) * 100), 1);
		}
		
		/**
		 * with database update of the adjusted bgreadings
		 */
		public static function adjustRecentBgReadings(adjustCount:int):void {
			var calibrations:ArrayCollection = Calibration.latest(3);
			var bgReadings:ArrayCollection= BgReading.latestUnCalculated(adjustCount);
			if (calibrations.length == 3) {
				var denom:int = bgReadings.length;
				var latestCalibration:Calibration = calibrations.getItemAt(0) as Calibration;
				var i:int = 0;
				for each (var bgReading:BgReading in bgReadings) {
					var oldYValue:Number = bgReading.calculatedValue;
					var newYvalue:Number = (bgReading.ageAdjustedRawValue * latestCalibration.slope) + latestCalibration.intercept;
					bgReading.calculatedValue = ((newYvalue * (denom - i)) + (oldYValue * ( i ))) / denom;
					bgReading.updateInDatabaseSynchronous();
					i += 1;
				}
			} else if (calibrations.length == 2) {
				var latestCalibration:Calibration = calibrations.getItemAt(0) as Calibration;
				for each (var bgReading:BgReading in bgReadings) {
					var newYvalue:Number = (bgReading.ageAdjustedRawValue * latestCalibration.slope) + latestCalibration.intercept;
					bgReading.calculatedValue = newYvalue;
					BgReading.updateCalculatedValue(bgReading);
					bgReading.updateInDatabaseSynchronous();
				}
			}
			(bgReadings.getItemAt(0) as BgReading).findNewRawCurve();
			(bgReadings.getItemAt(0) as BgReading).findNewCurve();
			(bgReadings.getItemAt(0) as BgReading).updateInDatabaseSynchronous();
			(bgReadings.getItemAt(0) as BgReading).updateInDatabaseSynchronous();		
		}
		
		public static function requestCalibrationIfRangeTooNarrow():void {
			var max:Number = Calibration.recent(true);
			var min:Number = Calibration.recent(false);
			if ((max - min) < 55) {
				var avg:Number = ((min + max) / 2);
				var dist:Number = max - avg;
				CalibrationRequest.createOffset(avg, dist + 20);
			}
		}
		
		/**
		 * same as minRecent and maxRecent in the android project but combined in one single method
		 */
		public static function recent(max:Boolean):Number {
			var sensor:Sensor = Sensor.getActiveSensor();
			var calibrations:ArrayCollection = Database.getCalibrationForSensorInLastXDays(4, sensor.uniqueId);
			if (calibrations.length == 0) {
				if (max)
					return 120;
				else
					return 100;
			}
			var dataSortField:SortField = new SortField();
			dataSortField.name = "bg";
			dataSortField.numeric = true;
			if (max)
				dataSortField.descending = true;//ie from large to small
			else
				dataSortField.descending = false;
			var dataSort:Sort = new Sort();
			dataSort.fields=[dataSortField];
			calibrations.sort = dataSort;
			calibrations.refresh();
			
			return (calibrations.getItemAt(0) as Calibration).bg;
		}
		
		/**
		 * no database update of the calibration ! 
		 */
		public function rawValueOverride(rawValue:Number):Calibration {
			_estimateRawAtTimeOfCalibration = rawValue;
			resetLastModifiedTimeStamp();
			calculateWLS();
			return this;
		}
		
		public function saveToDatabaseSynchronous():Calibration {
			Database.insertCalibrationSynchronous(this);
			return this;
		}
		
		public function updateInDatabaseSynchronous():Calibration {
			Database.updateCalibrationSynchronous(this);
			return this;
		}
		
		public function deleteInDatabaseSynchronous():Calibration {
			Database.deleteCalibrationSynchronous(this);
			return this;
		}
	}
}

internal class SlopeParameters {
	protected var _LOW_SLOPE_1:Number;
	
	public function set LOW_SLOPE_1(value:Number):void
	{
		_LOW_SLOPE_1 = value;
	}
	
	
	public function get LOW_SLOPE_1():Number
	{
		return _LOW_SLOPE_1;
	}
	
	protected var _LOW_SLOPE_2:Number;

	public function set LOW_SLOPE_2(value:Number):void
	{
		_LOW_SLOPE_2 = value;
	}

	
	public function get LOW_SLOPE_2():Number
	{
		return _LOW_SLOPE_2;
	}

	protected var _HIGH_SLOPE_1:Number;

	public function set HIGH_SLOPE_1(value:Number):void
	{
		_HIGH_SLOPE_1 = value;
	}

	
	public function get HIGH_SLOPE_1():Number
	{
		return _HIGH_SLOPE_1;
	}
	
	protected var _HIGH_SLOPE_2:Number;

	public function set HIGH_SLOPE_2(value:Number):void
	{
		_HIGH_SLOPE_2 = value;
	}

	
	public function get HIGH_SLOPE_2():Number
	{
		return _HIGH_SLOPE_2;
	}
	
	protected var _DEFAULT_LOW_SLOPE_LOW:Number;

	public function set DEFAULT_LOW_SLOPE_LOW(value:Number):void
	{
		_DEFAULT_LOW_SLOPE_LOW = value;
	}

	
	public function get DEFAULT_LOW_SLOPE_LOW():Number
	{
		return _DEFAULT_LOW_SLOPE_LOW;
	}
	
	protected var _DEFAULT_LOW_SLOPE_HIGH:Number;

	public function set DEFAULT_LOW_SLOPE_HIGH(value:Number):void
	{
		_DEFAULT_LOW_SLOPE_HIGH = value;
	}

	
	public function get DEFAULT_LOW_SLOPE_HIGH():Number
	{
		return _DEFAULT_LOW_SLOPE_HIGH;
	}
	
	protected var _DEFAULT_SLOPE:int;

	public function set DEFAULT_SLOPE(value:int):void
	{
		_DEFAULT_SLOPE = value;
	}

	
	public function get DEFAULT_SLOPE():int
	{
		return _DEFAULT_SLOPE;
	}
	
	protected var _DEFAULT_HIGH_SLOPE_HIGH:Number;

	public function set DEFAULT_HIGH_SLOPE_HIGH(value:Number):void
	{
		_DEFAULT_HIGH_SLOPE_HIGH = value;
	}

	
	public function get DEFAULT_HIGH_SLOPE_HIGH():Number
	{
		return _DEFAULT_HIGH_SLOPE_HIGH;
	}
	
	protected var _DEFAUL_HIGH_SLOPE_LOW:Number;

	public function set DEFAUL_HIGH_SLOPE_LOW(value:Number):void
	{
		_DEFAUL_HIGH_SLOPE_LOW = value;
	}

	
	public function get DEFAUL_HIGH_SLOPE_LOW():Number
	{
		return _DEFAUL_HIGH_SLOPE_LOW;
	}
	
}

internal class DexParameters extends SlopeParameters {
	function DexParameters() {
		LOW_SLOPE_1 = 0.95;
		LOW_SLOPE_2 = 0.85;
		HIGH_SLOPE_1 = 1.3;
		HIGH_SLOPE_2 = 1.4;
		DEFAULT_LOW_SLOPE_LOW = 1.08;
		DEFAULT_LOW_SLOPE_HIGH = 1.15;
		DEFAULT_SLOPE = 1;
		DEFAULT_HIGH_SLOPE_HIGH = 1.3;
		DEFAUL_HIGH_SLOPE_LOW = 1.2;
	}
}

/* THIS IS FOR LIMITTER */
/*internal class LiParameters extends SlopeParameters {
	function LiParameters(){
		LOW_SLOPE_1 = 1;
		LOW_SLOPE_2 = 1;
		HIGH_SLOPE_1 = 1;
		HIGH_SLOPE_2 = 1;
		DEFAULT_LOW_SLOPE_LOW = 1;
		DEFAULT_LOW_SLOPE_HIGH = 1;
		DEFAULT_SLOPE = 1;
		DEFAULT_HIGH_SLOPE_HIGH = 1;
		DEFAUL_HIGH_SLOPE_LOW = 1;
	}
}*/

