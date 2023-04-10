//
//  BLEViewModel.swift
//  CyclingBLESensorTester
//
//  Created by JB Baudens on 4/5/23.
//

import Foundation




struct HRData {
    var sensorName: String
    var date: Date
    var hr: UInt16
    var rrIntervals: [UInt16]
}

struct PowerData {
    var sensorName: String
    var date: Date
    var power: UInt16
    var pedalPowerBalance: UInt8?

    func rightPowerPercentage() -> Int? {
        guard let pedalPowerBalance = pedalPowerBalance else {
            return nil
        }
        let leftPower = Double(200 - Int16(pedalPowerBalance)) * Double(power) / 200
        let totalPower = Double(power)
        if totalPower == 0 {
            return 50
        }
        return Int(round(leftPower / totalPower * 1000) / 10) // percentage of left power
    }

    func leftPowerPercentage() -> Int? {
        guard let pedalPowerBalance = pedalPowerBalance else {
            return nil
        }
        let rightPower = Double(pedalPowerBalance) * Double(power) / 200
        let totalPower = Double(power)
        if totalPower == 0 {
            return 50
        }
        return Int(round(rightPower / totalPower * 1000) / 10) // percentage of right power
    }
}


protocol BLEViewModelProtocol: ObservableObject {
    var centralSwitchOn: Bool { get }
    var isScanning: Bool { get }
    var sensors: [UUID: BLESensorModel] { get }
    var hrData: [HRData] { get }
    var powerData: [PowerData] { get }
    func scan()
    func stopScan()
}


final class BLEViewModel: NSObject, BLEDelegate, BLEViewModelProtocol {
    @Published var centralSwitchOn : Bool = false
    @Published var isScanning : Bool = false
    @Published var sensors : [UUID: BLESensorModel]
    @Published var hrData : [HRData] = [HRData]()
    @Published var powerData : [PowerData] = [PowerData]()

    var bleController : BLEProtocol
    
    override init() {
        sensors = [UUID: BLESensorModel]()
        self.bleController = BLEController()
        super.init()
        self.bleController.delegate = self
    }
    
    func scan() {
        isScanning = true
        bleController.scan()
    }
    
    func stopScan() {
        isScanning = false
        bleController.stopScan()
    }
    
    
    
    func centralSwithedOn() {
        centralSwitchOn = true
    }
    
    func newSensorDiscovered(sensorId: UUID, name: String) {
        sensors[sensorId] = BLESensorModel(name: name,
                                           connect: {
            self.bleController.connect(sensorId: sensorId)
        },
                                           disconnect: {
            self.bleController.disconnect(sensorId: sensorId)
        })
    }
    
    func newServiceDiscovered(sensorId: UUID, desc: String) {
        sensors[sensorId]?.services.insert(desc)
    }
    
    func updateHRData(sensorId: UUID, hr: UInt16, rrIntervals: [UInt16]) {
        hrData.append(HRData(sensorName: sensors[sensorId]!.name, date: Date(), hr: hr, rrIntervals: rrIntervals))
        sensors[sensorId]?.hrData.append(HRData(sensorName: sensors[sensorId]!.name, date: Date(), hr: hr, rrIntervals: rrIntervals))
    }
    
    func updatePowerData(sensorId: UUID, power: UInt16, pedalPowerBalance: UInt8?) {
        powerData.append(PowerData(sensorName: sensors[sensorId]!.name, date: Date(), power: power, pedalPowerBalance: pedalPowerBalance))
        sensors[sensorId]?.powerData.append(PowerData(sensorName: sensors[sensorId]!.name, date: Date(), power: power, pedalPowerBalance: pedalPowerBalance))
    }
    
    func updateBodyLocation(sensorId: UUID, bodyLocation: String) {
        sensors[sensorId]?.bodyLocation = bodyLocation
    }
    
    func updateManufacturerName(sensorId: UUID, manufacturerName: String) {
        sensors[sensorId]?.manufacturerName = manufacturerName
    }
    
    func updateModelNumber(sensorId: UUID, modelNumber: String) {
        sensors[sensorId]?.modelNumber = modelNumber
    }
    
    func updateSerialNumber(sensorId: UUID, serialNumber: String) {
        sensors[sensorId]?.serialNumber = serialNumber
    }
    
    func updateHardwareRevision(sensorId: UUID, hardwareRev: String) {
        sensors[sensorId]?.hardwareRev = hardwareRev
    }
    
    func updateFirmwareRevision(sensorId: UUID, firmwareRev: String) {
        sensors[sensorId]?.firmwareRev = firmwareRev
    }
    
    func updateBatteryLevel(sensorId: UUID, batteryLevel: UInt8) {
        sensors[sensorId]?.batteryLevel = batteryLevel
    }
    
    func updateWheelRpm(sensorId: UUID, wheelRPM: Double) {
        
    }
    
    func updateCrankRpm(sensorId: UUID, crankRPM: Double) {
        
    }
    
    func updateSensorLocation(sensorId: UUID, sensorLocation: String) {
        sensors[sensorId]?.sensorLocation = sensorLocation
    }
}
