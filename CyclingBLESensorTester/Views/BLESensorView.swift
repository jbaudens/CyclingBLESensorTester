//
//  BLESensorView.swift
//  CyclingBLESensorTester
//
//  Created by JB Baudens on 4/5/23.
//

import SwiftUI

struct BLESensorDataView: View {
    @ObservedObject var bleSensor: BLESensorModel
    @State var sensorSwitchIsOn = false
    
    var body: some View {
        VStack {
            Toggle(isOn: $sensorSwitchIsOn) {
                    Text(bleSensor.name).font(Font.headline.weight(.bold))
            }
            .toggleStyle(SwitchToggleStyle(tint: .green))
            .padding()
            .onChange(of: sensorSwitchIsOn) { value in
                if value {
                    // Connect to the sensor
                    bleSensor.connect()
                } else {
                    // Disconnect from the sensor
                    bleSensor.disconnect()
                }
            }

            Text("\(bleSensor.manufacturerName ?? "") \(bleSensor.modelNumber ?? "") \(bleSensor.bodyLocation ?? "") \(bleSensor.sensorLocation ?? "")")
            Text("\(bleSensor.serialNumber ?? "") \(bleSensor.hardwareRev ?? "") \(bleSensor.firmwareRev ?? "")")

            VStack {
                if !bleSensor.hrData.isEmpty {
                    HStack {
                        Image(systemName: "heart.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .frame(width: 30, alignment: .leading)
                        Text(bleSensor.hrData.last!.hr.description).frame(width: 80, alignment: .center)
                    }
                    HStack {
                        Text("RR")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .frame(width: 30, alignment: .leading)
                        Text(bleSensor.hrData.last!.rrIntervals.description).frame(width: 80, alignment: .center)
                    }
                }
                if !bleSensor.powerData.isEmpty {
                    HStack {
                        Image(systemName: "bolt.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .frame(width: 30, alignment: .leading)
                        Text(bleSensor.powerData.last!.power.description).frame(width: 80, alignment: .center)
                        
                    }
                    HStack {
                        Image(systemName: "scalemass.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                            .frame(width: 30, alignment: .leading)
                        
                        if let _ = bleSensor.powerData.last!.pedalPowerBalance {
                            Text("\(bleSensor.powerData.last!.leftPowerPercentage()!.description) - \(bleSensor.powerData.last!.rightPowerPercentage()!.description)")
                                .frame(width: 80, alignment: .center)
                        } else {
                            Text("N/A").frame(width: 80, alignment: .leading)
                        }
                    }
                    
                    
                }
                if let batteryLevel = bleSensor.batteryLevel {
                    HStack {
                        Image(systemName: "battery.100.circle.fill")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .frame(width: 30, alignment: .leading)
                        BatteryView(batteryLevel: batteryLevel)
                            .frame(width: 80, height: 20, alignment: .center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                }
                if let wheelRPM = bleSensor.wheelRPM {
                    HStack {
                        Text("Wheel RPM").frame(width: 50, alignment: .leading)
                        Text("\(wheelRPM)").frame(width: 50, alignment: .center)
                    }
                }
                if let crankRPM = bleSensor.crankRPM {
                    HStack {
                        Text("Crank RPM").frame(width: 50, alignment: .leading)
                        Text("\(crankRPM)").frame(width: 50, alignment: .center)
                    }
                }
            }
        }
        .padding(10)
        .background(Color.blue)
        .cornerRadius(8)
        
    }
}

struct BatteryView: View {
    var batteryLevel: UInt8
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .foregroundColor(.gray)
                    Rectangle()
                        .frame(width: CGFloat(batteryLevel) / 100 * geometry.size.width, height: geometry.size.height)
                        .foregroundColor(batteryLevel < 20 ? .red : .green)
                        .padding(.trailing, 4)
                        
                }
                .cornerRadius(5)
                .overlay(
                    Text("\(batteryLevel)%")
                        .font(.headline)
                        .foregroundColor(.white)
                )
            }
        }
    }
}


struct BLESensorDataView_Previews: PreviewProvider {
    static var previews: some View {
        BLESensorDataView(bleSensor: BLESensorModelFactory.createHRSensor(sensorName: "Garmin Dual"))
        BLESensorDataView(bleSensor: BLESensorModelFactory.createPowerSensor(sensorName: "Garmin Vector 3"))
    }
}
