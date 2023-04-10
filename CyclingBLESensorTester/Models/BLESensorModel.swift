//
//  BLESensor.swift
//  CyclingBLESensorTester
//
//  Created by JB Baudens on 4/5/23.
//

import Foundation

class BLESensorModel : ObservableObject {
    @Published var name : String
    @Published var isConnected : Bool
    @Published var services : Set<String> = Set<String>()
    @Published var hrData : [HRData] = [HRData]()
    @Published var powerData : [PowerData] = [PowerData]()
    @Published var bodyLocation : String?
    @Published var sensorLocation : String?
    @Published var batteryLevel : UInt8?
    @Published var manufacturerName : String?
    @Published var modelNumber : String?
    @Published var serialNumber : String?
    @Published var hardwareRev : String?
    @Published var firmwareRev : String?
    @Published var wheelRPM : Double?
    @Published var crankRPM : Double?
    
    var connect : (() -> Void)
    var disconnect : (() -> Void)

    
    init(name: String, connect : (@escaping () -> Void), disconnect : (@escaping () -> Void)) {
        self.name = name
        self.isConnected = false
        self.connect = connect
        self.disconnect = disconnect
    }
}

class BLESensorModelFactory {
    static func createHRSensor(sensorName : String) -> BLESensorModel {
        let sensor = BLESensorModel(name: sensorName, connect: {}, disconnect: {})
        let date = Date()
        for i in 1..<100 {
            let modifiedDate = Calendar.current.date(byAdding: .second, value: i, to: date)!
            sensor.hrData.append(HRData(sensorName: sensorName, date: modifiedDate, hr: UInt16.random(in: 38...202), rrIntervals: [UInt16]()))
        }
        sensor.batteryLevel = UInt8.random(in: 0...100)
        sensor.manufacturerName = "Garmin"
        sensor.modelNumber = "HR Dual"
        sensor.serialNumber = "AB1234"
        sensor.hardwareRev = "1.2"
        sensor.firmwareRev = "12.8"
        return sensor
    }
    
    static func createPowerSensor(sensorName : String) -> BLESensorModel {
        let sensor = BLESensorModel(name: sensorName, connect: {}, disconnect: {})
        let date = Date()
        for i in 1..<100 {
            let modifiedDate = Calendar.current.date(byAdding: .second, value: i, to: date)!
            sensor.powerData.append(PowerData(sensorName: sensorName, date: modifiedDate, power: UInt16.random(in: 0...1250), pedalPowerBalance: UInt8.random(in: 0...200)))
        }
        sensor.batteryLevel = UInt8.random(in: 0...100)
        sensor.manufacturerName = "Garmin"
        sensor.modelNumber = "Vector 3"
        sensor.serialNumber = "AB1234"
        sensor.hardwareRev = "1.2"
        sensor.firmwareRev = "12.8"
        return sensor
    }
}
