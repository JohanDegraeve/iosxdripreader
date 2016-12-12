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
	import com.distriqt.extension.dialog.Dialog;
	import com.distriqt.extension.dialog.DialogView;
	import com.distriqt.extension.dialog.builders.AlertBuilder;
	import com.distriqt.extension.dialog.events.DialogViewEvent;
	import com.distriqt.extension.dialog.objects.DialogAction;
	
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import databaseclasses.BgReading;
	import databaseclasses.CommonSettings;
	import databaseclasses.Sensor;
	
	import events.BlueToothServiceEvent;
	import events.TransmitterServiceEvent;
	
	import model.ModelLocator;
	import model.TransmitterDataXBridgeBeaconPacket;
	import model.TransmitterDataXBridgeDataPacket;
	import model.TransmitterDataXdripDataPacket;
	
	/**
	 * transmitter service handles all transmitterdata received from BlueToothService<br>
	 * It will handle TransmitterData .. packets (see children of TransmitterData class), create bgreadings ..<br>
	 * If no sensor active then no bgreading will be created<br>
	 * init must be called to start the service
	 */
	public class TransmitterService extends EventDispatcher
	{
		[ResourceBundle("transmitterservice")]
		
		private static var _instance:TransmitterService = new TransmitterService();
		
		public static function get instance():TransmitterService
		{
			return _instance;
		}
		
		private static var initialStart:Boolean = true;
		/**
		 * timestamp of last received packet, in ms 
		 */
		private static var lastPacketTime:Number = 0;
		
		public function TransmitterService()
		{
			if (_instance != null) {
				throw new Error("TransmitterService class  constructor can not be used");	
			}
		}
		
		public static function init():void {
			if (!initialStart)
				return;
			else
				initialStart = false;
			
			BluetoothService.instance.addEventListener(BlueToothServiceEvent.TRANSMITTER_DATA, transmitterDataReceived);
			
		}
		
		private static function transmitterDataReceived(be:BlueToothServiceEvent):void {
			if (be.data == null)
				return;//should never be null actually
			else {
				if (be.data is TransmitterDataXBridgeBeaconPacket) {
					var transmitterDataBeaconPacket:TransmitterDataXBridgeBeaconPacket = be.data as TransmitterDataXBridgeBeaconPacket;
					if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID) == "00000" 
						&&
						transmitterDataBeaconPacket.TxID == "00000") {
						var alert:DialogView = Dialog.service.create(
							new AlertBuilder()
							.setTitle(ModelLocator.resourceManagerInstance.getString("transmitterservice","enter_transmitter_id_dialog_title"))
							.setMessage(ModelLocator.resourceManagerInstance.getString("calibrationservice","enter_transmitter_id"))
							.addTextField("","00000")
							.addOption("Ok", DialogAction.STYLE_POSITIVE, 0)
							.addOption(ModelLocator.resourceManagerInstance.getString("general","cancel"), DialogAction.STYLE_CANCEL, 1)
							.build()
						);
						alert.addEventListener(DialogViewEvent.CLOSED, transmitterIdEntered);
						DialogService.addDialog(alert, 60);
					} else if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID) == "00000" 
						&&
						transmitterDataBeaconPacket.TxID != "00000") {
						trace("TransmitterService.as storing transmitter id received from bluetooth device = " + transmitterDataBeaconPacket.TxID);
						var transmitterServiceEvent:TransmitterServiceEvent = new TransmitterServiceEvent(TransmitterServiceEvent.TRANSMITTER_SERVICE_INFORMATION_EVENT);
						transmitterServiceEvent.data = new Object();
						transmitterServiceEvent.data.information = "storing transmitter id received from bluetooth device = " + transmitterDataBeaconPacket.TxID;
						_instance.dispatchEvent(transmitterServiceEvent);
						CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID, transmitterDataBeaconPacket.TxID);
					} else if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID) != "00000" 
						&&
						transmitterDataBeaconPacket.TxID != CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID) != "00000") {
						var value:ByteArray = new ByteArray();
						value.writeByte(0x06);
						value.writeByte(0x01);
						value.writeUnsignedInt((BluetoothService.encodeTxID(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID))));
						trace("TransmitterService.as calling BluetoothService.ackCharacteristicUpdate");
						BluetoothService.ackCharacteristicUpdate(value);
					} else {
						var value:ByteArray = new ByteArray();
						value.writeByte(0x02);
						value.writeByte(0xF0);
						BluetoothService.ackCharacteristicUpdate(value);
					}
				} else if (be.data is TransmitterDataXBridgeDataPacket) {
					var transmitterDataXBridgeDataPacket:TransmitterDataXBridgeDataPacket = be.data as TransmitterDataXBridgeDataPacket;
					if (((new Date()).valueOf() - lastPacketTime) < 60000) {
						//if previous packet was less than 1 minute ago then ignore it
						//dispatchInformation('ignoring_transmitterxbridgedatapacket');
					} else {
						lastPacketTime = (new Date()).valueOf();
						if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID) == "00000" 
							&&
							transmitterDataXBridgeDataPacket.TxID != "00000") {
							trace("TransmitterService.as storing transmitter id received from bluetooth device = " + transmitterDataXBridgeDataPacket.TxID);
							var transmitterServiceEvent:TransmitterServiceEvent = new TransmitterServiceEvent(TransmitterServiceEvent.TRANSMITTER_SERVICE_INFORMATION_EVENT);
							transmitterServiceEvent.data = new Object();
							transmitterServiceEvent.data.information = "storing transmitter id received from bluetooth device = " + transmitterDataXBridgeDataPacket.TxID;
							_instance.dispatchEvent(transmitterServiceEvent);
							CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID, transmitterDataXBridgeDataPacket.TxID);
						} else if (CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID) != "00000" 
							&&
							transmitterDataXBridgeDataPacket.TxID != CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID) != "00000") {
							var value:ByteArray = new ByteArray();
							value.writeByte(0x06);
							value.writeByte(0x01);
							value.writeUnsignedInt((BluetoothService.encodeTxID(CommonSettings.getCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID))));
								trace("TransmitterService.as calling BluetoothService.ackCharacteristicUpdate");
								BluetoothService.ackCharacteristicUpdate(value);
								} else {
									var value:ByteArray = new ByteArray();
									value.writeByte(0x02);
									value.writeByte(0xF0);
									BluetoothService.ackCharacteristicUpdate(value);
								}						
						//store the transmitter battery level in the common settings (to be synchronized)
						CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_BATTERY_VOLTAGE,transmitterDataXBridgeDataPacket.transmitterBatteryVoltage.toString());
						
						//store the bridge battery level in the common settings (to be synchronized)
						CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_BRIDGE_BATTERY_PERCENTAGE,transmitterDataXBridgeDataPacket.bridgeBatteryPercentage.toString());
						if (Sensor.getActiveSensor() != null) {
							Sensor.getActiveSensor().latestBatteryLevel = transmitterDataXBridgeDataPacket.transmitterBatteryVoltage;
							//create and save bgreading
							BgReading.
								create(transmitterDataXBridgeDataPacket.rawData, transmitterDataXBridgeDataPacket.filteredData)
								.saveToDatabaseSynchronous();
							
							//dispatch the event that there's new data
							var transmitterServiceEvent:TransmitterServiceEvent = new TransmitterServiceEvent(TransmitterServiceEvent.BGREADING_EVENT);
							_instance.dispatchEvent(transmitterServiceEvent);
						} else {
							//TODO inform that bgreading is received but sensor not started ?
						}
					}
					
				} else if (be.data is TransmitterDataXdripDataPacket) {
					var transmitterDataXdripDataPacket:TransmitterDataXdripDataPacket = be.data as TransmitterDataXdripDataPacket;
					if (((new Date()).valueOf() - lastPacketTime) < 60000) {
						//if previous packet was less than 1 minute ago then ignore it
						//dispatchInformation('ignoring_transmitterxdripdatapacket');
					} else {//it's an xdrip, with old software, 
						lastPacketTime = (new Date()).valueOf();
						
						//store as bridge battery level value 0 in the common settings (to be synchronized)
						CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_BRIDGE_BATTERY_PERCENTAGE, "0");
						
						//store the transmitter battery level in the common settings (to be synchronized)
						CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_BATTERY_VOLTAGE, transmitterDataXdripDataPacket.transmitterBatteryVoltage.toString());
						Sensor.getActiveSensor().latestBatteryLevel = transmitterDataXdripDataPacket.transmitterBatteryVoltage;
						//create and save bgreading
						BgReading.
							create(transmitterDataXdripDataPacket.rawData, transmitterDataXdripDataPacket.filteredData)
							.saveToDatabaseSynchronous();
						
						//dispatch the event that there's new data
						transmitterServiceEvent = new TransmitterServiceEvent(TransmitterServiceEvent.BGREADING_EVENT);
						_instance.dispatchEvent(transmitterServiceEvent);
					}
				}
			}
		}
		
		private static function transmitterIdEntered(event:DialogViewEvent):void {
			if (event.index == 1) {
				return;
			}
			if ((event.values[0] as String).length != 5) {
				var alert:DialogView = Dialog.service.create(
					new AlertBuilder()
					.setTitle(ModelLocator.resourceManagerInstance.getString("transmitterservice","enter_transmitter_id_dialog_title"))
					.setMessage(ModelLocator.resourceManagerInstance.getString("transmitterservice","transmitter_id_should_be_five_chars"))
					.addOption("Ok", DialogAction.STYLE_POSITIVE, 0)
					.build()
				);
				DialogService.addDialog(alert);
			} else {
				var value:ByteArray = new ByteArray();
				value.writeByte(0x06);
				value.writeByte(0x01);
				value.writeUnsignedInt(BluetoothService.encodeTxID(event.values[0] as String));
				trace("TransmitterService.as calling BluetoothService.ackCharacteristicUpdate");
				BluetoothService.ackCharacteristicUpdate(value);
				CommonSettings.setCommonSetting(CommonSettings.COMMON_SETTING_TRANSMITTER_ID, event.values[0] as String);
			}
		}
		
		private static function dispatchInformation(informationResourceName:String):void {
			var transmitterServiceEvent:TransmitterServiceEvent = new TransmitterServiceEvent(TransmitterServiceEvent.TRANSMITTER_SERVICE_INFORMATION_EVENT);
			transmitterServiceEvent.data = new Object();
			transmitterServiceEvent.data.information = ModelLocator.resourceManagerInstance.getString('transmitterservice',informationResourceName);
			_instance.dispatchEvent(transmitterServiceEvent);
		}
		
		
	}
}