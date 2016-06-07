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
	import com.distriqt.extension.bluetoothle.events.PeripheralEvent;
	
	import model.ModelLocator;

	public class BluetoothService
	{
		[ResourceBundle("secrets")]
		
		private static var instance:BluetoothService = new BluetoothService();

		public function BluetoothService()
		{
			if (instance != null) {
				throw new Error("BluetoothService class can only be instantiated through BluetoothService.getInstance()");	
			}

			BluetoothLE.init(ModelLocator.resourceManagerInstance.getString('secrets','distriqt-key'));
			if (BluetoothLE.isSupported) {
				trace("bluetoothle is supported");
				//set an eventlistener for state changes
				BluetoothLE.service.addEventListener( BluetoothLEEvent.STATE_CHANGED, bluetoothStateChangedHandler );
				
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

			} else {
				trace("bluetoothle is not supported - no further action to take");
			}
		}
		
		public static function getInstance():BluetoothService {
			if (instance == null) instance = new BluetoothService();
			return instance;
		}
		
		private function bluetoothStateChangedHandler(event:BluetoothLEEvent):void
		{
			trace("bluetoothStateChangedHandler (): " + BluetoothLE.service.state);
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
		* Then we'll scan for peripherals. If we don't have a peripheral name stored yet in the settings, then we'll try to connect to the first xdrip or xbridge<br>
		* If we already have or had a bluetoothe peripheral name stored, then we'll only connect to that one <br>
		 * 
		 * TO DO : NOT SURE ACTUALLY IF THE DEVICE WILL AUTOMATICALLY CONNECT TO A PERIPHERAL THAT WAS ALREADY KNOWN BEFORE
		*/
		private function bluetoothStatusIsOn():void {
			BluetoothLE.service.centralManager.addEventListener( PeripheralEvent.DISCOVERED, central_peripheralDiscoveredHandler );
			
			if (!BluetoothLE.service.centralManager.scanForPeripherals())
			{
				trace("BluetoothService.bluetoothStatusIsOn : error while trying to scan for peripherals");
				//TODO handle this error
				return;
			}
			
			function central_peripheralDiscoveredHandler(event:PeripheralEvent):void
			{
				// event.peripheral will contain a Peripheral object with information about the Peripheral
				trace( "peripheral discovered: "+ event.peripheral.name );
			}
		}

	}
}