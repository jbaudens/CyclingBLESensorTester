//
//  BLE.swift
//  CyclingBLESensorTester
//
//  Created by JB Baudens on 4/5/23.
//

import Foundation
import CoreBluetooth

let heartRateServiceCBUUID = CBUUID(string: "0x180D")
let cyclingPowerServiceCBUUID = CBUUID(string: "0x1818")
let cyclingSpeedAndCadenceServiceCBUUID = CBUUID(string: "0x1816")
let fitnessMachineServiceCBUUID = CBUUID(string: "0x1826")
let indoorBikeServiceCBUUID = CBUUID(string: "0x1825")


let ManufacturerNameCharacteristicCBUUID = CBUUID(string: "2A29")
let ModelNumberCharacteristicCBUUID = CBUUID(string: "2A24")
let SerialNumberCharacteristicCBUUID = CBUUID(string: "2A25")
let HardwareRevisionCharacteristicCBUUID = CBUUID(string: "2A27")
let FirmwareRevisionCharacteristicCBUUID = CBUUID(string: "2A26")

let BatteryLevelCharacteristicCBUUID = CBUUID(string: "2A19")

let HeartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
let BodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")

let CSCMeasurementCharacteristicCBUUID = CBUUID(string: "2A53")
let CSCFeatureCharacteristicCBUUID = CBUUID(string: "2A54")
let CSCSensorLocationCharacteristicCBUUID = CBUUID(string: "2A5B")
let CSCControlPointCharacteristicCBUUID = CBUUID(string: "2A5C")

let cyclingPowerCharacteristicCBUUID = CBUUID(string: "2A63")


protocol BLEProtocol {
    var delegate : BLEDelegate! {get set}
    var isSwitchedOn : Bool {get}
    func scan()
    func stopScan()
    func connect(sensorId: UUID)
    func disconnect(sensorId: UUID)
}

protocol BLEDelegate {
    func centralSwithedOn()
    func newSensorDiscovered(sensorId: UUID, name: String)
    func newServiceDiscovered(sensorId: UUID, desc: String)
    func updateHRData(sensorId: UUID, hr: UInt16, rrIntervals: [UInt16])
    func updatePowerData(sensorId: UUID, power: UInt16, pedalPowerBalance: UInt8?)
    func updateBodyLocation(sensorId: UUID, bodyLocation: String)
    func updateManufacturerName(sensorId: UUID, manufacturerName: String)
    func updateModelNumber(sensorId: UUID, modelNumber: String)
    func updateSerialNumber(sensorId: UUID, serialNumber: String)
    func updateHardwareRevision(sensorId: UUID, hardwareRev: String)
    func updateFirmwareRevision(sensorId: UUID, firmwareRev: String)
    func updateBatteryLevel(sensorId: UUID, batteryLevel: UInt8)
    func updateWheelRpm(sensorId: UUID, wheelRPM: Double)
    func updateCrankRpm(sensorId: UUID, crankRPM: Double)
    func updateSensorLocation(sensorId: UUID, sensorLocation: String)
}


class BLEController : NSObject, BLEProtocol, CBCentralManagerDelegate, CBPeripheralDelegate {
    var isSwitchedOn = false
    var myCentral: CBCentralManager!
    var delegate : BLEDelegate!
    var peripherals : Set<CBPeripheral>
    
