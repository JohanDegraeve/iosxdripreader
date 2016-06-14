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
	import flash.utils.ByteArray;
	
	import Utilities.HM10Attributes;
	
	import databaseclasses.BlueToothDevice;
	
	import model.ModelLocator;
	
	public class BluetoothService extends EventDispatcher
	{
		[ResourceBundle("secrets")]
		[ResourceBundle("bluetoothservice")]
		
		public static const BLUETOOTH_DEVICE_DISCONNECTED:String = "DEVICE_DISCONNECTED";
		public static const BLUETOOTH_DEVICE_CONNECTED:String = "DEVICE_CONNECTED";
		
		public static var instance:BluetoothService = new BluetoothService();
		
		private static var _activeBluetoothPeripheral:Peripheral;
		
		private static var initialStart:Boolean = true;
		
		private static var blueToothServiceEvent:BlueToothServiceEvent;
		
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
				throw new Error("BluetoothService class constructor can not be used");	
			}
		}
		
		/**
		 * start all bluetooth related activity : scanning, connecting, start listening ...<br>
		 * Also intializes BlueToothDevice with values retrieved from Database. 
		 */
		public static function init():void {
			if (!initialStart)
				return;
			else
				initialStart = false;
				
			BluetoothLE.init(ModelLocator.resourceManagerInstance.getString('secrets','distriqt-key'));
			if (BluetoothLE.isSupported) {
				treatNewBlueToothStatus(BluetoothLE.service.centralManager.state);	
				trace("BluetoothService.as : bluetoothle is supported");
				BluetoothLE.service.centralManager.addEventListener(PeripheralEvent.DISCOVERED, central_peripheralDiscoveredHandler);
				BluetoothLE.service.centralManager.addEventListener( PeripheralEvent.CONNECT, central_peripheralConnectHandler );
				BluetoothLE.service.centralManager.addEventListener( PeripheralEvent.CONNECT_FAIL, central_peripheralConnectFailHandler );
				BluetoothLE.service.centralManager.addEventListener( PeripheralEvent.DISCONNECT, central_peripheralDisconnectHandler );
				BluetoothLE.service.addEventListener(BluetoothLEEvent.STATE_CHANGED, bluetoothStateChangedHandler);
				switch (BluetoothLE.service.centralManager.state)
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
			} else {
				trace("BluetoothService.as : bluetoothle is not supported - no further action to take");
				blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
				blueToothServiceEvent.data = new Object();
				blueToothServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('bluetoothservice','bluetooth_not_supported');
				instance.dispatchEvent(blueToothServiceEvent);

				blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_STATUS_CHANGED_EVENT);
				blueToothServiceEvent.data = new Object();
				blueToothServiceEvent.data.status = BluetoothLEState.STATE_UNSUPPORTED;
				instance.dispatchEvent(blueToothServiceEvent);
			}
		}
		
		private static function treatNewBlueToothStatus(newStatus:String):void {
			blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_STATUS_CHANGED_EVENT);
			blueToothServiceEvent.data = new Object();
			blueToothServiceEvent.data.status = BluetoothLE.service.centralManager.state;
			instance.dispatchEvent(blueToothServiceEvent);

			switch (BluetoothLE.service.centralManager.state)
			{
				case BluetoothLEState.STATE_ON:	
					// We can use the Bluetooth LE functions
					bluetoothStatusIsOn();
					break;
				case BluetoothLEState.STATE_OFF:
					break;//does the device automatically change to connected ? 
				case BluetoothLEState.STATE_RESETTING:	
					break;
				case BluetoothLEState.STATE_UNAUTHORISED:	
					break;
				case BluetoothLEState.STATE_UNSUPPORTED:	
					break;
				case BluetoothLEState.STATE_UNKNOWN:
					break;
			}
		}
		
		private static function bluetoothStateChangedHandler(event:BluetoothLEEvent):void
		{
			trace("BluetoothService.as : bluetoothStateChangedHandler (): " + BluetoothLE.service.centralManager.state);
			treatNewBlueToothStatus(BluetoothLE.service.centralManager.state);					
		}
		
		/** the plan is, as soon as we see that the bluetooth status is on<br>
		 * &nbsp&nbsp (this may happen the first time that this class is instantiated, means it's instantiated while bluetooth is on<br>
		 * &nbsp&nbsp or bluetooth was off before, while the app was running already, and it changed to on) <br>
		 * Then scan for peripherals. If no peripheral name stored yet, then we'll try to connect to the first xdrip or xbridge<br>
		 * If bluetoothle peripheral name stored, then connect to that one <br>
		 * 
		 * TODO : NOT SURE ACTUALLY IF THE DEVICE WILL AUTOMATICALLY CONNECT TO A PERIPHERAL THAT WAS ALREADY KNOWN BEFORE
		 */
		private static function bluetoothStatusIsOn():void {
			var uuids:Vector.<String> = new <String>[HM10Attributes.HM_10_SERVICE];
			
			if (!BluetoothLE.service.centralManager.isScanning) {
				if (!BluetoothLE.service.centralManager.scanForPeripherals(uuids))
				{
					blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
					blueToothServiceEvent.data = new Object();
					blueToothServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('bluetoothservice','failed_to_start_scanning_for_peripherals');
					instance.dispatchEvent(blueToothServiceEvent);

					trace("BluetoothService.as : BluetoothService.bluetoothStatusIsOn : error while trying to scan for peripherals");
					//TODO handle this error
					return;
				} else {
					blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
					blueToothServiceEvent.data = new Object();
					blueToothServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('bluetoothservice','started_scanning_for_peripherals');
					instance.dispatchEvent(blueToothServiceEvent);
				}
			}
		}
		
		private static function central_peripheralDiscoveredHandler(event:PeripheralEvent):void
		{
			// event.peripheral will contain a Peripheral object with information about the Peripheral
			trace("BluetoothService.as : peripheral discovered: "+ event.peripheral.name);
			if ((event.peripheral.name as String).toUpperCase().indexOf("XDRIP") > -1 || (event.peripheral.name as String).toUpperCase().indexOf("XBRIDGE") > -1) {//not sure if xbridge is ever used, i think it's always xdrip
				blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
				blueToothServiceEvent.data = new Object();
				blueToothServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('bluetoothservice','found_peripheral_with_name') + " = " + event.peripheral.name;
				instance.dispatchEvent(blueToothServiceEvent);
				
				if (BlueToothDevice.address != "") {
					if (BlueToothDevice.address != event.peripheral.uuid) {
						//a bluetooth device address is already stored, but it's not the one for which peripheraldiscoveredhandler is called
						//so we ignore it
						blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
						blueToothServiceEvent.data = new Object();
						blueToothServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('bluetoothservice','stored_uuid_does_not_match');
						instance.dispatchEvent(blueToothServiceEvent);
						return;
					}
				}

				//we want to connect to this device, so stop scanning
				BluetoothLE.service.centralManager.stopScan();
				trace("BluetoothService.as : connecting to peripheral : " + event.peripheral.name);
				BluetoothLE.service.centralManager.connect(event.peripheral);
				blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
				blueToothServiceEvent.data = new Object();
				blueToothServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('bluetoothservice','stop_scanning_and_try_to_connect');
				instance.dispatchEvent(blueToothServiceEvent);
			}
		}
		
		private static function central_peripheralConnectHandler(event:PeripheralEvent):void {
			trace("BluetoothService.as : connected to peripheral : " + event.peripheral.name);
			blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
			blueToothServiceEvent.data = new Object();
			blueToothServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('bluetoothservice','connected_to_peripheral');
			instance.dispatchEvent(blueToothServiceEvent);
			BlueToothDevice.address = event.peripheral.uuid;
			BlueToothDevice.name = event.peripheral.name;
			BlueToothDevice.connected = true;
			
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
			
			BlueToothDevice.connected = false;
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
			//not really correct here, first go through each service and each characteristic to trace the content
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
			//na het uitlezen ook nog een ack message uitsturen, zie DexCollectionService.java 363
			
			//acknowledge the receipt back to the xdrip, otherwise it will keep on trying
			var value:ByteArray = new ByteArray();
			value.writeByte(0x02);
			value.writeByte(0xF0);
			
			//call back to peripheral_characteristic_writeErrorHandler seems to be not working, so commented it out
			//activeBluetoothPeripheral.addEventListener(CharacteristicEvent.WRITE_SUCCESS, peripheral_characteristic_writeHandler);
			//activeBluetoothPeripheral.addEventListener(CharacteristicEvent.WRITE_ERROR, peripheral_characteristic_writeErrorHandler);
			var success:Boolean = activeBluetoothPeripheral.writeValueForCharacteristic(characteristic, value);
			trace("BluetoothService.as : peripheral_characteristic_updatedHandler, result of call to activeBluetoothPeripheral.writeValueForCharacteristic = " + success);
		}
		
		/*private static function peripheral_characteristic_writeHandler(event:CharacteristicEvent):void {
			activeBluetoothPeripheral.removeEventListener(CharacteristicEvent.WRITE_SUCCESS, peripheral_characteristic_writeHandler);
			activeBluetoothPeripheral.removeEventListener(CharacteristicEvent.WRITE_ERROR, peripheral_characteristic_writeErrorHandler);
			trace("	BluetoothService.as : peripheral_characteristic_writeHandler");
		}
		
		private static function peripheral_characteristic_writeErrorHandler(event:CharacteristicEvent):void {
			activeBluetoothPeripheral.removeEventListener(CharacteristicEvent.WRITE_SUCCESS, peripheral_characteristic_writeHandler);
			activeBluetoothPeripheral.removeEventListener(CharacteristicEvent.WRITE_ERROR, peripheral_characteristic_writeErrorHandler);
			trace("	BluetoothService.as : peripheral_characteristic_writeErrorHandler");
		}*/
		
		private static function peripheral_characteristic_errorHandler(event:CharacteristicEvent):void {
			trace("BluetoothService.as : peripheral_characteristic_errorHandler" );
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