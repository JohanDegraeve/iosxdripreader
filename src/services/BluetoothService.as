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
package services
{
	import com.distriqt.extension.bluetoothle.BluetoothLE;
	import com.distriqt.extension.bluetoothle.BluetoothLEState;
	import com.distriqt.extension.bluetoothle.events.BluetoothLEEvent;
	import com.distriqt.extension.bluetoothle.events.CharacteristicEvent;
	import com.distriqt.extension.bluetoothle.events.PeripheralEvent;
	import com.distriqt.extension.bluetoothle.objects.Characteristic;
	import com.distriqt.extension.bluetoothle.objects.Peripheral;
	import com.distriqt.extension.bluetoothle.objects.Service;
	
	import flash.events.EventDispatcher;
	
	import Utilities.HM10Attributes;
	
	import databaseclasses.BlueToothDevice;
	import databaseclasses.Database;
	import databaseclasses.DatabaseEvent;
	
	import model.ModelLocator;
	
	public class BluetoothService
	{
		[ResourceBundle("secrets")]
		
		private static var instance:BluetoothService = new BluetoothService();
		
		private static var _activeBluetoothPeripheral:Peripheral;
		
		private static function set activeBluetoothPeripheral(value:Peripheral):void
		{
			_activeBluetoothPeripheral = value;
			if (value != null) {
				_activeBluetoothPeripheral.addEventListener(PeripheralEvent.DISCOVER_SERVICES, peripheral_discoverServicesHandler );
				_activeBluetoothPeripheral.addEventListener(PeripheralEvent.DISCOVER_CHARACTERISTICS, peripheral_discoverCharacteristicsHandler );
				_activeBluetoothPeripheral.addEventListener(CharacteristicEvent.UPDATE, peripheral_characteristic_updatedHandler);
				_activeBluetoothPeripheral.addEventListener(CharacteristicEvent.UPDATE_ERROR, peripheral_characteristic_errorHandler);
				_activeBluetoothPeripheral.addEventListener(CharacteristicEvent.SUBSCRIBE, peripheral_characteristic_subscribeHandler);
				_activeBluetoothPeripheral.addEventListener(CharacteristicEvent.SUBSCRIBE_ERROR, peripheral_characteristic_subscribeErrorHandler);
				_activeBluetoothPeripheral.addEventListener(CharacteristicEvent.UNSUBSCRIBE, peripheral_characteristic_unsubscribeHandler);
			}
		}
		
		private static function get activeBluetoothPeripheral():Peripheral {
			return _activeBluetoothPeripheral;
		}
		
		private static var _characteristic:Characteristic;
		
		private static function get characteristic():Characteristic
		{
			return _characteristic;
		}
		
		private static function set characteristic(value:Characteristic):void
		{
			_characteristic = value;
		}
		
		public function BluetoothService()
		{
			if (instance != null) {
				throw new Error("BluetoothService class  constructor can not be used");	
			}
		}
		
		/**
		 * start all bluetooth related activity : scanning, connecting, start listening ...<br>
		 * Also intializes BlueToothDevice with values retrieved from Database. 
		 */
		public static function init():void {
			BluetoothLE.init(ModelLocator.resourceManagerInstance.getString('secrets','distriqt-key'));
			if (BluetoothLE.isSupported) {
				trace("BluetoothService.as : bluetoothle is supported");
				BluetoothLE.service.centralManager.addEventListener(PeripheralEvent.DISCOVERED, central_peripheralDiscoveredHandler);
				BluetoothLE.service.centralManager.addEventListener( PeripheralEvent.CONNECT, central_peripheralConnectHandler );
				BluetoothLE.service.centralManager.addEventListener( PeripheralEvent.CONNECT_FAIL, central_peripheralConnectFailHandler );
				BluetoothLE.service.centralManager.addEventListener( PeripheralEvent.DISCONNECT, central_peripheralDisconnectHandler );
				
				//first of all get the device name and address from database and store it
				var dispatcher:EventDispatcher = new EventDispatcher();
				dispatcher.addEventListener(DatabaseEvent.RESULT_EVENT,blueToothDeviceRetrieved);
				dispatcher.addEventListener(DatabaseEvent.ERROR_EVENT,blueToothDeviceRetrievalError);
				Database.getBlueToothDevice(dispatcher);
				
				function blueToothDeviceRetrieved (event:DatabaseEvent):void {
					BlueToothDevice.address = event.data.address;
					BlueToothDevice.name = event.data.name;
					BlueToothDevice.instance.lastModifiedTimestamp = event.data.lastmodifiedtimestamp;
					
					//set an eventlistener for state changes
					BluetoothLE.service.addEventListener(BluetoothLEEvent.STATE_CHANGED, bluetoothStateChangedHandler);
					
					//what's the actual status ?
					switch (BluetoothLE.service.state)
					{
						case BluetoothLEState.STATE_ON:	
							// We can use the Bluetooth LE functions
							bluetoothStatusIsOn();
							break;
						case BluetoothLEState.STATE_OFF:
						case BluetoothLEState.STATE_RESETTING:	
						case BluetoothLEState.STATE_UNAUTHORISED:	
						case BluetoothLEState.STATE_UNSUPPORTED:	
						case BluetoothLEState.STATE_UNKNOWN:
					}
					
				}
				
				function blueToothDeviceRetrievalError (event:DatabaseEvent):void {
					//shouldn't happen, not really 
					trace("BluetoothService.as : BluetoothService.as : Failed retrieving bluetoothdevice");
				}
			} else {
				trace("BluetoothService.as : bluetoothle is not supported - no further action to take");
			}
		}
		
		private static function bluetoothStateChangedHandler(event:BluetoothLEEvent):void
		{
			trace("BluetoothService.as : bluetoothStateChangedHandler (): " + BluetoothLE.service.state);
			//TODO : inform the user when bluetooth connection is lost ? or just change an indication field ?
			//probably in any case listen for STATE_ON, because probably that's where we need to start doing other things
			//what's the actual status ?
			switch (BluetoothLE.service.state)
			{
				case BluetoothLEState.STATE_ON:	
					// We can use the Bluetooth LE functions
					bluetoothStatusIsOn();
					break;
				case BluetoothLEState.STATE_OFF:
				case BluetoothLEState.STATE_RESETTING:	
				case BluetoothLEState.STATE_UNAUTHORISED:	
				case BluetoothLEState.STATE_UNSUPPORTED:	
				case BluetoothLEState.STATE_UNKNOWN:
			}
		}
		
		/** the plan is, as soon as we see that the bluetooth status is on<br>
		 * &nbsp&nbsp (this may happen the first time that this class is instantiated, means it's instantiated while bluetooth is on<br>
		 * &nbsp&nbsp or bluetooth was off before, while the app was running already, and it changed to on) <br>
		 * Then scan for peripherals. If no peripheral name stored yet, then we'll try to connect to the first xdrip or xbridge<br>
		 * If bluetoothle peripheral name stored, then connect to that one <br>
		 * 
		 * TO DO : NOT SURE ACTUALLY IF THE DEVICE WILL AUTOMATICALLY CONNECT TO A PERIPHERAL THAT WAS ALREADY KNOWN BEFORE
		 */
		private static function bluetoothStatusIsOn():void {
			var uuids:Vector.<String> = new <String>[HM10Attributes.HM_10_SERVICE];
			
			if (!BluetoothLE.service.centralManager.scanForPeripherals(uuids))
			{
				trace("BluetoothService.as : BluetoothService.bluetoothStatusIsOn : error while trying to scan for peripherals");
				//TODO handle this error
				return;
			}
		}
		
		private static function central_peripheralDiscoveredHandler(event:PeripheralEvent):void
		{
			// event.peripheral will contain a Peripheral object with information about the Peripheral
			trace("BluetoothService.as : peripheral discovered: "+ event.peripheral.name);
			if ((event.peripheral.name as String).toUpperCase() == "XDRIP" || (event.peripheral.name as String).toUpperCase() == "XBRIDGE") {//not sure if xbridge is ever used, i think it's always xdrip
				//here we should check if BlueToothDevice.address != "", then theck if BlueToothDevice.address matches the address of the scanned device, if not don't continue
				//but we don't get the address of the scanned device, so continue
				
				trace("BluetoothService.as : connecting to peripheral : " + event.peripheral.name);
				BluetoothLE.service.centralManager.connect(event.peripheral);
			}
		}
		
		private static function central_peripheralConnectHandler(event:PeripheralEvent):void {
			trace("BluetoothService.as : connected to peripheral : " + event.peripheral.name);
			activeBluetoothPeripheral = event.peripheral;
			var uuids:Vector.<String> = new <String>[HM10Attributes.HM_10_SERVICE];
			activeBluetoothPeripheral.discoverServices(uuids);
		}
		
		private static function central_peripheralConnectFailHandler(event:PeripheralEvent):void {
			trace("BluetoothService.as : connection failed  : " + event.peripheral.name);
			activeBluetoothPeripheral = null;
		}
		
		private static function central_peripheralDisconnectHandler(event:PeripheralEvent):void {
			trace("BluetoothService.as : disconnected from peripheral : " + event.peripheral.name);
			activeBluetoothPeripheral = null;
		}
		
		private static function peripheral_discoverServicesHandler(event:PeripheralEvent):void {
			trace("BluetoothService.as : peripheral_discoverServicesHandler");
			if (event.peripheral.services.length > 0)
			{
				for each (var service:Service in event.peripheral.services)
				{
					trace( "service: "+ service.uuid );
				}
				activeBluetoothPeripheral = event.peripheral;
				var uuids:Vector.<String> = new <String>[HM10Attributes.HM_RX_TX];
				activeBluetoothPeripheral.discoverCharacteristics(activeBluetoothPeripheral.services[0]/*, uuids*/);
			}
		}
		
		private static function peripheral_discoverCharacteristicsHandler(event:PeripheralEvent):void {
			trace("BluetoothService.as : in peripheral_discoverCharacteristicsHandler");
			for each (var service:Service in event.peripheral.services) {
				for each (var ch:Characteristic in service.characteristics)
				{
					trace( "characteristic: "+ch.uuid );
				}
			}
			//not correct here, first go through each service and each characteristic to trace the content
			//then assume there's only one of each
			characteristic = event.peripheral.services[0].characteristics[0];
			if (!activeBluetoothPeripheral.subscribeToCharacteristic(characteristic))
			{
				// TODO error starting subscription process
			}
			//activeBluetoothPeripheral.readValueForCharacteristic(characteristic);
		}
		
		private static function peripheral_characteristic_updatedHandler(event:CharacteristicEvent):void {
			trace("BluetoothService.as : peripheral_characteristic_updatedHandler: " + event.characteristic.uuid);
			trace("BluetoothService.as : value="+ event.characteristic.value.readUTFBytes(event.characteristic.value.length));
			//Should be same as in DexCollectionService , linenumber 443
			var bytesAvailable:int = event.characteristic.value.bytesAvailable;
			var endian:String = event.characteristic.value.endian;
			var length:int = event.characteristic.value.length;
			for (var i:int = 0;i < length;i++) {
				trace("bytearray element " + i + " = " + (new Number(event.characteristic.value[i])).toString(16));
			}
			//alles zit dus in event.characteristics.value[0]
			//txid zit daar in, controleren ? best wel zeker ? 
			//processing van values zit in TransmitterData.create
		}
		
		private static function peripheral_characteristic_errorHandler(event:CharacteristicEvent):void {
			trace("BluetoothService.as : peripheral_characteristic_errorHandler: " + event.characteristic.uuid);
		}
		
		private static function peripheral_characteristic_subscribeHandler(event:CharacteristicEvent):void {
			trace("BluetoothService.as : peripheral_characteristic_subscribeHandler: " + event.characteristic.uuid);
		}
		
		private static function peripheral_characteristic_subscribeErrorHandler(event:CharacteristicEvent):void {
			trace("BluetoothService.as : peripheral_characteristic_subscribeErrorHandler: " + event.characteristic.uuid);
		}
		
		private static function peripheral_characteristic_unsubscribeHandler(event:CharacteristicEvent):void {
			trace("BluetoothService.as : peripheral_characteristic_unsubscribeHandler: " + event.characteristic.uuid);	
		}
	}
}