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
		//Actual Database error : 0008
		private static var instance:Database = new Database();

		public static var aConn:SQLConnection;		
		private static var sqlStatement:SQLStatement;
		private static var globalDispatcher:EventDispatcher;
		private static var sampleDatabaseFileName:String;
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
			"bluetoothdevice_id STRING PRIMARY KEY, " + //unique id, used in all tables that will use Google Sync
			"name STRING, " +
			"address STRING, " +
			"connected BOOLEAN" +
			"lastmodifiedtimestamp TIMESTAMP NOT NULL)";
		
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
		 * If that fails, it means the database is not existing yet. Then an attempt is made to copy a sample from the assets, the database name searched will be
		 * language dependent. 
		 * 
		 * Independent of the result of the attempt to open the database and to copy from the assets, all tables will be created (if not existing yet).<br>
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
				createBlueToothDeviceStatusTable();
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
		
		private static function createBlueToothDeviceStatusTable():void {
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
					errorEvent.data = "Failed to create BlueToothDeviceStatus table. Database:0008";
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
			
			sampleDatabaseFileName = "xdripreader-sample.db";
			
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
		


	}
}