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
	import flash.data.SQLStatement;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	public class Database
	{
		//Actual Database error : 0013
		private static var instance:Database = new Database();
		
		public static var aConn:SQLConnection;		
		private static var sqlStatement:SQLStatement;
		private static var globalDispatcher:EventDispatcher;
		private static var sampleDatabaseFileName:String = "xdripreader-sample.db";;
		private static const dbFileName:String = "xdripreader.db";
		private  static var dbFile:File  ;
		private static var xmlFileName:String;
		private static var databaseWasCopiedFromSampleFile:Boolean = false;
		
		/**
		 * create table to store the bluetooth device name and address<br>
		 * connected status will be in seperate table<br>
		 * At most one row should be stored
		 */
		private static const CREATE_TABLE_ACTIVE_BLUETOOTH_DEVICE:String = "CREATE TABLE IF NOT EXISTS activebluetoothdevice (" +
			"bluetoothdevice_id STRING PRIMARY KEY, " + //unique id, used in all tables that will use Google Sync (note that for iOS no google sync will be done for this table because mac address is not visible in iOS. UDID is used as address but this is different for each install
			"name STRING, " +
			"address STRING, " +
			"connected BOOLEAN," +
			"lastmodifiedtimestamp TIMESTAMP NOT NULL)";
		
		private static const SELECT_ALL_BLUETOOTH_DEVICES:String = "SELECT * from activebluetoothdevice";
		private static const INSERT_DEFAULT_BLUETOOTH_DEVICE:String = "INSERT into activebluetoothdevice (bluetoothdevice_id, name, address, connected, lastmodifiedtimestamp) VALUES (:bluetoothdevice_id,:name, :address, :connected, :lastmodifiedtimestamp)";
		
		/**
		 * bluetooth device status, no device id stored here because it should at most be one.<br>
		 * Keeping seperate from BLUETOOTH_DEVICE name and address because connected status will not be Google synced
		 */
		private static const CREATE_TABLE_ACTIVE_BLUETOOTH_DEVICE_STATUS:String = "CREATE TABLE IF NOT EXISTS activebluetoothdevicestatus (" +
			"connected BOOLEAN)";
		
		
		/**
		 * constructor, should not be used
		 */
		public function Database()
		{
			if (instance != null) {
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
		 * A default bluetooth device is created if not existing yet with name "", address "", connected false, lastmodifiedtimestamp current date, id = BlueToothDevice.DEFAULT_BLUETOOTH_DEVICE_ID
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
			createBlueToothDeviceTable();				
		}
		
		private static function createBlueToothDeviceTable():void {
			sqlStatement.text = CREATE_TABLE_ACTIVE_BLUETOOTH_DEVICE;
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
					globalDispatcher = null;
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
							createBlueToothDeviceStatusTable();
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
					globalDispatcher = null;
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
			sqlStatement.parameters[":connected"] = false;
			sqlStatement.parameters[":lastmodifiedtimestamp"] = (new Date()).valueOf();
			sqlStatement.addEventListener(SQLEvent.RESULT,defaultBlueToothDeviceInserted);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR,defaultBlueToothDeviceInsetionFailed);
			sqlStatement.execute();
			
			function defaultBlueToothDeviceInserted(se:SQLEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,defaultBlueToothDeviceInserted);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,defaultBlueToothDeviceInsetionFailed);
				createBlueToothDeviceStatusTable();
			}
			
			function defaultBlueToothDeviceInsetionFailed(see:SQLErrorEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,defaultBlueToothDeviceInserted);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,defaultBlueToothDeviceInsetionFailed);
				if (globalDispatcher != null) {
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Failed to insert default bluetooth device. Database:0010 - details = " + (see.error.details == null ? "":see.error.details);
					globalDispatcher.dispatchEvent(errorEvent);
					globalDispatcher = null;
				}
			}
		}
		
		private static function createBlueToothDeviceStatusTable():void {
			sqlStatement.clearParameters();
			sqlStatement.text = CREATE_TABLE_ACTIVE_BLUETOOTH_DEVICE_STATUS;
			sqlStatement.addEventListener(SQLEvent.RESULT,tableCreated);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR,tableCreationError);
			sqlStatement.execute();
			
			function tableCreated(se:SQLEvent):void {
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				finishedCreatingTables();
			}
			
			function tableCreationError(see:SQLErrorEvent):void {
				trace("Database.as : Failed to create BlueToothDeviceStatus table. Database:0007");
				sqlStatement.removeEventListener(SQLEvent.RESULT,tableCreated);
				sqlStatement.removeEventListener(SQLErrorEvent.ERROR,tableCreationError);
				if (globalDispatcher != null) {
					var errorEvent:DatabaseEvent = new DatabaseEvent(DatabaseEvent.ERROR_EVENT);
					errorEvent.data = "Failed to create BlueToothDeviceStatus table. Database:0008 - details = " + (see.error.details == null ? "":see.error.details);
					globalDispatcher.dispatchEvent(errorEvent);
					globalDispatcher = null;
				}
			}
		}
		
		private static function finishedCreatingTables():void {
			if (globalDispatcher != null) {
				globalDispatcher.dispatchEvent(new Event(DatabaseEvent.RESULT_EVENT));
				globalDispatcher = null;
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
	}
}