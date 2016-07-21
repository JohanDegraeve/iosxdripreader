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
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import Utilities.HM10Attributes;
	
	import databaseclasses.BlueToothDevice;
	
	import events.BlueToothServiceEvent;
	
	import model.ModelLocator;
	import model.TransmitterDataXBridgeBeaconPacket;
	import model.TransmitterDataXBridgeDataPacket;
	import model.TransmitterDataXdripDataPacket;
	
	/**
	 * all functionality related to bluetooth connectivity<br>
	 * init function must be called once immediately at start of the application<br>
	 * <br>
	 * to get info about connectivity status, new transmitter data ... check BluetoothServiceEvent  create listeners for the events<br>
	 * BluetoothService itself is not doing anything with the data received from the bluetoothdevice, also not checking the transmit id, it just passes the information via 
	 * dispatching<br>
	 * <br>
	 * There is also a method to update the transmitter id, however the bluetoothservice is not handling the response, it just tries to send the message to the device, no guarantee that this will succeed.
	 */
	public class BluetoothService extends EventDispatcher
	{
		
		private static var _instance:BluetoothService = new BluetoothService();
		
		[ResourceBundle("secrets")]
		[ResourceBundle("bluetoothservice")]
		public static function get instance():BluetoothService
		{
			return _instance;
		}
		
		
		private static var _activeBluetoothPeripheral:Peripheral;
		
		private static var initialStart:Boolean = true;
		
		private static var blueToothServiceEvent:BlueToothServiceEvent;
		
		private static var reconnectTimer:Timer;
		private static var reconnectTimesInSeconds:Array = [5,5,60,60,60,60,60,300,300,300,300,300,900,900,900,900,1800];
		private static var currentReconnectTimesPointer:int = 0;
		
		private static var checkReScanTimer:Timer;
		/**
		 * seconds after which new scan will be started 
		 */
		private static const rescanTimesInSeconds:Array = [60,60,60,60,60,300,300,300,300,300,900,900,900,900,1800];
		private static var currentRescanTimesPointer:int = 0;
		private static const secondsAfterWhichRunningScanWillBeStopped:int = 60;
		
		private static var testcounter:int = 0;
		
		private static var nrOfAttemptsToConnectToNewDevice:int = 0;
		private static const maxNrOfAttemptsToConnectToNewDevice:int = 5;
		private static const lengthOfDataPacket:int = 17;
		private static const srcNameTable:Array = [ '0', '1', '2', '3', '4', '5', '6', '7',
			'8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
			'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P',
			'Q', 'R', 'S', 'T', 'U', 'W', 'X', 'Y' ];
		
		private static var timeStampOfLastDataPacketReceived:Number = 0;
		
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
			if (_instance != null) {
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
				trace("passing bluetoothservice.issupported");
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
						dispatchInformation('bluetooth_is_switched_off');
						break;
					case BluetoothLEState.STATE_RESETTING:	
						break;
					case BluetoothLEState.STATE_UNAUTHORISED:
						break;
					case BluetoothLEState.STATE_UNSUPPORTED:
						break;
					case BluetoothLEState.STATE_UNKNOWN:
						break;
				}				
			} else {
				dispatchInformation('bluetooth_not_supported');
				
				blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_STATUS_CHANGED_EVENT);
				blueToothServiceEvent.data = new Object();
				blueToothServiceEvent.data.status = BluetoothLEState.STATE_UNSUPPORTED;
				_instance.dispatchEvent(blueToothServiceEvent);
				
				//var buffer:ByteArray = new ByteArray();
				/*buffer.writeByte(17);//(0x11);
				buffer.writeByte(0);//(0x00);
				buffer.writeByte(128);//(0x80);
				buffer.writeByte(179);//(0xB3);
				buffer.writeByte(1);//(0x01);
				
				buffer.writeByte(0);//(0x00);
				buffer.writeByte(240);//(0xF0);
				buffer.writeByte(208);//(0xD0);
				buffer.writeByte(1);//(0x01);
				buffer.writeByte(0);//(0x00);
				
				buffer.writeByte(215);//(0xD7);
				buffer.writeByte(0);//(0x00);
				buffer.writeByte(97);//0x61);
				buffer.writeByte(202);//(0xCA);
				buffer.writeByte(102);//(0x66);
				
				buffer.writeByte(0);//(0x00);
				buffer.writeByte(1);//(0x01);*/
				
				//f1 
				/*buffer.writeByte(0x07);//(0x07);
				buffer.writeByte(0xF1);//
				buffer.writeByte(0x61);//(0xB3);
				buffer.writeByte(0xCA);//(0x01);
				
				buffer.writeByte(0x66);//(0x00);
				buffer.writeByte(0x00);//(0xF0);
				buffer.writeByte(0x01);//(0xF0);
				
				
				
				buffer.position = 0;
				buffer.endian = Endian.LITTLE_ENDIAN;
				
				buffer.readUnsignedByte();
				buffer.readUnsignedByte();
				var txid:Number = buffer.readUnsignedInt();
				trace("txid = " + decodeTxID(txid));*/
				
				/*var DexSrc:int;
				var firstByte:int = buffer.readUnsignedByte();
				var rawData:Number;
				var filteredData:Number;
				//positin = 1
				var secondByte:int = buffer.readUnsignedByte();
				//position = 2
				if (firstByte == 7 && secondByte == -15) {
				//beacon packet
				DexSrc = buffer.readUnsignedInt();
				//position = 6	
				} else {
				if (firstByte == 17 && secondByte == 0) {
				//data packet
				if (packetLength >= lengthOfDataPacket) {
				//we're still at position 2
				rawData = buffer.readUnsignedInt();
				//position = 6
				filteredData = buffer.readUnsignedInt();
				//position = 10
				//transmitterData.sensor_battery_level = txData.get(10) & 0xff;
				}
				} else {
				//seems to be some other kind of packet
				//TODO dispatch information event
				}
				}*/
			}
		}
		
		private static function treatNewBlueToothStatus(newStatus:String):void {
			blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_STATUS_CHANGED_EVENT);
			blueToothServiceEvent.data = new Object();
			blueToothServiceEvent.data.status = BluetoothLE.service.centralManager.state;
			_instance.dispatchEvent(blueToothServiceEvent);
			
			switch (BluetoothLE.service.centralManager.state)
			{
				case BluetoothLEState.STATE_ON:	
					currentReconnectTimesPointer = 0;//for next new attempt, whenever just in case
					currentRescanTimesPointer = 0;
					dispatchInformation('bluetooth_is_switched_on');
					// We can use the Bluetooth LE functions
					bluetoothStatusIsOn();
					break;
				case BluetoothLEState.STATE_OFF:
					currentReconnectTimesPointer = 0;//for next new attempt, whenever just in case
					currentRescanTimesPointer = 0;
					dispatchInformation('bluetooth_is_switched_off');
					break;//does the device automatically change to connected ? 
				case BluetoothLEState.STATE_RESETTING:	
					currentReconnectTimesPointer = 0;//for next new attempt, whenever just in case
					currentRescanTimesPointer = 0;
					break;
				case BluetoothLEState.STATE_UNAUTHORISED:	
					currentReconnectTimesPointer = 0;//for next new attempt, whenever just in case
					currentRescanTimesPointer = 0;
					break;
				case BluetoothLEState.STATE_UNSUPPORTED:	
					break;
				case BluetoothLEState.STATE_UNKNOWN:
					currentReconnectTimesPointer = 0;//for next new attempt, whenever just in case
					currentRescanTimesPointer = 0;
					break;
			}
		}
		
		private static function bluetoothStateChangedHandler(event:BluetoothLEEvent):void
		{
			treatNewBlueToothStatus(BluetoothLE.service.centralManager.state);					
		}
		
		/** as soon as bluetooth status is on<br>
		 * &nbsp&nbsp (this may happen the first time that this class is instantiated, means it's instantiated while bluetooth is on<br>
		 * &nbsp&nbsp or bluetooth was off before, while the app was running already, and it changed to on) <br>
		 * First, if activebluetoothperipheral is already known, try to connect to it<br>
		 * If no active bluetooth peripheral known, then scan, try to connect to the first peripheral with name drip or xbridge in it (not case sensitive)<br>
		 */
		private static function bluetoothStatusIsOn():void {
			if (activeBluetoothPeripheral != null) {
				BluetoothLE.service.centralManager.connect(activeBluetoothPeripheral);
				dispatchInformation('trying_to_connect_to_known_device');
				//make sure scanning is not going on anymore, to save energy
				BluetoothLE.service.centralManager.stopScan();
			} else {
				nrOfAttemptsToConnectToNewDevice = 0;
				var uuids:Vector.<String> = new <String>[HM10Attributes.HM_10_SERVICE];
				if (!BluetoothLE.service.centralManager.isScanning) {
					if (!BluetoothLE.service.centralManager.scanForPeripherals(uuids))
					{
						dispatchInformation('failed_to_start_scanning_for_peripherals');
						return;
					} else {
						dispatchInformation('started_scanning_for_peripherals');
						setCheckScanStatusTimer(true);
					}
				} else {
					//to save energy
					BluetoothLE.service.centralManager.stopScan();
					dispatchInformation('scanning_still_running_stopped_now');
					setCheckScanStatusTimer(false);
				}
			}
		}
		
		private static function central_peripheralDiscoveredHandler(event:PeripheralEvent):void {
			trace("passing in central_peripheralDiscoveredHandler for " + testcounter++ + "-th time");
			
			// event.peripheral will contain a Peripheral object with information about the Peripheral
			if ((event.peripheral.name as String).toUpperCase().indexOf("DRIP") > -1 || (event.peripheral.name as String).toUpperCase().indexOf("BRIDGE") > -1) {
				blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
				blueToothServiceEvent.data = new Object();
				blueToothServiceEvent.data.information = 
					ModelLocator.resourceManagerInstance.getString('bluetoothservice','found_peripheral_with_name') +
					" = " + event.peripheral.name;
				_instance.dispatchEvent(blueToothServiceEvent);
				
				//var temp:String = BlueToothDevice.address;
				if (BlueToothDevice.address != "") {
					if (BlueToothDevice.address != event.peripheral.uuid) {
						//a bluetooth device address is already stored, but it's not the one for which peripheraldiscoveredhandler is called
						//so we ignore it
						dispatchInformation('stored_uuid_does_not_match');
						return;
					}
				}
				
				//we want to connect to this device, so stop scanning
				BluetoothLE.service.centralManager.stopScan();
				BluetoothLE.service.centralManager.connect(event.peripheral);
				dispatchInformation('stop_scanning_and_try_to_connect');
			}
		}
		
		private static function central_peripheralConnectHandler(event:PeripheralEvent):void {
			disableCheckScanTimer();
			disableReconnectTimer();
			nrOfAttemptsToConnectToNewDevice = 0;
			currentReconnectTimesPointer = 0;//for next new attempt, whenever just in case
			currentRescanTimesPointer = 0;
			if (BlueToothDevice.address == "") {
				BlueToothDevice.address = event.peripheral.uuid;
				BlueToothDevice.name = event.peripheral.name;
				dispatchInformation('connected_to_peripheral_device_id_stored');
			} else {
				dispatchInformation('connected_to_peripheral');
			}			
			activeBluetoothPeripheral = event.peripheral;
			var uuids:Vector.<String> = new <String>[HM10Attributes.HM_10_SERVICE];
			activeBluetoothPeripheral.discoverServices(uuids);
		}
		
		private static function central_peripheralConnectFailHandler(event:PeripheralEvent):void {
			if (activeBluetoothPeripheral == null) {
				//it was an attempt to connect to a peripheral that was just scanned
				if (BluetoothLE.service.state == BluetoothLEState.STATE_ON) {
					//bluetooth state is on so retry
					if (nrOfAttemptsToConnectToNewDevice == maxNrOfAttemptsToConnectToNewDevice) {
						nrOfAttemptsToConnectToNewDevice = 0;
						dispatchInformation('connection_failed_max_attempts_reached');
						currentRescanTimesPointer = 0;
						setCheckScanStatusTimer(false);
					} else {
						dispatchInformation('connection_failed_rescanning_will_start');
						bluetoothStatusIsOn();
						nrOfAttemptsToConnectToNewDevice++;
					}
				} else {
					//
					dispatchInformation('connection_failed_and_bluetooth_is_off');
				}
			} else {
				dispatchInformation('connection_attempt_to_peripheral_failed');
				setReconnectTimer();
			}
		}
		
		private static function central_peripheralDisconnectHandler(event:PeripheralEvent):void {
			dispatchInformation('disconnected_from_device');
			if (BluetoothLE.service.state == BluetoothLEState.STATE_ON)
				setReconnectTimer();
		}
		
		private static function peripheral_discoverServicesHandler(event:PeripheralEvent):void {
			if (event.peripheral.services.length > 0)
			{
				activeBluetoothPeripheral = event.peripheral;
				var uuids:Vector.<String> = new <String>[HM10Attributes.HM_RX_TX];
				activeBluetoothPeripheral.discoverCharacteristics(activeBluetoothPeripheral.services[0]/*, uuids*/);
			}
		}
		
		private static function peripheral_discoverCharacteristicsHandler(event:PeripheralEvent):void {
			characteristic = event.peripheral.services[0].characteristics[0];
			if (!activeBluetoothPeripheral.subscribeToCharacteristic(characteristic))
			{
				// TODO error starting subscription process
			}
		}
		
		
		/**
		 * simply acknowledges receipt of a message, needed for xbridge so that it goes to sleep 
		 */
		public static function ackCharacteristicUpdate():void {
			var value:ByteArray = new ByteArray();
			value.writeByte(0x02);
			value.writeByte(0xF0);
			activeBluetoothPeripheral.addEventListener(CharacteristicEvent.WRITE_SUCCESS, peripheral_characteristic_writeHandler);
			activeBluetoothPeripheral.addEventListener(CharacteristicEvent.WRITE_ERROR, peripheral_characteristic_writeErrorHandler);
			activeBluetoothPeripheral.writeValueForCharacteristic(characteristic, value);
			
		}
		
		private static function peripheral_characteristic_updatedHandler(event:CharacteristicEvent):void {
			for (var i:int = 0;i < event.characteristic.value.length;i++) {
				trace("bytearray element " + i + " = " + (new Number(event.characteristic.value[i])).toString(16));
			}
			
			//now start reading the values
			var value:ByteArray = event.characteristic.value;
			blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
			blueToothServiceEvent.data = new Object();
			blueToothServiceEvent.data.information = 
				ModelLocator.resourceManagerInstance.getString('bluetoothservice','data_packet_received_from_transmitter_with') +
				" byte 0 = " + value.readUnsignedByte() + " and byte 1 = " + value.readUnsignedByte();
			_instance.dispatchEvent(blueToothServiceEvent);
			
			value.position = 0;
			processTransmitterData(value);
		}
		
		private static function peripheral_characteristic_writeHandler(event:CharacteristicEvent):void {
			activeBluetoothPeripheral.removeEventListener(CharacteristicEvent.WRITE_SUCCESS, peripheral_characteristic_writeHandler);
			activeBluetoothPeripheral.removeEventListener(CharacteristicEvent.WRITE_ERROR, peripheral_characteristic_writeErrorHandler);
			trace("	BluetoothService.as : peripheral_characteristic_writeHandler");
		}
		
		private static function peripheral_characteristic_writeErrorHandler(event:CharacteristicEvent):void {
			activeBluetoothPeripheral.removeEventListener(CharacteristicEvent.WRITE_SUCCESS, peripheral_characteristic_writeHandler);
			activeBluetoothPeripheral.removeEventListener(CharacteristicEvent.WRITE_ERROR, peripheral_characteristic_writeErrorHandler);
			trace("	BluetoothService.as : peripheral_characteristic_writeErrorHandler");
			dispatchInformation("failed_to_write_value_for_characteristic_to_device");
		}
		
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
		
		private static function dispatchInformation(informationResourceName:String):void {
			blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
			blueToothServiceEvent.data = new Object();
			blueToothServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('bluetoothservice',informationResourceName);
			_instance.dispatchEvent(blueToothServiceEvent);
		}
		
		private static function tryReconnect(event:Event = null):void {
			if (activeBluetoothPeripheral != null) {
				BluetoothLE.service.centralManager.connect(activeBluetoothPeripheral);
				dispatchInformation('try_to_connect_to_device');
				setReconnectTimer();
			} else {
				checkScanStatus(null);
			}
		}
		
		private static function disableReconnectTimer():void {
			if (reconnectTimer != null) {
				if (reconnectTimer.hasEventListener(TimerEvent.TIMER)) 
					reconnectTimer.removeEventListener(TimerEvent.TIMER,tryReconnect);
				reconnectTimer.stop();
				reconnectTimer = null;
			}
		}
		
		/**
		 * sets timer after which new attempt will be done to connect to known bluetoothdevice<br>
		 * Also dispatch information
		 */
		private static function setReconnectTimer():void {
			var seconds:int = 0;
			if ((new Date()).valueOf() - timeStampOfLastDataPacketReceived < (4 * 60 + 45) * 1000) {
				//less than 4 minutes and 45 seconds since last data packet
				//new connect should happen in time for receiving the next packet, but not sooner
				seconds = (timeStampOfLastDataPacketReceived + (4 * 60 + 45) * 1000 - (new Date()).valueOf())/1000;
			} else {
				seconds = reconnectTimesInSeconds[currentReconnectTimesPointer];
				currentReconnectTimesPointer++;
				if (currentReconnectTimesPointer == reconnectTimesInSeconds.length)
					currentReconnectTimesPointer--;
			}
			trace("seconds for reattempt set to = " + seconds);
			
			blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
			blueToothServiceEvent.data = new Object();
			blueToothServiceEvent.data.information = 
				ModelLocator.resourceManagerInstance.getString('bluetoothservice','will_try_to_reconnect_in') +
				" " + seconds + " " +
				ModelLocator.resourceManagerInstance.getString('bluetoothservice','seconds');
			_instance.dispatchEvent(blueToothServiceEvent);
			
			disableReconnectTimer();
			reconnectTimer = new Timer(seconds * 1000, 1);
			reconnectTimer.addEventListener(TimerEvent.TIMER, tryReconnect);
			reconnectTimer.start();
		}
		
		/**
		 * checking scan means : check if scan is still running and if so stop it, or if not running restart it<br>
		 * this timer will set the timer to launch the checkScanStatus<br>
		 * If timer needs to be called for check running scan, then set checkForStopping = true<br> 
		 * Dispatches information<br>
		 * If timer started for checking when scanning needs to be restarted, then increments currentRescanTimesPointer<br>
		 */
		private static function setCheckScanStatusTimer(checkForStopping:Boolean):void {
			var seconds:int = 0;
			blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
			blueToothServiceEvent.data = new Object();
			if (checkForStopping) {
				seconds = secondsAfterWhichRunningScanWillBeStopped;
				blueToothServiceEvent.data.information = 
					ModelLocator.resourceManagerInstance.getString('bluetoothservice','will_stop_scanning') +
					" " + seconds + " " +
					ModelLocator.resourceManagerInstance.getString('bluetoothservice','seconds');
			}
			else {
				seconds = rescanTimesInSeconds[currentRescanTimesPointer];
				blueToothServiceEvent.data.information = 
					ModelLocator.resourceManagerInstance.getString('bluetoothservice','will_restart_scanning') +
					" " + seconds + " " +
					ModelLocator.resourceManagerInstance.getString('bluetoothservice','seconds');
			}
			_instance.dispatchEvent(blueToothServiceEvent);
			
			disableCheckScanTimer();
			checkReScanTimer = new Timer(seconds * 1000, 1);
			checkReScanTimer.addEventListener(TimerEvent.TIMER, checkScanStatus);
			checkReScanTimer.start();
			currentRescanTimesPointer++;
			if (currentRescanTimesPointer == rescanTimesInSeconds.length)
				currentRescanTimesPointer--;
		}
		
		private static function checkScanStatus(event:Event):void {
			if (BluetoothLE.service.centralManager.isScanning) {
				//to save energy
				BluetoothLE.service.centralManager.stopScan();
				dispatchInformation('scanning_still_running_stopped_now');
				setCheckScanStatusTimer(false);
			} else {
				if ((BluetoothLE.service.centralManager.state == BluetoothLEState.STATE_ON))
					//this will cause a new scanning, information will be dispatched in bluetoothStatusIsOn
					bluetoothStatusIsOn();
				else
					//else, no need to restart the scanning timer, whenever bluetooth is switched on, it will automatically restart
					dispatchInformation('bluetooth_is_switched_off');
			}
		}
		
		private static function disableCheckScanTimer():void {
			if (checkReScanTimer != null) {
				if (checkReScanTimer.hasEventListener(TimerEvent.TIMER)) 
					checkReScanTimer.removeEventListener(TimerEvent.TIMER,checkScanStatus);
				checkReScanTimer.stop();
				checkReScanTimer = null;
			}
		}
		
		/**
		 * Disconnects the active bluetoothperipheral if any (otherwise returns without doing anything)<br>
		 * If bluetooth status = on, then immediately will call bluetoothstatus is on (ie scanning, ...) 
		 */
		public static function forgetBlueToothDevice():void {
			blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.BLUETOOTH_SERVICE_INFORMATION_EVENT);
			blueToothServiceEvent.data = new Object();
			blueToothServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('settingsview','bluetoothdeviceforgotten');
			_instance.dispatchEvent(blueToothServiceEvent);
			
			currentReconnectTimesPointer = 0;//for next new attempt, whenever just in case
			currentRescanTimesPointer = 0;
			if (activeBluetoothPeripheral == null)
				return;
			BluetoothLE.service.centralManager.disconnect(activeBluetoothPeripheral);
			activeBluetoothPeripheral = null;
			disableReconnectTimer();
			if ((BluetoothLE.service.centralManager.state == BluetoothLEState.STATE_ON))
				bluetoothStatusIsOn();
		}
		
		/**
		 * encode transmitter id as explained in xBridge2.pdf 
		 */
		public static function encodeTxID(TxID:String):Number {
			var returnValue:Number = 0;
			var tmpSrc:String = TxID.toUpperCase();
			returnValue |= getSrcValue(tmpSrc.charAt(0)) << 20;
			returnValue |= getSrcValue(tmpSrc.charAt(1)) << 15;
			returnValue |= getSrcValue(tmpSrc.charAt(2)) << 10;
			returnValue |= getSrcValue(tmpSrc.charAt(3)) << 5;
			returnValue |= getSrcValue(tmpSrc.charAt(4));
			return returnValue;
		}
		
		private static function decodeTxID(TxID:Number):String {
			var returnValue:String = "";
			returnValue += srcNameTable[(TxID >> 20) & 0x1F];
			returnValue += srcNameTable[(TxID >> 15) & 0x1F];
			returnValue += srcNameTable[(TxID >> 10) & 0x1F];
			returnValue += srcNameTable[(TxID >> 5) & 0x1F];
			returnValue += srcNameTable[(TxID >> 0) & 0x1F];
			return returnValue;
		}
		
		private static function getSrcValue(ch:String):int {
			var i:int = 0;
			for (i = 0; i < srcNameTable.length; i++) {
				if (srcNameTable[i] == ch) break;
			}
			return i;
		}
		
		private static function processTransmitterData(buffer:ByteArray):void {
			var packetLength:int = buffer.readUnsignedByte();
			//position = 1
			var packetType:int = buffer.readUnsignedByte();//0 = data packet, 1 =  TXID packet, 0xF1 (241 if read as unsigned int) = Beacon packet
			switch (packetType) {
				case 0:
					//data packet
					var rawData:Number = buffer.readUnsignedInt();
					var filteredData:Number = buffer.readUnsignedInt();
					var transmitterBatteryVoltage:Number = buffer.readUnsignedByte();
					
					//following only if the name of the device contains "bridge", if it' doesnt contain bridge, then it's an xdrip (old) and doesn't have those bytes' +
					if (BlueToothDevice.isXBridge()) {
						var bridgeBatteryPercentage:Number = buffer.readUnsignedByte();
						var txID:Number = buffer.readUnsignedInt();
						var xBridgeProtocolLevel:Number = buffer.readUnsignedByte();
						
						blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.TRANSMITTER_DATA);
						blueToothServiceEvent.data = new TransmitterDataXBridgeDataPacket(rawData, filteredData, transmitterBatteryVoltage, bridgeBatteryPercentage, decodeTxID(txID));
						_instance.dispatchEvent(blueToothServiceEvent);
					} else {
						blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.TRANSMITTER_DATA);
						blueToothServiceEvent.data = new TransmitterDataXdripDataPacket(rawData, filteredData, transmitterBatteryVoltage);
						_instance.dispatchEvent(blueToothServiceEvent);
					}
					
					timeStampOfLastDataPacketReceived = (new Date()).valueOf();
					break;
				case 1://will actually never happen, this is a packet type for the other direction , ie from App to xbridge
					//TXID packet
					var txID:Number = buffer.readUnsignedInt();
					break;
				case 241:
					//Beacon packet
					var txID:Number = buffer.readUnsignedInt();
					
					blueToothServiceEvent = new BlueToothServiceEvent(BlueToothServiceEvent.TRANSMITTER_DATA);
					blueToothServiceEvent.data = new TransmitterDataXBridgeBeaconPacket(decodeTxID(txID));
					_instance.dispatchEvent(blueToothServiceEvent);
					
					var xBridgeProtocolLevel:Number = buffer.readUnsignedByte();//not needed for the moment
					break;
			}
		}
	}
}