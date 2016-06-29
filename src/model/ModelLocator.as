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
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import spark.formatters.DateTimeFormatter;
	
	import Utilities.UniqueId;
	
	import databaseclasses.Database;
	import databaseclasses.DatabaseEvent;
	
	import services.BlueToothServiceEvent;
	import services.BluetoothService;

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
		
		public function ModelLocator()
		{
			if (_instance != null) {
				throw new Error("ModelLocator class can only be instantiated through ModelLocator.getInstance()");	
			}
			
			_resourceManagerInstance = ResourceManager.getInstance();
			
			var dataSortField:SortField = new SortField();
			dataSortField.numeric = false;
			var dataSort:Sort = new Sort();
			dataSort.fields=[dataSortField];

			_loggingList = new ArrayCollection();
			_loggingList.sort = dataSort;
			
			var localDispatcher:EventDispatcher = new EventDispatcher();
			localDispatcher.addEventListener(DatabaseEvent.RESULT_EVENT, logReceivedFromDatabase);
			Database.getLoggings(localDispatcher);
			
			BluetoothService.instance.addEventListener(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT,blueToothServiceInformationReceived);
			
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
	}
}