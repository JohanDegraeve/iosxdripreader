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
package model
{
	import flash.events.EventDispatcher;
	import flash.system.Capabilities;
	
	import mx.collections.ArrayCollection;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	import spark.formatters.DateTimeFormatter;
	
	import Utilities.UniqueId;
	
	import databaseclasses.BgReading;
	import databaseclasses.Database;
	import databaseclasses.DatabaseEvent;
	
	import events.BlueToothServiceEvent;
	import services.BluetoothService;

	/**
	 * holds arraylist needed for displaying etc, like bgreadings of last 24 hours, loggings, .. 
	 */
	public class ModelLocator extends EventDispatcher
	{
		private static var _instance:ModelLocator = new ModelLocator();
		private static var dateFormatter:DateTimeFormatter;


		public static function get instance():ModelLocator
		{
			return _instance;
		}

		private static var _resourceManagerInstance:IResourceManager;

		/**
		 * can be used anytime the resourcemanager is needed
		 */
		public static function get resourceManagerInstance():IResourceManager
		{
			return _resourceManagerInstance;
		}
		
		private static var _loggingList:ArrayCollection;

		[bindable]
		/**
		 * logging info dispatches by several components
		 */
		public static function get loggingList():ArrayCollection
		{
			return _loggingList;
		}
		
		private static var _bgReadings:ArrayCollection;

		/**
		 * last 24 hour bg readings<br>
		 * seperate method is there to add a bg reading, which will also there to clean up any items older dan 24 hours<br>
		 * there's no guarantee that there are no items older dan 24 hours<br>
		 */
		public static function get bgReadings():ArrayCollection
		{
			return _bgReadings;
		}

		
		public function ModelLocator()
		{
			if (_instance != null) {
				throw new Error("ModelLocator class can only be instantiated through ModelLocator.getInstance()");	
			}
			
			_resourceManagerInstance = ResourceManager.getInstance();
			
			var dataSortField:SortField= new SortField();
			dataSortField.numeric = false;
			var dataSort:Sort = new Sort();
			dataSort.fields=[dataSortField];

			_loggingList = new ArrayCollection();
			_loggingList.sort = dataSort;
			
			var localDispatcher1:EventDispatcher = new EventDispatcher();
			localDispatcher1.addEventListener(DatabaseEvent.RESULT_EVENT, logReceivedFromDatabase);
			Database.getLoggings(localDispatcher1);
			
			BluetoothService.instance.addEventListener(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT,blueToothServiceInformationReceived);
			Database.instance.addEventListener(DatabaseEvent.DATABASE_INFORMATION_EVENT, databaseInformationEventReceived);
			
			function databaseInformationEventReceived(be:DatabaseEvent):void {
				_loggingList.addItem(addTimeStamp(" DB : " + be.data.information));
				Database.insertLogging(Utilities.UniqueId.createEventId(), _loggingList.getItemAt(_loggingList.length - 1) as String, (new Date()).valueOf(),(new Date()).valueOf(),null);				
			}
			
			function blueToothServiceInformationReceived(be:BlueToothServiceEvent):void {
				_loggingList.addItem(addTimeStamp(" BT : " + be.data.information));
				Database.insertLogging(Utilities.UniqueId.createEventId(), _loggingList.getItemAt(_loggingList.length - 1) as String, (new Date()).valueOf(),(new Date()).valueOf(),null);
			}
			
			function logReceivedFromDatabase(de:DatabaseEvent):void {
				if (de.data != null)
					if (de.data is String) {
						if (de.data as String == Database.END_OF_RESULT) {
							_loggingList.refresh();
						} else {
							_loggingList.addItem(de.data as String);
						}
					}
			}
			
			//bgreadings arraycollectin, only last 24 hours should be stored
			_bgReadings = new ArrayCollection();
			var dataSortFieldForBGReadings:SortField = new SortField();
			dataSortFieldForBGReadings.name = "timestamp";
			dataSortFieldForBGReadings.numeric = true;
			dataSortFieldForBGReadings.descending = false;//ie ascending = from small to large
			var dataSortForBGReadings:Sort = new Sort();
			dataSortForBGReadings.fields=[dataSortFieldForBGReadings];
			_bgReadings.sort = dataSortForBGReadings;
			var localDispatcher2:EventDispatcher = new EventDispatcher();
			localDispatcher2.addEventListener(DatabaseEvent.RESULT_EVENT, bgReadingsReceivedFromDatabase);
			Database.getBgReadings(localDispatcher2);
			
			function bgReadingsReceivedFromDatabase(de:DatabaseEvent):void {
				if (de.data != null)
					if (de.data is BgReading) {
						_bgReadings.addItem(de.data);
					} else if (de.data is String) {
						if (de.data as String == Database.END_OF_RESULT) {
							_bgReadings.refresh();
						}
					}
			}
		}
		
		private static function addTimeStamp(source:String):String {
			if (dateFormatter == null) {
				dateFormatter = new DateTimeFormatter();
				dateFormatter.dateTimePattern = ModelLocator.resourceManagerInstance.getString('general','datetimepatternforlogginginfo');
				dateFormatter.useUTC = false;
				dateFormatter.setStyle("locale",Capabilities.language.substr(0,2));
			}
			
			var returnValue:String = dateFormatter.format((new Date())) + " " + source;
			return returnValue;
		}
		
		public static function addBGReading(bgReading:BgReading):void {
			_bgReadings.addItem(bgReading);
			_bgReadings.refresh();
			var firstBGReading:BgReading = _bgReadings.getItemAt(0) as BgReading;
			var now:Number = (new Date()).valueOf();
			while (now - firstBGReading.timestamp > 24 * 3600 * 1000) {
				_bgReadings.removeItemAt(0);
				if (_bgReadings.length == 0)
					break;
				firstBGReading = _bgReadings.getItemAt(0) as BgReading;
			}
		}
		
	}
}