    override init() {
        peripherals = Set<CBPeripheral>()
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
            delegate.centralSwithedOn()
        }
        else {
            isSwitchedOn = false
        }
    }
    
    func scan() {
        myCentral.scanForPeripherals(withServices: [heartRateServiceCBUUID, cyclingPowerServiceCBUUID, indoorBikeServiceCBUUID, fitnessMachineServiceCBUUID, indoorBikeServiceCBUUID])
    }
    
    func stopScan() {
        myCentral.stopScan()
    }
    
    private func getPeripheralById(sensorId: UUID) -> CBPeripheral? {
        for peripheral in peripherals {
            if peripheral.identifier == sensorId {
                return peripheral
            }
        }
        return nil
    }
    
    func connect(sensorId: UUID) {
        let peripheral = getPeripheralById(sensorId: sensorId)
        if let peripheral = peripheral {
            myCentral.connect(peripheral, options: nil)
        }
    }
    
    func disconnect(sensorId: UUID) {
        let peripheral = getPeripheralById(sensorId: sensorId)
        if let peripheral = peripheral {
            myCentral.cancelPeripheralConnection(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.insert(peripheral)
            delegate.newSensorDiscovered(sensorId: peripheral.identifier, name: peripheral.name ?? "unknown name")
            peripheral.delegate = self
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            delegate.newServiceDiscovered(sensorId: peripheral.identifier, desc: service.uuid.description)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
      guard let characteristics = service.characteristics else { return }
      
      for characteristic in characteristics {
        if characteristic.properties.contains(.read) {
          peripheral.readValue(for: characteristic)
          
        }
        if characteristic.properties.contains(.notify) {
          peripheral.setNotifyValue(true, for: characteristic)
        }
      }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        switch characteristic.uuid {
        case BodySensorLocationCharacteristicCBUUID:
            if let data = characteristic.value {
                delegate.updateBodyLocation(sensorId: peripheral.identifier, bodyLocation: HeartRateParser.parseBodyLocation(data: data))
            }
        case HeartRateMeasurementCharacteristicCBUUID:
            if let data = characteristic.value {
                let hrm = HeartRateParser.parseHRM(data: data)
                delegate.updateHRData(sensorId: peripheral.identifier, hr: hrm.heartRateMeasurementValue, rrIntervals: hrm.rrIntervals)
            }
        case cyclingPowerCharacteristicCBUUID:
            if let data = characteristic.value {
                let cpm = CyclingPowerParser.parsePowerData(data: data)
                delegate.updatePowerData(sensorId: peripheral.identifier, power: cpm.instantPower, pedalPowerBalance: cpm.pedalPowerBalance)
            }
        case ManufacturerNameCharacteristicCBUUID:
            if let data = characteristic.value {
                if let str = String(data: data, encoding: .utf8) {
                    delegate.updateManufacturerName(sensorId: peripheral.identifier, manufacturerName: str)
                }
            }
        case ModelNumberCharacteristicCBUUID:
            if let data = characteristic.value {
                if let str = String(data: data, encoding: .utf8) {
                    delegate.updateModelNumber(sensorId: peripheral.identifier, modelNumber: str)
                }
            }
        case SerialNumberCharacteristicCBUUID:
            if let data = characteristic.value {
                if let str = String(data: data, encoding: .utf8) {
                    delegate.updateSerialNumber(sensorId: peripheral.identifier, serialNumber: str)
                }
            }
        case HardwareRevisionCharacteristicCBUUID:
            if let data = characteristic.value {
                if let str = String(data: data, encoding: .utf8) {
                    delegate.updateHardwareRevision(sensorId: peripheral.identifier, hardwareRev: str)
                }
            }
        case FirmwareRevisionCharacteristicCBUUID:
            if let data = characteristic.value {
                if let str = String(data: data, encoding: .utf8) {
                    delegate.updateFirmwareRevision(sensorId: peripheral.identifier, firmwareRev: str)
                }
            }
        case BatteryLevelCharacteristicCBUUID:
            if let data = characteristic.value {
                delegate.updateBatteryLevel(sensorId: peripheral.identifier, batteryLevel: data[0])
            }
        case CSCMeasurementCharacteristicCBUUID:
            if let data = characteristic.value {
                let (wheelRPM, crankRPM) = CyclingSpeedAndCadenceParser.parseCrankOrWheelRevolutionData(data)
                if let wheelRPM = wheelRPM {
                    delegate.updateWheelRpm(sensorId: peripheral.identifier, wheelRPM: wheelRPM)
                }
                if let crankRPM = crankRPM {
                    delegate.updateCrankRpm(sensorId: peripheral.identifier, crankRPM: crankRPM)
                }
            }
        case CSCSensorLocationCharacteristicCBUUID:
            if let data = characteristic.value {
                if let decodedSensorLocation = CyclingSpeedAndCadenceParser.parseSensorLocationData(data) {
                    delegate.updateSensorLocation(sensorId: peripheral.identifier, sensorLocation: decodedSensorLocation)
                }
            }
        default:
            if let data = characteristic.value {
            }
        }
    }
    
}

