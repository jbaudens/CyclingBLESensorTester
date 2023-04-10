//
//  CyclingSpeedAndCadence.swift
//  CyclingBLESensorTester
//
//  Created by JB Baudens on 4/6/23.
//

import Foundation

class CyclingSpeedAndCadenceParser {
    static func parseCrankOrWheelRevolutionData(_ data: Data) -> (wheelRpm: Double?, crankRpm: Double?) {
        let flags = data[0]
        let wheelRevolutionPresent = flags & 0x01 > 0
        let crankRevolutionPresent = flags & 0x02 > 0
        
        let rawWheelRevolutions = wheelRevolutionPresent ? UInt32(data[1]) | UInt32(data[2]) << 8 | UInt32(data[3]) << 16 | UInt32(data[4]) << 24 : nil
        let rawCrankRevolutions = crankRevolutionPresent ? UInt16(data[5]) | UInt16(data[6]) << 8 : nil
        let lastEventTime = UInt16(data[7]) | UInt16(data[8]) << 8
        
        var wheelRpm: Double? = nil
        if let wheelRevolutions = rawWheelRevolutions {
            let wheelRpmValue = Double(wheelRevolutions) / Double(lastEventTime) * 60.0
            wheelRpm = wheelRpmValue
        }
        
        var crankRpm: Double? = nil
        if let crankRevolutions = rawCrankRevolutions {
            let crankRpmValue = Double(crankRevolutions) / Double(lastEventTime) * 60.0
            crankRpm = crankRpmValue
        }
        
        return (wheelRpm, crankRpm)
    }
    
    
    static func parseSensorLocationData(_ data: Data) -> String? {
        // Make sure the data is at least 1 byte long
        guard data.count >= 1 else {
            return nil
        }
        
        // Extract the flags byte and check if the Sensor Location field is present
        let flags = data[0]
        let isSensorLocationPresent = flags & 0x01 != 0
        
        if isSensorLocationPresent {
            // Extract the Sensor Location field and decode it into a string
            let sensorLocation = Int(data[1])
            return CyclingSpeedAndCadenceParser.decodeSensorLocation(sensorLocation)
        } else {
            return nil
        }
    }
    
    static func decodeSensorLocation(_ sensorLocation: Int) -> String? {
        switch sensorLocation {
        case 0:
            return "Other"
        case 1:
            return "Top of shoe"
        case 2:
            return "In shoe"
        case 3:
            return "Hip"
        case 4:
            return "Front wheel"
        case 5:
            return "Left crank"
        case 6:
            return "Right crank"
        case 7:
            return "Left pedal"
        case 8:
            return "Right pedal"
        case 9:
            return "Front hub"
        case 10:
            return "Rear dropout"
        case 11:
            return "Chainstay"
        case 12:
            return "Rear wheel"
        case 13:
            return "Rear hub"
        case 14:
            return "Chest"
        case 15:
            return "Rear shock"
        default:
            return nil
        }
    }

}


