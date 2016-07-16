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
 
 */
package databaseclasses
{
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	
	import model.ModelLocator;
	
	public class Database extends EventDispatcher
	{
		//Actual Database error : 0034
		[ResourceBundle("database")]
		private static var _instance:Database = new Database();
		public static function get instance():Database {
			return _instance;
		}
		
		public static var aConn:SQLConnection;		
		private static var sqlStatement:SQLStatement;
		private static var globalDispatcher:EventDispatcher;
		private static var sampleDatabaseFileName:String = "xdripreader-sample.db";;
		private static const dbFileName:String = "xdripreader.db";
		private  static var dbFile:File  ;
		private static var xmlFileName:String;
		private static var databaseWasCopiedFromSampleFile:Boolean = false;
		private static const maxDaysToKeepLogfiles:int = 2;
		public static const END_OF_RESULT:String = "END_OF_RESULT";
		
		/**
		 * create table to store the bluetooth device name and address<br>
		 * At most one row should be stored
		 */
		private static const CREATE_TABLE_BLUETOOTH_DEVICE:String = "CREATE TABLE IF NOT EXISTS bluetoothdevice (" +
			"bluetoothdevice_id STRING PRIMARY KEY, " + //unique id, used in all tables that will use Google Sync (note that for iOS no google sync will be done for this table because mac address is not visible in iOS. UDID is used as address but this is different for each install
			"name STRING, " +
			"address STRING, " +
			"lastmodifiedtimestamp TIMESTAMP NOT NULL)";
		
		private static const CREATE_TABLE_LOGGING:String = "CREATE TABLE IF NOT EXISTS logging (" +
			"logging_id STRING PRIMARY KEY, " +
			"log STRING, " +
			"logtimestamp TIMESTAMP NOT NULL, " +
			"lastmodifiedtimestamp TIMESTAMP NOT NULL)";
		
		private static const CREATE_TABLE_CALIBRATION_REQUEST:String = "CREATE TABLE IF NOT EXISTS calibrationrequest (" +
			"calibrationrequestid STRING PRIMARY KEY," +
			"requestifabove REAL," +
			"deleted BOOLEAN," +
			"requestifbelow REAL)";
		
		private static const CREATE_TABLE_CALIBRATION:String = "CREATE TABLE IF NOT EXISTS calibration (" +
			"calibrationid STRING PRIMARY KEY," +
			"lastmodifiedtimestamp TIMESTAMP NOT NULL," +
			"timestamp TIMESTAMP," +
			"sensorAgeAtTimeOfEstimation REAL," +
			"sensorid STRING," +
			"bg REAL," +
			"rawValue REAL," +
			"adjustedRawValue REAL," +
			"sensorConfidence REAL," +
			"slopeConfidence REAL," +
			"rawTimestamp TIMESTAMP," +
			"slope REAL," +
			"intercept REAL," +
			"distanceFromEstimate REAL," +
			"estimateRawAtTimeOfCalibration REAL," +
			"estimateBgAtTimeOfCalibration REAL," +
			"possibleBad BOOLEAN," +
			"checkIn BOOLEAN," +
			"firstDecay REAL," +
			"secondDecay REAL," +
			"firstSlope REAL," +
			"secondSlope REAL," +
			"firstIntercept REAL," +
			"secondIntercept REAL," +
			"firstScale REAL," +
			"secondScale REAL," +
			"FOREIGN KEY (sensorid) REFERENCES sensor(sensorid))";
		
		private static const CREATE_TABLE_SENSOR:String = "CREATE TABLE IF NOT EXISTS sensor (" +
			"sensorid STRING PRIMARY KEY," +
			"lastmodifiedtimestamp TIMESTAMP NOT NULL," +
			"startedat TIMESTAMP," +
			"stoppedat TIMESTAMP," +
			"latestbatterylevel INTEGER)";
		
		private static const CREATE_TABLE_BGREADING:String = "CREATE TABLE IF NOT EXISTS bgreading (" +
			"bgreadingid STRING PRIMARY KEY," +
			"lastmodifiedtimestamp TIMESTAMP NOT NULL," +
			"timestamp TIMESTAMP NOT NULL," +
			"sensorid STRING," +
			"calibrationid STRING," +
			"rawData REAL," +
			"filteredData REAL," +
			"ageAdjustedRawValue REAL," +
			"calibrationFlag BOOLEAN," +
			"calculatedValue REAL," +
			"filteredCalculatedValue REAL," +
			"calculatedValueSlope REAL," +
			"a REAL," +
			"b REAL," +
			"c REAL," +
			"ra REAL," +
			"rb REAL," +
			"rc REAL," +
			"rawCalculated REAL," +
			"hideSlope BOOLEAN," +
			"noise STRING " + ")";
		
		private static const SELECT_ALL_BLUETOOTH_DEVICES:String = "SELECT * from bluetoothdevice";
		private static const INSERT_DEFAULT_BLUETOOTH_DEVICE:String = "INSERT into bluetoothdevice (bluetoothdevice_id, name, address, lastmodifiedtimestamp) VALUES (:bluetoothdevice_id,:name, :address, :lastmodifiedtimestamp)";
		private static const INSERT_LOG:String = "INSERT into logging (logging_id, log, logtimestamp, lastmodifiedtimestamp) VALUES (:logging_id, :log, :logtimestamp, :lastmodifiedtimestamp)";
		private static const DELETE_OLD_LOGS:String = "DELETE FROM logging where (logtimestamp < :logtimestamp)";
		private static const GET_ALL_LOGGINGS:String = "SELECT * from logging";
		
		/**
		 * to update the bloothdevice, there's only one, no need to have a where clause
		 */
		private static const UPDATE_BLUETOOTH_DEVICE:String = "UPDATE bluetoothdevice SET address = :address, name = :name, lastmodifiedtimestamp = :lastmodifiedtimestamp"; 
		/**
		 * constructor, should not be used
		 */
		
		private static var databaseInformationEvent:DatabaseEvent;
		
		public function Database()
		{
			if (_instance != null) {
				throw new Error("Database class constructor can not be used");	
			}
		}
		
		/**
		 * Create the asynchronous connection to the database<br>
		 * In the complete flow first an attempt will be made to open the database in update mode. <br>
		 * If that fails, it means the database is not existing yet. Then an attempt is made to copy a sample from the assets<br>
		 * <br>
		 * Independent of the result of the attempt to open the database and to copy from the assets, all tables will be created (if not existing yet).<br>
		 * <br>
		 * A default bluetooth device is created if not existing yet with name "", address "", lastmodifiedtimestamp current date, id = BlueToothDevice.DEFAULT_BLUETOOTH_DEVICE_ID
		 **/
		public static function init(dispatcher:EventDispatcher):void
		{
			trace("Database.init");
			
			globalDispatcher = dispatcher;
			dbFile  = File.applicationStorageDirectory.resolvePath(dbFileName);
			
			aConn = new SQLConnection();
			aConn.addEventListener(SQLEvent.OPEN, onConnOpen);
			aConn.addEventListener(SQLErrorEvent.ERROR, onConnError);
			trace("Database.as : Attempting to open database in update mode. Database:0001");
			aConn.openAsync(dbFile, SQLMode.UPDATE);
			
			function onConnOpen(se:SQLEvent):void
			{
				trace("Database.as : SQL Connection successfully opened. Database:0002");
				aConn.removeEventListener(SQLEvent.OPEN, onConnOpen);
				aConn.removeEventListener(SQLErrorEvent.ERROR, onConnError);	
				createTables();
			}
			
			function onConnError(see:SQLErrorEvent):void
			{
				trace("Database.as : SQL Error while attempting to open database. Database:0003");
				aConn.removeEventListener(SQLEvent.OPEN, onConnOpen);
				aConn.removeEventListener(SQLErrorEvent.ERROR, onConnError);
				reAttempt();
			}
			
			function reAttempt():void {
				//attempt to create dbFile based on a sample in assets directory, 
				//if that fails then dbFile will simply not exist and so will be created later on in openAsync 
				databaseWasCopiedFromSampleFile = createDatabaseFromAssets(dbFile);
				aConn = new SQLConnection();
				aConn.addEventListener(SQLEvent.OPEN, onConnOpen);
				aConn.addEventListener(SQLErrorEvent.ERROR, onConnError);
				trace("Database.as : Attempting to open database in creation mode. Database:0004");
				aConn.openAsync(dbFile, SQLMode.CREATE);
			}
		}
		
		private static function createTables():void
		{			
			trace("Database.as : in method createtables");
			sqlStatement = new SQLStatement();
			sqlStatement.sqlConnection = aConn;
			createCalibrationRequestTable();				
		}
		
		private static function createCalibrationRequestTable():void {
			sqlStatement.clearParameters();
			sqlStatement.text = CREATE_TABLE_CALIBRATION_REQUEST;
			sqlStatement.addEventListener(SQLEvent.RESULT,tableCreated);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR,tableCreationError);
			sqlStatement.execute();
			
			function tableCreated(se:SQLEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				createSensorTable();
			}
			
			function tableCreationError(see:SQLErrorEvent):void {
				trace("Database.as : Failed to create calibration request table. Database:0024");
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				dispatchInformation('failed_to_create_calibration_request_table', see != null ? see.error.details:null);
				if (globalDispatcher != null) {
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Failed to create calibration request  table. Database:0025";
					globalDispatcher.dispatchEvent(errorEvent);
				}
			}
		}
		
		private static function createSensorTable():void {
			sqlStatement.clearParameters();
			sqlStatement.text = CREATE_TABLE_SENSOR;
			sqlStatement.addEventListener(SQLEvent.RESULT,tableCreated);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR,tableCreationError);
			sqlStatement.execute();
			
			function tableCreated(se:SQLEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				createCalibrationTable();
			}
			
			function tableCreationError(see:SQLErrorEvent):void {
				trace("Database.as : Failed to create sensor table. Database:0028");
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				dispatchInformation('failed_to_create_sensor_table', see != null ? see.error.details:null);
				if (globalDispatcher != null) {
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Failed to create sensor table. Database:0029";
					globalDispatcher.dispatchEvent(errorEvent);
				}
			}
		}
		
		private static function createCalibrationTable():void {
			sqlStatement.clearParameters();
			sqlStatement.text = CREATE_TABLE_CALIBRATION;
			sqlStatement.addEventListener(SQLEvent.RESULT,tableCreated);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR,tableCreationError);
			sqlStatement.execute();
			
			function tableCreated(se:SQLEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				createBGreadingTable();
			}
			
			function tableCreationError(see:SQLErrorEvent):void {
				trace("Database.as : Failed to create calibration table. Database:0026");
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				dispatchInformation('failed_to_create_calibration_table', see != null ? see.error.details:null);
				if (globalDispatcher != null) {
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Failed to create calibration table. Database:0027";
					globalDispatcher.dispatchEvent(errorEvent);
				}
			}
		}
		
		private static function createBGreadingTable():void {
			sqlStatement.clearParameters();
			sqlStatement.text = CREATE_TABLE_BGREADING;
			sqlStatement.addEventListener(SQLEvent.RESULT,tableCreated);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR,tableCreationError);
			sqlStatement.execute();
			
			function tableCreated(se:SQLEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				createBlueToothDeviceTable();
			}
			
			function tableCreationError(see:SQLErrorEvent):void {
				trace("Database.as : Failed to create bgreading table. Database:0030");
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				dispatchInformation('failed_to_create_bgreading_table', see != null ? see.error.details:null);
				if (globalDispatcher != null) {
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Failed to create bgreading table. Database:0031";
					globalDispatcher.dispatchEvent(errorEvent);
				}
			}
		}
		
		private static function createBlueToothDeviceTable():void {
			sqlStatement.clearParameters();
			sqlStatement.text = CREATE_TABLE_BLUETOOTH_DEVICE;
			sqlStatement.addEventListener(SQLEvent.RESULT,tableCreated);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR,tableCreationError);
			sqlStatement.execute();
			
			function tableCreated(se:SQLEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				selectBlueToothDevices();
			}
			
			function tableCreationError(see:SQLErrorEvent):void {
				trace("Database.as : Failed to create BlueToothDevice table. Database:0005");
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				if (globalDispatcher != null) {
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Failed to create BlueToothDevice table. Database:0006";
					globalDispatcher.dispatchEvent(errorEvent);
					//globalDispatcher = null;
				}
			}
		}
		
		private static function selectBlueToothDevices():void {
			sqlStatement.clearParameters();
			sqlStatement.text = SELECT_ALL_BLUETOOTH_DEVICES;
			sqlStatement.addEventListener(SQLEvent.RESULT,blueToothDevicesSelected);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR,blueToothDevicesSelectionFailed);
			sqlStatement.execute();
			
			function blueToothDevicesSelected(se:SQLEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,blueToothDevicesSelected);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,blueToothDevicesSelectionFailed);
				var result:Object = sqlStatement.getResult().data;
				if (result != null) {
					if (result is Array) {
						if ((result as Array).length == 1) {
							//there's a bluetoothdevice already, no need to further check
							createLoggingTable();
							return;
						}
					}
				}
				//not using else here because i think there might be other cases like restult not being null but having no elements ?
				insertBlueToothDevice();
			}
			
			function blueToothDevicesSelectionFailed(se:SQLErrorEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,blueToothDevicesSelected);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,blueToothDevicesSelectionFailed);
				if (globalDispatcher != null) {
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Failed to select BlueToothDevices. Database:0009";
					globalDispatcher.dispatchEvent(errorEvent);
					//globalDispatcher = null;
				}
			}
		}
		
		/**
		 * will add one row, with name and address "", and default id 
		 */
		private static function insertBlueToothDevice():void {
			sqlStatement.clearParameters();
			sqlStatement.text = INSERT_DEFAULT_BLUETOOTH_DEVICE;
			sqlStatement.parameters[":bluetoothdevice_id"] = BlueToothDevice.DEFAULT_BLUETOOTH_DEVICE_ID;
			sqlStatement.parameters[":name"] = ""; 
			sqlStatement.parameters[":address"] = "";
			sqlStatement.parameters[":lastmodifiedtimestamp"] = (new Date()).valueOf();
			sqlStatement.addEventListener(SQLEvent.RESULT,defaultBlueToothDeviceInserted);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR,defaultBlueToothDeviceInsetionFailed);
			sqlStatement.execute();
			
			function defaultBlueToothDeviceInserted(se:SQLEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,defaultBlueToothDeviceInserted);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,defaultBlueToothDeviceInsetionFailed);
				createLoggingTable();
			}
			
			function defaultBlueToothDeviceInsetionFailed(see:SQLErrorEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,defaultBlueToothDeviceInserted);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,defaultBlueToothDeviceInsetionFailed);
				trace("Database.as : insertBlueToothDevice failed. Database 0014");
				if (globalDispatcher != null) {
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Failed to insert default bluetooth device. Database:0010 - details = " + (see.error.details == null ? "":see.error.details);
					globalDispatcher.dispatchEvent(errorEvent);
					//globalDispatcher = null;
				}
			}
		}
		
		private static function createLoggingTable():void {
			sqlStatement.clearParameters();
			sqlStatement.text = CREATE_TABLE_LOGGING;
			sqlStatement.addEventListener(SQLEvent.RESULT,tableCreated);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR,tableCreationError);
			sqlStatement.execute();
			
			function tableCreated(se:SQLEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				deleteOldLogFiles();
			}
			
			function tableCreationError(see:SQLErrorEvent):void {
				trace("Database.as : Failed to create Logging table. Database:0017");
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				if (globalDispatcher != null) {
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Failed to create Logging table. Database:0018";
					globalDispatcher.dispatchEvent(errorEvent);
				}
			}
		}
		
		private static function deleteOldLogFiles():void {
			sqlStatement.clearParameters();
			sqlStatement.text = DELETE_OLD_LOGS;
			sqlStatement.parameters[":logtimestamp"] = (new Date()).valueOf() - maxDaysToKeepLogfiles * 24 * 60 * 60 * 1000;
			
			sqlStatement.addEventListener(SQLEvent.RESULT,oldLogFilesDeleted);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR,oldLogFileDeletionFailed);
			sqlStatement.execute();
			
			function oldLogFilesDeleted(se:SQLEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,oldLogFilesDeleted);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,oldLogFileDeletionFailed);
				finishedCreatingTables();
			}
			
			function oldLogFileDeletionFailed(see:SQLErrorEvent):void {
				trace("Database.as : Failed to delete old logfiles. Database:0021");
				sqlStatement.removeEventListener(SQLEvent.RESULT,oldLogFilesDeleted);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,oldLogFileDeletionFailed);
				if (globalDispatcher != null) {
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Failed to delete old logfiles. Database:0021";
					globalDispatcher.dispatchEvent(errorEvent);
				}
			}
		}
		
		private static function finishedCreatingTables():void {
			if (globalDispatcher != null) {
				globalDispatcher.dispatchEvent(new Event(DatabaseEvent.RESULT_EVENT));
			}
		}
		
		private static function createDatabaseFromAssets(targetFile:File):Boolean 			
		{
			var isSuccess:Boolean = true; 
			
			var sampleFile:File = File.applicationDirectory.resolvePath("assets/database/" + sampleDatabaseFileName);
			if ( !sampleFile.exists )
			{
				isSuccess = false;
			}
			else
			{
				sampleFile.copyTo(targetFile);			
			}
			return isSuccess;			
		}
		
		/**
		 * asynchronous
		 */
		public static function getBlueToothDevice(dispatcher:EventDispatcher):void {
			var localSqlStatement:SQLStatement = new SQLStatement();
			var localdispatcher:EventDispatcher = new EventDispatcher();
			
			localdispatcher.addEventListener(SQLEvent.RESULT,onOpenResult);
			localdispatcher.addEventListener(SQLErrorEvent.ERROR,onOpenError);
			
			if (openSQLConnection(localdispatcher))
				onOpenResult(null);
			
			function onOpenResult(se:SQLEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				
				localSqlStatement.addEventListener(SQLEvent.RESULT,blueToothDeviceRetrieved);
				localSqlStatement.addEventListener(SQLErrorEvent.ERROR,blueToothDeviceRetrievalError);
				localSqlStatement.sqlConnection = aConn;
				localSqlStatement.text = SELECT_ALL_BLUETOOTH_DEVICES;
				localSqlStatement.execute();
			}
			
			function blueToothDeviceRetrieved(se:SQLEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,blueToothDeviceRetrieved);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,blueToothDeviceRetrievalError);
				var tempObject:Object = localSqlStatement.getResult().data;
				var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				if (tempObject != null) {
					event.data = new Object();
					event.data.name = tempObject[0].name;
					event.data.address = tempObject[0].address;
					event.data.bluetoothdevice_id = tempObject[0].bluetoothdevice_id;
					event.data.lastmodifiedtimestamp = tempObject[0].lastmodifiedtimestamp;
					dispatcher.dispatchEvent(event);
				} else {
					//shouldn't happen
					localSqlStatement.removeEventListener(SQLEvent.RESULT,blueToothDeviceRetrieved);
					localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,blueToothDeviceRetrievalError);
					trace("Database.as : there's no bluetoothdevice. Database 0013");
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Database.as there's no bluetoothdevice. Database:0013";
					dispatcher.dispatchEvent(errorEvent);
				}
			}
			
			function blueToothDeviceRetrievalError(see:SQLErrorEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,blueToothDeviceRetrieved);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,blueToothDeviceRetrievalError);
				trace("Database.as : Failed to retrieve bluetoothdevice. Database 0012");
				var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
				errorEvent.data = "Failed to retrieve BlueToothDevice . Database:0012";
				dispatcher.dispatchEvent(errorEvent);
			}
			
			function onOpenError(see:SQLErrorEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				trace("Database.as : Failed to open the database. Database 0011");
				if (dispatcher != null) {
					var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					dispatcher.dispatchEvent(event);
				}
			}
		}
		
		/**
		 * to update the one and only bluetoothdevice 
		 */
		public static function updateBlueToothDevice(address:String, name:String, lastModifiedTimeStamp:Number, dispatcher:EventDispatcher):void {
			var localSqlStatement:SQLStatement = new SQLStatement()
			var localdispatcher:EventDispatcher = new EventDispatcher();
			
			localdispatcher.addEventListener(SQLEvent.RESULT,onOpenResult);
			localdispatcher.addEventListener(SQLErrorEvent.ERROR,onOpenError);
			if (openSQLConnection(localdispatcher))
				onOpenResult(null);
			
			function onOpenResult(se:SQLEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				localSqlStatement.sqlConnection = aConn;
				localSqlStatement.text = UPDATE_BLUETOOTH_DEVICE;
				
				localSqlStatement.parameters[":address"] = address;
				localSqlStatement.parameters[":name"] = name;
				localSqlStatement.parameters[":lastmodifiedtimestamp"] = (isNaN(lastModifiedTimeStamp) ? (new Date()).valueOf() : lastModifiedTimeStamp);
				localSqlStatement.addEventListener(SQLEvent.RESULT, bluetoothDeviceUpdated);
				localSqlStatement.addEventListener(SQLErrorEvent.ERROR, bluetoothDeviceUpdateFailed);
				localSqlStatement.execute();
			}
			
			function bluetoothDeviceUpdated(se:SQLEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,bluetoothDeviceUpdated);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,bluetoothDeviceUpdateFailed);
				trace("Database.as : bluetooth device updated. Database0016");
				if (dispatcher != null) {
					var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dispatcher.dispatchEvent(event);
				}
			}
			
			function bluetoothDeviceUpdateFailed(se:SQLEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,bluetoothDeviceUpdated);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,bluetoothDeviceUpdateFailed);
				trace("Database.as : bluetooth device update failed. Database0017");
				if (dispatcher != null) {
					var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					dispatcher.dispatchEvent(event);
				}
			}
			
			function onOpenError(see:SQLErrorEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				trace("Database.as : Failed to open the database. Database0015");
				if (dispatcher != null) {
					var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					dispatcher.dispatchEvent(event);
				}
			}
		}
		
		public static function insertLogging(logging_id:String, log:String, logTimeStamp:Number, lastModifiedTimeStamp:Number, dispatcher:EventDispatcher):void {
			var localSqlStatement:SQLStatement = new SQLStatement()
			var localdispatcher:EventDispatcher = new EventDispatcher();
			
			localdispatcher.addEventListener(SQLEvent.RESULT,onOpenResult);
			localdispatcher.addEventListener(SQLErrorEvent.ERROR,onOpenError);
			if (openSQLConnection(localdispatcher))
				onOpenResult(null);
			
			function onOpenResult(se:SQLEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				
				localSqlStatement.sqlConnection = aConn;
				localSqlStatement.text = INSERT_LOG;
				
				localSqlStatement.parameters[":logging_id"] = logging_id;
				localSqlStatement.parameters[":log"] = log;
				localSqlStatement.parameters[":logtimestamp"] = logTimeStamp;
				localSqlStatement.parameters[":lastmodifiedtimestamp"] = (isNaN(lastModifiedTimeStamp) ? (new Date()).valueOf() : lastModifiedTimeStamp);
				localSqlStatement.addEventListener(SQLEvent.RESULT,loggingInserted);
				localSqlStatement.addEventListener(SQLErrorEvent.ERROR,loggingInsertionFailed);
				localSqlStatement.execute();
			}
			
			function onOpenError(see:SQLErrorEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				trace("Database.as : Failed to open the database. Database 0020");
				if (dispatcher != null) {
					var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					event.data = "Database.as : Failed to open the database. Database 0020";
					dispatcher.dispatchEvent(event);
				}
			}
			
			function loggingInserted(se:SQLEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,loggingInserted);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,loggingInsertionFailed);
				if (dispatcher != null) {
					var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
					dispatcher.dispatchEvent(event);
				}
			}
			
			function loggingInsertionFailed(see:SQLErrorEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,loggingInserted);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,loggingInsertionFailed);
				if (dispatcher != null) {
					var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					trace("Database.as : Failed to insert logging. Database 0021");
					event.data = "Database.as : Failed to insert logging. Database 0021";
					dispatcher.dispatchEvent(event);
				}
			}
		}
		
		/**
		 * will get the loggings and dispatch them one by one (ie one event per logging) in the data field of a Database Event<br>
		 * If the last string is sent, an additional event is set with data = "END_OF_RESULT"
		 */
		public static function getLoggings(dispatcher:EventDispatcher):void {
			var localSqlStatement:SQLStatement = new SQLStatement();
			var localdispatcher:EventDispatcher = new EventDispatcher();
			
			localdispatcher.addEventListener(SQLEvent.RESULT,onOpenResult);
			localdispatcher.addEventListener(SQLErrorEvent.ERROR,onOpenError);
			
			if (openSQLConnection(localdispatcher))
				onOpenResult(null);
			
			function onOpenResult(se:SQLEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				localSqlStatement.addEventListener(SQLEvent.RESULT,loggingsRetrieved);
				localSqlStatement.addEventListener(SQLErrorEvent.ERROR,loggingRetrievalFailed);
				localSqlStatement.sqlConnection = aConn;
				localSqlStatement.text = GET_ALL_LOGGINGS;
				localSqlStatement.execute();
			}
			
			function loggingsRetrieved(se:SQLEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,loggingsRetrieved);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,loggingRetrievalFailed);
				var tempObject:Object = localSqlStatement.getResult().data;
				if (tempObject != null) {
					if (tempObject is Array) {
						for each ( var o:Object in tempObject) {
							var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
							event.data = o.log;
							dispatcher.dispatchEvent(event);
						}
					}
				} else {
					//no need to dispatch anything, there are no loggings
				}
				var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				event.data = END_OF_RESULT;
				dispatcher.dispatchEvent(event);
			}
			
			function loggingRetrievalFailed(see:SQLErrorEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,loggingsRetrieved);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,loggingRetrievalFailed);
				trace("Database.as : Failed to retrieve loggings. Database 0022");
				var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
				errorEvent.data = "Failed to retrieve loggings . Database:0022";
				dispatcher.dispatchEvent(errorEvent);
			}
			
			function onOpenError(see:SQLErrorEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				trace("Database.as : Failed to open the database. Database 0023");
				if (dispatcher != null) {
					var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					dispatcher.dispatchEvent(event);
				}
			}
		}
		
		/**
		 * inserts a calibrationrequest in the database<br>
		 * dispatches info if anything goes wrong<br>
		 * synchronous
		 */
		public static function insertCalibrationRequestSychronous(calibrationRequest:CalibrationRequest):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var insertRequest:SQLStatement = new SQLStatement();
				insertRequest.sqlConnection = conn;
				insertRequest.text = "INSERT INTO calibrationrequest (calibrationrequestid, lastmodifiedtimestamp, requestifabove, requestifbelow, deleted) " +
					"VALUES ('" + calibrationRequest.uniqueId + "', " +
					calibrationRequest.lastModifiedTimestamp.toString() + 
					", " +
					calibrationRequest.requestIfAbove + ", " + calibrationRequest.requestIfBelow + ", " +
					false +")";
				insertRequest.execute();
				conn.commit();
			} catch (error:SQLError) {
				dispatchInformation('error_while_inserting_calibration_request_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * deletes a calibrationrequest in the database<br>
		 * dispatches info if anything goes wrong 
		 */
		public static function deleteCalibrationRequestSynchronous(calibrationRequest:CalibrationRequest):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var deleteRequest:SQLStatement = new SQLStatement();
				deleteRequest.sqlConnection = conn;
				deleteRequest.text = "UPDATE calibrationrequest SET deleted = true where calibrationrequestid = " + "'" + calibrationRequest.uniqueId + "'";
				deleteRequest.execute();
				conn.commit();
			} catch (error:SQLError) {
				dispatchInformation('error_while_deleting_calibration_request_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * updates a calibrationrequest in the database<br>
		 * dispatches info if anything goes wrong 
		 */
		public static function updateCalibrationRequestSynchronous(calibrationRequest:CalibrationRequest):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var insertRequest:SQLStatement = new SQLStatement();
				insertRequest.sqlConnection = conn;
				insertRequest.text = "UPDATE calibrationrequest SET " +
					"lastmodifiedtimestamp = " + calibrationRequest.lastModifiedTimestamp.toString() + "," +
					"requestifabove = " + calibrationRequest.requestIfAbove + ", " + 
					"requestifbelow = " + calibrationRequest.requestIfBelow + 
					" WHERE calibrationrequestid = " + "'" + calibrationRequest.uniqueId + "'"; 
				insertRequest.execute();
				conn.commit();
			} catch (error:SQLError) {
				dispatchInformation('error_while_updating_calibration_request_in_db', error.details);
				conn.rollback();
			}
		}
		

		/**
		 * deletes all calibrations<br>
		 * synchronous
		 */
		public static function deleteAllCalibrationsSynchronous():void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var deleteRequest:SQLStatement = new SQLStatement();
				deleteRequest.sqlConnection = conn;
				deleteRequest.text = "DELETE from calibration";
				deleteRequest.execute();
				conn.commit();
			} catch (error:SQLError) {
				dispatchInformation('error_while_deleting_all_calibration_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * deletes all calibrationrequests<br>
		 * synchronous
		 */
		public static function deleteAllCalibrationRequestsSynchronous():void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var deleteRequest:SQLStatement = new SQLStatement();
				deleteRequest.sqlConnection = conn;
				deleteRequest.text = "UPDATE calibrationrequest SET deleted = true";
				deleteRequest.execute();
				conn.commit();
			} catch (error:SQLError) {
				dispatchInformation('error_while_deleting_all_calibrationrequests_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * get calibrationRequests with requestIfAbove < value and requestIfBelow > value<br>
		 * synchronous
		 */
		public static function getCalibrationRequestsForValue(value:Number):ArrayCollection {
			var returnValue:ArrayCollection = new ArrayCollection();
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.READ);
				conn.begin();
				var getRequest:SQLStatement = new SQLStatement();
				getRequest.sqlConnection = conn;
				getRequest.text = "SELECT FROM calibrationrequest WHERE deleted = false AND  requestifabove < " + value + " AND requestifbelow > " + value;
				getRequest.execute();
				var result:SQLResult = getRequest.getResult();
				var numResults:int = result.data.length;
				for (var i:int = 0; i < numResults; i++) 
				{ 
					var row:Object = result.data[i]; 
					returnValue.addItem(new CalibrationRequest(row.requestifabove, row.requestifbelow, row.calibrationrequestid, row.lastmodifiedtimestamp));
				} 
			} catch (error:SQLError) {
				dispatchInformation('error_while_getting_calibration_requests_in_db', error.details);
			} catch (other:Error) {
				dispatchInformation('error_while_getting_calibration_requests_in_db',other.getStackTrace().toString());
			} finally {
				return returnValue;
			}
		}
		
		public static function getLatestCalibrations(number:int, sensorId:String):ArrayCollection {
			var returnValue:ArrayCollection = new ArrayCollection();
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.READ);
				conn.begin();
				var getRequest:SQLStatement = new SQLStatement();
				getRequest.sqlConnection = conn;
				getRequest.text = "SELECT FROM calibration WHERE sensorid = " + sensorId ;
				getRequest.execute();
				var result:SQLResult = getRequest.getResult();
				var numResults:int = result.data.length;
				for (var i:int = 0; i < numResults; i++) 
				{ 
					var row:Object = result.data[i];
					var tempReturnValue:ArrayCollection = new ArrayCollection();
					tempReturnValue.addItem(
						new Calibration(
							result.data[i].timestamp,
							result.data[i].sensorAgeAtTimeOfEstimation,
							getSensor(result.data[i].sensorid),
							result.data[i].bg,
							result.data[i].rawValue,
							result.data[i].adjustedRawValue,
							result.data[i].sensorConfidence,
							result.data[i].slopeConfidence,
							result.data[i].rawTimestamp,
							result.data[i].slope,
							result.data[i].intercept,
							result.data[i].distanceFromEstimate,
							result.data[i].estimateRawAtTimeOfCalibration,
							result.data[i].estimateBgAtTimeOfCalibration,
							result.data[i].possibleBad == "1" ? true:false,
							result.data[i].checkIn == "1" ? true:false,
							result.data[i].firstDecay,
							result.data[i].secondDecay,
							result.data[i].firstSlope,
							result.data[i].secondSlope,
							result.data[i].firstIntercept,
							result.data[i].secondIntercept,
							result.data[i].firstScale,
							result.data[i].secondScale,
							result.data[i].lastmodifiedtimestamp,
							result.data[i].calibrationid)
					);
					var dataSortFieldForReturnValue:SortField = new SortField();
					dataSortFieldForReturnValue.name = "timestamp";
					dataSortFieldForReturnValue.numeric = true;
					dataSortFieldForReturnValue.descending = true;//ie from large to small
					var dataSortForBGReadings:Sort = new Sort();
					dataSortForBGReadings.fields=[dataSortFieldForReturnValue];
					tempReturnValue.sort = dataSortForBGReadings;
					tempReturnValue.refresh();
					for (var cntr:int; cntr < tempReturnValue.length; cntr++) {
						returnValue.addItem(tempReturnValue.getItemAt(cntr));
						if (cntr == number -1) {
							break;
						}
					}
					//TODO check that returnvalue is in descending order, latest calibrations
				} 
				
			} catch (error:SQLError) {
				dispatchInformation('error_while_getting_latest_calibrations_in_db', error.details);
			} catch (other:Error) {
				dispatchInformation('error_while_getting_latest_calibrations_in_db',other.getStackTrace().toString());
			} finally {
				return tempReturnValue;
			}
		}
			
		
		/**
		 * get calibrations with sensorid and last x days and slopeconfidence != 0 and sensorConfidence != 0<br>
		 * order by timestamp descending
		 * synchronous<br>
		 */
		public static function getCalibrationForSensorInLastXDays(days:int, sensorid:String):ArrayCollection {
			var returnValue:ArrayCollection = new ArrayCollection();
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.READ);
				conn.begin();
				var getRequest:SQLStatement = new SQLStatement();
				getRequest.sqlConnection = conn;
				getRequest.text = "SELECT FROM calibration WHERE sensorid = " + sensorid + " AND slopeConfidence != 0 " +
					"AND sensorConfidence != 0 and timestamp > " + (new Date((new Date()).valueOf() - (60000 * 60 * 24 * days))).valueOf();
				getRequest.execute();
				var result:SQLResult = getRequest.getResult();
				var numResults:int = result.data.length;
				for (var i:int = 0; i < numResults; i++) 
				{ 
					var row:Object = result.data[i]; 
					returnValue.addItem(
						new Calibration(
							result.data[i].timestamp,
							result.data[i].sensorAgeAtTimeOfEstimation,
							getSensor(result.data[i].sensorid),
							result.data[i].bg,
							result.data[i].rawValue,
							result.data[i].adjustedRawValue,
							result.data[i].sensorConfidence,
							result.data[i].slopeConfidence,
							result.data[i].rawTimestamp,
							result.data[i].slope,
							result.data[i].intercept,
							result.data[i].distanceFromEstimate,
							result.data[i].estimateRawAtTimeOfCalibration,
							result.data[i].estimateBgAtTimeOfCalibration,
							result.data[i].possibleBad == "1" ? true:false,
							result.data[i].checkIn == "1" ? true:false,
							result.data[i].firstDecay,
							result.data[i].secondDecay,
							result.data[i].firstSlope,
							result.data[i].secondSlope,
							result.data[i].firstIntercept,
							result.data[i].secondIntercept,
							result.data[i].firstScale,
							result.data[i].secondScale,
							result.data[i].lastmodifiedtimestamp,
							result.data[i].calibrationid)
					);
					var dataSortFieldForReturnValue:SortField = new SortField();
					dataSortFieldForReturnValue.name = "timestamp";
					dataSortFieldForReturnValue.numeric = true;
					dataSortFieldForReturnValue.descending = true;//ie from large to small
					var dataSortForBGReadings:Sort = new Sort();
					dataSortForBGReadings.fields=[dataSortFieldForReturnValue];
					returnValue.sort = dataSortForBGReadings;
					returnValue.refresh();
				} 
				
			} catch (error:SQLError) {
				dispatchInformation('error_while_getting_for_sensor_in_lastxdays_in_db', error.details);
			} catch (other:Error) {
				dispatchInformation('error_while_getting_for_sensor_in_lastxdays_in_db',other.getStackTrace().toString());
			} finally {
				return returnValue;
			}
		}
		
		/**
		 * get first or last calibration for specified sensorid<br>
		 * if first = true then it will return the first, otherwise the last<br>
		 * returns null if there's none
		 * synchronous<br>
		 */
		public static function getLastOrFirstCalibration(sensorid:String, first:Boolean):Calibration {
			var returnValue:Calibration;
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.READ);
				conn.begin();
				var getRequest:SQLStatement = new SQLStatement();
				getRequest.sqlConnection = conn;
				getRequest.text = "SELECT FROM calibration WHERE sensorid = " + sensorid;
				getRequest.execute();
				var result:SQLResult = getRequest.getResult();
				var numResults:int = result.data.length;
				var calibrations:ArrayCollection = new ArrayCollection();
				for (var i:int = 0; i < numResults; i++) 
				{ 
					var row:Object = result.data[i]; 
					calibrations.addItem(
						new Calibration(
							result.data[i].timestamp,
							result.data[i].sensorAgeAtTimeOfEstimation,
							getSensor(result.data[i].sensorid),
							result.data[i].bg,
							result.data[i].rawValue,
							result.data[i].adjustedRawValue,
							result.data[i].sensorConfidence,
							result.data[i].slopeConfidence,
							result.data[i].rawTimestamp,
							result.data[i].slope,
							result.data[i].intercept,
							result.data[i].distanceFromEstimate,
							result.data[i].estimateRawAtTimeOfCalibration,
							result.data[i].estimateBgAtTimeOfCalibration,
							result.data[i].possibleBad == "1" ? true:false,
							result.data[i].checkIn == "1" ? true:false,
							result.data[i].firstDecay,
							result.data[i].secondDecay,
							result.data[i].firstSlope,
							result.data[i].secondSlope,
							result.data[i].firstIntercept,
							result.data[i].secondIntercept,
							result.data[i].firstScale,
							result.data[i].secondScale,
							result.data[i].lastmodifiedtimestamp,
							result.data[i].calibrationid)
					);
					var dataSortFieldForReturnValue:SortField = new SortField();
					dataSortFieldForReturnValue.name = "timestamp";
					dataSortFieldForReturnValue.numeric = true;
					if (first)
						dataSortFieldForReturnValue.descending = true;//ie from large to small
					var dataSortForBGReadings:Sort = new Sort();
					dataSortForBGReadings.fields=[dataSortFieldForReturnValue];
					calibrations.sort = dataSortForBGReadings;
					calibrations.refresh();
					if (calibrations.length > 0)
						returnValue = calibrations.getItemAt(0) as Calibration;
				} 
				
			} catch (error:SQLError) {
				dispatchInformation('error_while_getting_last_or_first_calibration_in_db', error.details);
			} catch (other:Error) {
				dispatchInformation('error_while_getting_last_or_first_calibration_in_db',other.getStackTrace().toString());
			} finally {
				return returnValue;
			}
		}
		
		/**
		 * inserts a calibration in the database<br>
		 * dispatches info if anything goes wrong 
		 */
		public static function insertCalibrationSynchronous(calibration:Calibration):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var insertRequest:SQLStatement = new SQLStatement();
				insertRequest.sqlConnection = conn;
				insertRequest.text = "INSERT INTO calibration (" +
					"calibrationid, " +
					"lastmodifiedtimestamp, " +
					"timestamp," +
					"sensorAgeAtTimeOfEstimation," +
					"sensorid," +
					"bg," +
					"rawValue," +
					"adjustedRawValue," +
					"sensorConfidence," +
					"slopeConfidence," +
					"rawTimestamp," +
					"slope," +
					"intercept," +
					"distanceFromEstimate," +
					"estimateRawAtTimeOfCalibration," +
					"estimateBgAtTimeOfCalibration," +
					"possibleBad," +
					"checkIn" +
					"firstDecay," +
					"secondDecay," +
					"firstSlope," +
					"secondSlope," +
					"firstIntercept," +
					"secondIntercept," +
					"firstScale," +
					"secondScale)" +
					"VALUES ('" + calibration.uniqueId + "', " +
						calibration.lastModifiedTimestamp + ", " +
						calibration.timestamp + ", " +
						calibration.sensorAgeAtTimeOfEstimation + ", " +
						"'" + calibration.sensor.uniqueId +"', " + 
						calibration.bg +", " + 
						calibration.rawValue +", " + 
						calibration.adjustedRawValue +", " + 
						calibration.sensorConfidence  +", " + 
						calibration.slopeConfidence +", " +
						calibration.rawTimestamp +", " +
						calibration.slope +", " +
						calibration.intercept +", " +
						calibration.distanceFromEstimate +", " +
						calibration.estimateRawAtTimeOfCalibration +", " +
						calibration.estimateBgAtTimeOfCalibration +", " +
						calibration.possibleBad ? "1":"0" +", " +
						calibration.checkIn ? "1":"0" +", " +
						calibration.firstDecay +", " +
						calibration.secondDecay +", " +
						calibration.firstSlope +", " +
						calibration.secondSlope +", " +
						calibration.firstIntercept +", " +
						calibration.secondIntercept +", " +
						calibration.firstScale +", " +
						calibration.secondScale + ")";
				insertRequest.execute();
				conn.commit();
			} catch (error:SQLError) {
				dispatchInformation('error_while_inserting_calibration_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * deletes a calibration in the database<br>
		 * dispatches info if anything goes wrong <br>
		 */
		public static function deleteCalibrationSynchronous(calibration:Calibration):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var deleteRequest:SQLStatement = new SQLStatement();
				deleteRequest.sqlConnection = conn;
				deleteRequest.text = "DELETE from calibration where calibrationid = " + "'" + calibration.uniqueId + "'";
				deleteRequest.execute();
				conn.commit();
			} catch (error:SQLError) {
				dispatchInformation('error_while_deleting_calibration_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * updates a calibration in the database<br>
		 * dispatches info if anything goes wrong 
		 */
		public static function updateCalibrationSynchronous(calibration:Calibration):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var updateRequest:SQLStatement = new SQLStatement();
				updateRequest.sqlConnection = conn;
				updateRequest.text = "UPDATE calibration SET " +
					"lastmodifiedtimestamp = " + calibration.lastModifiedTimestamp + ", " + 
					"timestamp = " + calibration.timestamp + ", " + 
					"sensorAgeAtTimeOfEstimation = " + calibration.sensorAgeAtTimeOfEstimation + ", " + 
					"sensorid = '" + calibration.sensor.uniqueId + "', " +
					"bg = " +  calibration.bg + ", " +
					"rawValue = " +  calibration.rawValue + ", " +
					"adjustedRawValue = " +  calibration.adjustedRawValue + ", " +
					"sensorConfidence = " +  calibration.sensorConfidence + ", " +
					"slopeConfidence = " +  calibration.slopeConfidence + ", " +
					"rawTimestamp = " +  calibration.rawTimestamp + ", " +
					"slope = " +  calibration.slope + ", " +
					"intercept = " +  calibration.intercept + ", " +
					"distanceFromEstimate = " +  calibration.distanceFromEstimate + ", " +
					"estimateRawAtTimeOfCalibration = " +  calibration.estimateRawAtTimeOfCalibration + ", " +
					"estimateBgAtTimeOfCalibration = " +  calibration.estimateBgAtTimeOfCalibration + ", " +
					"possibleBad = " +  calibration.possibleBad? "1":"0" + ", " +
					"checkIn = " + calibration.checkIn? "1":"0" + ", " +
					"firstDecay = " +  calibration.firstDecay + ", " +
					"secondDecay = " +  calibration.secondDecay + ", " +
					"firstSlope = " +  calibration.firstSlope + ", " +
					"secondSlope = " +  calibration.secondSlope + ", " +
					"firstIntercept = " + calibration. firstIntercept + ", " +
					"secondIntercept = " +  calibration.secondIntercept + ", " +
					"firstScale = " +  calibration.firstScale + ", " +
					"secondScale = " +  calibration.secondScale + ", " +
					"WHERE calibrationid = " + "'" + calibration.uniqueId + "'";
			} catch (error:SQLError) {
				dispatchInformation('error_while_updating_calibration_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * get calibration for specified uniqueId<br>
		 * synchronous
		 */
		public static function getCalibration(uniqueId:String):Calibration {
			var returnValue:Calibration;
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.READ);
				conn.begin();
				var getRequest:SQLStatement = new SQLStatement();
				getRequest.sqlConnection = conn;
				getRequest.text = "SELECT FROM calibration WHERE calibrationid = '" + uniqueId + "'";
				getRequest.execute();
				var result:SQLResult = getRequest.getResult();
				var numResults:int = result.data.length;
				if (numResults == 1) {
					returnValue = new Calibration(
						result.data[0].timestamp,
						result.data[0].sensorAgeAtTimeOfEstimation,
						getSensor(result.data[0].sensorid),
						result.data[0].bg,
						result.data[0].rawValue,
						result.data[0].adjustedRawValue,
						result.data[0].sensorConfidence,
						result.data[0].slopeConfidence,
						result.data[0].rawTimestamp,
						result.data[0].slope,
						result.data[0].intercept,
						result.data[0].distanceFromEstimate,
						result.data[0].estimateRawAtTimeOfCalibration,
						result.data[0].estimateBgAtTimeOfCalibration,
						result.data[0].possibleBad == "1" ? true:false,
						result.data[0].checkIn == "1" ? true:false,
						result.data[0].firstDecay,
						result.data[0].secondDecay,
						result.data[0].firstSlope,
						result.data[0].secondSlope,
						result.data[0].firstIntercept,
						result.data[0].secondIntercept,
						result.data[0].firstScale,
						result.data[0].secondScale,
						result.data[0].lastmodifiedtimestamp,
						result.data[0].calibrationid
					)
				} else {
					dispatchInformation('error_while_getting_calibration_in_db','resulting amount of calibrations should be 1 but is ' + numResults);
				}
			} catch (error:SQLError) {
				dispatchInformation('error_while_getting_calibration_in_db', error.details);
			} catch (other:Error) {
				dispatchInformation('error_while_getting_calibration_in_db', other.getStackTrace().toString());
			} finally {
				return returnValue;
			}
		}

		/**
		 * get calibration for specified sensorId<br>
		 * if there's no calibration for the specified sensorId then the returnvalue is an empty arraycollection<br>
		 * the calibrations will be order in descending order by timestamp<br>
		 * synchronous
		 */
		public static function getCalibrationForSensorId(sensorId:String):ArrayCollection {
			var returnValue:ArrayCollection = new ArrayCollection();
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.READ);
				conn.begin();
				var getRequest:SQLStatement = new SQLStatement();
				getRequest.sqlConnection = conn;
				getRequest.text = "SELECT FROM calibration WHERE sensorid = '" + sensorId + "'";
				getRequest.execute();
				var result:SQLResult = getRequest.getResult();
				var numResults:int = result.data.length;
				for (var i:int = 0; i < numResults; i++) 
				{ 
					returnValue.addItem(new Calibration(
						result.data[i].timestamp,
						result.data[i].sensorAgeAtTimeOfEstimation,
						getSensor(result.data[i].sensorid),
						result.data[i].bg,
						result.data[i].rawValue,
						result.data[i].adjustedRawValue,
						result.data[i].sensorConfidence,
						result.data[i].slopeConfidence,
						result.data[i].rawTimestamp,
						result.data[i].slope,
						result.data[i].intercept,
						result.data[i].distanceFromEstimate,
						result.data[i].estimateRawAtTimeOfCalibration,
						result.data[i].estimateBgAtTimeOfCalibration,
						result.data[i].possibleBad == "1" ? true:false,
						result.data[i].checkIn == "1" ? true:false,
						result.data[i].firstDecay,
						result.data[i].secondDecay,
						result.data[i].firstSlope,
						result.data[i].secondSlope,
						result.data[i].firstIntercept,
						result.data[i].secondIntercept,
						result.data[i].firstScale,
						result.data[i].secondScale,
						result.data[i].lastmodifiedtimestamp,
						result.data[i].calibrationid
					));
				} 
			} catch (error:SQLError) {
				dispatchInformation('error_while_getting_calibration_in_db', error.details);
			} catch (other:Error) {
				dispatchInformation('error_while_getting_calibration_in_db', other.getStackTrace().toString());
			} finally {
				
				return returnValue;
			}
		}
		
		
		/**
		 * inserts a sensor in the database<br>
		 * dispatches info if anything goes wrong 
		 */
		public static function insertSensor(sensor:Sensor):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var insertRequest:SQLStatement = new SQLStatement();
				insertRequest.sqlConnection = conn;
				insertRequest.text = "INSERT INTO sensor (" +
					"sensorid, " +
					"lastmodifiedtimestamp, " +
					"startedat," +
					"stoppedat," +
					"latestbatterylevel" +
					")" +
					"VALUES ('" + sensor.uniqueId + "', " +
					sensor.lastModifiedTimestamp.toString() + ", " +
					sensor.startedAt + ", " +
					sensor.stoppedAt + ", " +
					sensor.latestBatteryLevel + 
					")";
				insertRequest.execute();
				conn.commit();
			} catch (error:SQLError) {
				dispatchInformation('error_while_inserting_sensor_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * deletes a sensor in the database<br>
		 * dispatches info if anything goes wrong 
		 */
		public static function deleteSensor(sensor:Sensor):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var deleteRequest:SQLStatement = new SQLStatement();
				deleteRequest.sqlConnection = conn;
				deleteRequest.text = "DELETE from sensor where sensorid = " + "'" + sensor.uniqueId + "'";
				deleteRequest.execute();
				conn.commit();
			} catch (error:SQLError) {
				dispatchInformation('error_while_deleting_sensor_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * updates a sensor in the database<br>
		 * dispatches info if anything goes wrong 
		 */
		public static function updateSensor(sensor:Sensor):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var updateRequest:SQLStatement = new SQLStatement();
				updateRequest.sqlConnection = conn;
				updateRequest.text = "UPDATE sensor SET " +
					"lastmodifiedtimestamp = " + sensor.lastModifiedTimestamp.toString() + ", " + 
					"startedat = " + sensor.startedAt + ", " + 
					"stoppedat = " + sensor.stoppedAt + ", " + 
					"latestbatterylevel = " + sensor.latestBatteryLevel + ", " +
					"WHERE sensorid = " + "'" + sensor.uniqueId + "'";
			} catch (error:SQLError) {
				dispatchInformation('error_while_updating_sensor_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * get sensor for specified uniqueId<br>
		 * synchronous
		 */
		public static function getSensor(uniqueId:String):Sensor {
			var returnValue:Sensor;
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.READ);
				conn.begin();
				var getRequest:SQLStatement = new SQLStatement();
				getRequest.sqlConnection = conn;
				getRequest.text = "SELECT FROM sensor WHERE sensorid = '" + uniqueId + "'";
				getRequest.execute();
				var result:SQLResult = getRequest.getResult();
				var numResults:int = result.data.length;
				if (numResults == 1) {
					returnValue = new Sensor(
						result.data[0].startedat,
						result.data[0].stoppedat,
						result.data[0].latestbatterylevel,
						result.data[0].sensorid,
						result.data[0].lastmodifiedtimestamp
					)
				} else {
					dispatchInformation('error_while_getting_sensor_in_db','resulting amount of sensors should be 1 but is ' + numResults);
				}
			} catch (error:SQLError) {
				dispatchInformation('error_while_getting_sensor_in_db', error.details);
			} catch (other:Error) {
				dispatchInformation('error_while_getting_sensor_in_db', other.getStackTrace().toString());
			} finally {
				return returnValue;
			}
		}
		
		/**
		 * inserts a bgreading in the database<br>
		 * synchronous<br>
		 * dispatches info if anything goes wrong 
		 */
		public static function insertBgReadingSynchronous(bgreading:BgReading):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var insertRequest:SQLStatement = new SQLStatement();
				insertRequest.sqlConnection = conn;
				insertRequest.text = "INSERT INTO bgreading (" +
					"bgreadingid, " +
					"lastmodifiedtimestamp, " +
					"timestamp," +
					"sensorid," +
					"calibrationid," +
					"rawData," +
					"filteredData," +
					"ageAdjustedRawValue," +
					"calibrationFlag," +
					"calculatedValue," +
					"filteredCalculatedValue," +
					"calculatedValueSlope," +
					"a," +
					"b," +
					"c," +
					"ra," +
					"rb" +
					"rc," +
					"rawCalculated," +
					"hideSlope," +
					"noise) " +
					"VALUES ('" + bgreading.uniqueId + "', " +
					bgreading.lastModifiedTimestamp.toString() + ", " +
					bgreading.timestamp + ", " +
					"'" + bgreading.sensor.uniqueId +"', '" + 
					bgreading.calibration.uniqueId +"', " + 
					bgreading.rawData +", " + 
					bgreading.filteredData +", " + 
					bgreading.ageAdjustedRawValue +", " + 
					bgreading.calibrationFlag ? "1":"0" +", " +
					bgreading.calculatedValue +", " +
					bgreading.filteredCalculatedValue +", " +
					bgreading.calculatedValueSlope +", " +
					bgreading.a +", " +
					bgreading.b +", " +
					bgreading.c +", " +
					bgreading.ra +", " +
					bgreading.rb +", " +
					bgreading.rc +", " +
					bgreading.rawCalculated +", " +
					bgreading.hideSlope +", " +
					"'" + bgreading.noise + "'" + ")";
				insertRequest.execute();
				conn.commit();
			} catch (error:SQLError) {
				dispatchInformation('error_while_inserting_bgreading_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * deletes a bgreading in the database<br>
		 * dispatches info if anything goes wrong 
		 */
		public static function deleteBgReadingSynchronous(bgreading:BgReading):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var deleteRequest:SQLStatement = new SQLStatement();
				deleteRequest.sqlConnection = conn;
				deleteRequest.text = "DELETE from bgreading where bgreadingid = " + "'" + bgreading.uniqueId + "'";
				deleteRequest.execute();
				conn.commit();
			} catch (error:SQLError) {
				dispatchInformation('error_while_deleting_bgreading_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * updates a calibration in the database<br>
		 * dispatches info if anything goes wrong<br>
		 * synchronous
		 */
		public static function updateBgReadingSynchronous(bgreading:BgReading):void {
			try {
				var conn:SQLConnection = new SQLConnection();
				conn.open(dbFile, SQLMode.UPDATE);
				conn.begin();
				var updateRequest:SQLStatement = new SQLStatement();
				updateRequest.sqlConnection = conn;
				updateRequest.text = "UPDATE bgreading SET " +
					"lastmodifiedtimestamp = " + bgreading.lastModifiedTimestamp.toString() + ", " + 
					"timestamp = " + bgreading.timestamp + ", " + 
					"sensorid = '" +  bgreading.sensor.uniqueId + "', " +
					"calibrationid = " +  "'" + bgreading.calibration.uniqueId + "'" + ", " +
					"rawData = " +  bgreading.rawData + ", " +
					"filteredData = " +  bgreading.filteredData + ", " +
					"ageAdjustedRawValue = " +  bgreading.ageAdjustedRawValue + ", " +
					"calibrationFlag = " +  bgreading.calibrationFlag + ", " +
					"calculatedValue = " +  bgreading.calculatedValue + ", " +
					"filteredCalculatedValue = " +  bgreading.filteredCalculatedValue + ", " +
					"calculatedValueSlope = " +  bgreading.calculatedValueSlope + ", " +
					"a = " +  bgreading.a + ", " +
					"b = " +  bgreading.b + ", " +
					"c = " +  bgreading.c + ", " +
					"ra = " +  bgreading.ra + ", " +
					"rb = " + bgreading.rb + ", " +
					"rc = " +  bgreading.rc + ", " +
					"rawCalculated = " +  bgreading.rawCalculated + ", " +
					"hideSlope = " +  bgreading.hideSlope + ", " +
					"noise = " +  "'" + bgreading.noise + "'" + ", " +
					"WHERE bgreadingid = " + "'" + bgreading.uniqueId + "'" ;
			} catch (error:SQLError) {
				dispatchInformation('error_while_updating_bgreading_in_db', error.details);
				conn.rollback();
			}
		}
		
		/**
		 * updates a calibration in the database<br>
		 * if lastmodifiedtimestamp is Number.NaN then it will be assigned actual time<br>
		 * dispatches info if anything goes wrong<br>
		 * asynchronous
		 */
		public static function updateBgReadingAsynchronous(bgreading:BgReading):void {
			var localSqlStatement:SQLStatement = new SQLStatement();
			var localdispatcher:EventDispatcher = new EventDispatcher();
			
			localdispatcher.addEventListener(SQLEvent.RESULT,onOpenResult);
			localdispatcher.addEventListener(SQLErrorEvent.ERROR,onOpenError);
			
			if (openSQLConnection(localdispatcher))
				onOpenResult(null);
			
			function onOpenResult(se:SQLEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				localSqlStatement.addEventListener(SQLEvent.RESULT,bgReadingUpdated);
				localSqlStatement.addEventListener(SQLErrorEvent.ERROR,bgReadingUpdateFailed);
				localSqlStatement.sqlConnection = aConn;
				localSqlStatement.text = "UPDATE bgreading SET " +
					"lastmodifiedtimestamp = " + bgreading.lastModifiedTimestamp.toString() + ", " + 
					"timestamp = " + bgreading.timestamp + ", " + 
					"sensorid = '" +  bgreading.sensor.uniqueId + "', " +
					"calibrationid = " +  "'" + bgreading.calibration.uniqueId + "'" + ", " +
					"rawData = " +  bgreading.rawData + ", " +
					"filteredData = " +  bgreading.filteredData + ", " +
					"ageAdjustedRawValue = " +  bgreading.ageAdjustedRawValue + ", " +
					"calibrationFlag = " +  bgreading.calibrationFlag + ", " +
					"calculatedValue = " +  bgreading.calculatedValue + ", " +
					"filteredCalculatedValue = " +  bgreading.filteredCalculatedValue + ", " +
					"calculatedValueSlope = " +  bgreading.calculatedValueSlope + ", " +
					"a = " +  bgreading.a + ", " +
					"b = " +  bgreading.b + ", " +
					"c = " +  bgreading.c + ", " +
					"ra = " +  bgreading.ra + ", " +
					"rb = " + bgreading.rb + ", " +
					"rc = " +  bgreading.rc + ", " +
					"rawCalculated = " +  bgreading.rawCalculated + ", " +
					"hideSlope = " +  bgreading.hideSlope + ", " +
					"noise = " +  "'" + bgreading.noise + "'" + ", " +
					"WHERE bgreadingid = " + "'" + bgreading.uniqueId + "'" ;
				localSqlStatement.execute();
			}
			
			function bgReadingUpdated(se:SQLEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,bgReadingUpdated);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,bgReadingUpdateFailed);
			}
			
			function bgReadingUpdateFailed(see:SQLErrorEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,bgReadingUpdated);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,bgReadingUpdateFailed);
				dispatchInformation('error_while_updating_bgreading_in_database', see != null ? see.error.details:null);
			}
			
			function onOpenError(see:SQLErrorEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				dispatchInformation('error_while_updating_bgreading_in_database', see != null ? see.error.details:null);
			}
		}

		/**
		 * will get the bgreadings and dispatch them one by one (ie one event per bgreading) in the data field of a Database Event<br>
		 * If the last string is sent, an additional event is set with data = "END_OF_RESULT"<br>
		 * asynchronous
		 */
		public static function getBgReadings(dispatcher:EventDispatcher):void {
			var localSqlStatement:SQLStatement = new SQLStatement();
			var localdispatcher:EventDispatcher = new EventDispatcher();
			
			localdispatcher.addEventListener(SQLEvent.RESULT,onOpenResult);
			localdispatcher.addEventListener(SQLErrorEvent.ERROR,onOpenError);
			
			if (openSQLConnection(localdispatcher))
				onOpenResult(null);
			
			function onOpenResult(se:SQLEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				localSqlStatement.addEventListener(SQLEvent.RESULT,bgReadingsRetrieved);
				localSqlStatement.addEventListener(SQLErrorEvent.ERROR,bgreadingRetrievalFailed);
				localSqlStatement.sqlConnection = aConn;
				localSqlStatement.text =  "SELECT * from bgreading";
				localSqlStatement.execute();
			}
			
			function bgReadingsRetrieved(se:SQLEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,bgReadingsRetrieved);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,bgreadingRetrievalFailed);
				var tempObject:Object = localSqlStatement.getResult().data;
				if (tempObject != null) {
					if (tempObject is Array) {
						for each ( var o:Object in tempObject) {
							var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
							event.data = new BgReading(
								o.timestamp,
								getSensor(o.sensorid),
								getCalibration(o.calibrationid),
								o.rawData,
								o.filteredData,
								o.ageAdjustedRawValue,
								o.calibrationFlag == "1" ? true:false,
								o.calculatedValue,
								o.filteredCalculatedValue,
								o.calculatedValeSlopoe,
								o.a,
								o.b,
								o.c,
								o.ra,
								o.rb,
								o.rc,
								o.rawCalculated,
								o.hideSlope == "1" ? true:false,
								o.noise,
								o.lastmodifiedtimestamp,
								o.bgreadingid);
							dispatcher.dispatchEvent(event);
						}
					}
				} else {
					//no need to dispatch anything, there are no bgreadings
				}
				var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.RESULT_EVENT);
				event.data = END_OF_RESULT;
				dispatcher.dispatchEvent(event);
			}
			
			function bgreadingRetrievalFailed(see:SQLErrorEvent):void {
				localSqlStatement.removeEventListener(SQLEvent.RESULT,bgReadingsRetrieved);
				localSqlStatement.removeEventListener(SQLErrorEvent.ERROR,bgreadingRetrievalFailed);
				trace("Database.as : Failed to retrieve bgreadings. Database 0032");
				var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
				errorEvent.data = "Failed to retrieve bgreadings . Database:0032";
				dispatcher.dispatchEvent(errorEvent);
			}
			
			function onOpenError(see:SQLErrorEvent):void {
				localdispatcher.removeEventListener(SQLEvent.RESULT,onOpenResult);
				localdispatcher.removeEventListener(SQLErrorEvent.ERROR,onOpenError);
				trace("Database.as : Failed to open the database. Database 0033");
				if (dispatcher != null) {
					var event:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					dispatcher.dispatchEvent(event);
				}
			}
		}
		
		/**
		 * if aconn is not open then open aconn to dbFile , in asynchronous mode, in UPDATE mode<br>
		 * returns true if aconn is open<br>
		 * if aconn is closed then connection will be opened asynchronous mode and an event will be dispatched to the dispatcher after opening the connecion<br>
		 * so that means if openSQLConnection returns true then there's no need to wait for the dispatcher event to trigger. <br>
		 */ 
		private static function openSQLConnection(dispatcher:EventDispatcher):Boolean {
			if (aConn != null && aConn.connected) { 
				return true;
			} else {
				aConn = new SQLConnection();
				aConn.addEventListener(SQLEvent.OPEN, onConnOpen);
				aConn.addEventListener(SQLErrorEvent.ERROR, onConnError);
				aConn.openAsync(dbFile, SQLMode.UPDATE);
			}
			
			return false;
			
			function onConnOpen(se:SQLEvent):void
			{
				trace("Database.as : SQL Connection successfully opened in method Database.openSQLConnection");
				aConn.removeEventListener(SQLEvent.OPEN, onConnOpen);
				aConn.removeEventListener(SQLErrorEvent.ERROR, onConnError);	
				if (dispatcher != null) {
					dispatcher.dispatchEvent(new DatabaseEvent(DatabaseEvent.RESULT_EVENT));
				}
			}
			
			function onConnError(see:SQLErrorEvent):void
			{
				trace("Database.as : SQL Error while attempting to open database in method Database.openSQLConnection");
				aConn.removeEventListener(SQLEvent.OPEN, onConnOpen);
				aConn.removeEventListener(SQLErrorEvent.ERROR, onConnError);
				if (dispatcher != null) {
					dispatcher.dispatchEvent(new DatabaseEvent(DatabaseEvent.ERROR_EVENT));
				}
			}
		}
		
		/**
		 * informationResourceName will look up the text in local/database.properties<br>
		 * additionalInfo will be added after a dash, if not null
		 */
		private static function dispatchInformation(informationResourceName:String, additionalInfo:String = null):void {
			databaseInformationEvent = new DatabaseEvent(DatabaseEvent.DATABASE_INFORMATION_EVENT);
			databaseInformationEvent.data = new Object();
			databaseInformationEvent.data.information = ModelLocator.resourceManagerInstance.getString('database',informationResourceName + additionalInfo == null ? "":" - " + additionalInfo);
			instance.dispatchEvent(databaseInformationEvent);
		}
	}
}