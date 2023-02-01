//
//  BluetoothHelper.swift
//  QC45Control
//
//  Created by Niklas Arnitz on 01.02.23.
//

import Cocoa
import IOBluetooth
import IOBluetoothUI

class BluetoothHelper: IOBluetoothRFCOMMChannelDelegate {
    private let quietModeMessage: [UInt8] = [0x1f, 0x03, 0x05, 0x02, 0x00, 0x01]
    private let awareModeMessage: [UInt8] = [0x1f, 0x03, 0x05, 0x02, 0x01, 0x01]

    private var mRFCOMMChannel: IOBluetoothRFCOMMChannel?

    public func discover() {
        let deviceSelector = IOBluetoothDeviceSelectorController.deviceSelector()
        
        deviceSelector?.setDescriptionText("Please select your pair of Bose QC45 headphones here.")
        let sppServiceUUID = IOBluetoothSDPUUID.uuid32(kBluetoothSDPUUID16ServiceClassSerialPort.rawValue)

        if (deviceSelector == nil) {
            print("Error - Unable to allocate IOBluetoothDeviceSelectorController!")
            return
        }

        deviceSelector?.addAllowedUUID(sppServiceUUID)

        if(deviceSelector?.runModal() != Int32(kIOBluetoothUISuccess)) {
            print("Error - The User has canceled the device selection!")
            return
        }

        let devices = deviceSelector?.getResults()

        if((devices == nil) || (devices?.count == 0)) {
            print("Error - No selected Device")
            return
        }

        let device: IOBluetoothDevice = devices?[0] as! IOBluetoothDevice

        let sppServiceRecord = device.getServiceRecord(for: sppServiceUUID)

        if(sppServiceRecord == nil) {
            print("Error - SPP not available on the selected device!")
        }

        var rfCommChannelID: BluetoothRFCOMMChannelID = 0;

        if(sppServiceRecord?.getRFCOMMChannelID(&rfCommChannelID) != kIOReturnSuccess) {
            print("Error - SPP not available on the selected device!")
            return
        }

        if(device.openRFCOMMChannelSync(&mRFCOMMChannel, withChannelID: rfCommChannelID, delegate: self) != kIOReturnSuccess) {
            print("Error - Couldn't open RFCOMMChannel.")
        }
    }
    
    public func close() {
        mRFCOMMChannel?.close()
    }

    @objc func switchToQuietMode() {
        let dataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: quietModeMessage.count)
        dataPointer.initialize(from: quietModeMessage, count: quietModeMessage.count)


        mRFCOMMChannel?.writeSync(dataPointer, length: UInt16(quietModeMessage.count))
        dataPointer.deallocate()
    }

    @objc func switchToAwareMode() {
        let dataPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: awareModeMessage.count)
        dataPointer.initialize(from: awareModeMessage, count: awareModeMessage.count)


        mRFCOMMChannel?.writeSync(dataPointer, length: UInt16(quietModeMessage.count))
        dataPointer.deallocate()
    }

    @IBAction func didPressAwareModeButton(_ sender: NSButton) {
        switchToAwareMode()
    }

    @IBAction func didPressQuietModeButton(_ sender: NSButton) {
        switchToQuietMode()
    }

    func rfcommChannelOpenComplete(_ rfcommChannel: IOBluetoothRFCOMMChannel!, status error: IOReturn) {
        if(error != kIOReturnSuccess){
            print("Error - Failed to open the RFCOMM channel");
        }
        else {
            print("Connected");
        }
    }
}
