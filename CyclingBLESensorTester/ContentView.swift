//
//  ContentView.swift
//  CyclingBLESensorTester
//
//  Created by JB Baudens on 4/5/23.
//

import SwiftUI
import Charts

struct ContentView<T:BLEViewModelProtocol>: View {
    @ObservedObject private var bleViewModel: T
    
    init(bleViewModel: T) {
        self.bleViewModel = bleViewModel
    }
    
    var body: some View {
        ZStack {
            Color.gray.edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    HStack {
                        Text("BLE central: ")
                        Text(bleViewModel.centralSwitchOn ? "ON" : "OFF")
                            .foregroundColor(bleViewModel.centralSwitchOn ? .green : .red)
                        Text("# of sensors: ")
                        Text(String(bleViewModel.sensors.count))
                        Text("Scanning: ")
                        Text(bleViewModel.isScanning ? "ON" : "OFF")
                            .foregroundColor(bleViewModel.isScanning ? .green : .red)
                    }
                    HStack {
                        Button(action: {
                            bleViewModel.scan()
                        }) {
                            Text("Scan")
                        }.disabled(bleViewModel.isScanning)
                        Button(action: {
                            bleViewModel.stopScan()
                        }) {
                            Text("Stop Scan")
                        }.disabled(!bleViewModel.isScanning)
                    }
                }.padding(10)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(bleViewModel.sensors.sorted{$0.key.uuidString < $1.key.uuidString}, id: \.key) { key, value in
                            BLESensorDataView(bleSensor: value)
                        }
                    }
                }.padding(10)
                
                Chart(bleViewModel.hrData, id: \.date) {
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Value", $0.hr)
                    )
                    .foregroundStyle(by: .value("Sensor", $0.sensorName))
                }.padding(10)
                
                Chart(bleViewModel.powerData, id: \.date) {
                    LineMark(
                        x: .value("Date", $0.date),
                        y: .value("Value", $0.power)
                    )
                    .foregroundStyle(by: .value("Sensor", $0.sensorName))
                }.padding(10)
                
            }
        }
        .foregroundColor(.white)
        .frame(width: 1800, height: 900)
        .padding(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    class BLEViewModelMock : BLEViewModelProtocol {
        
        
        var centralSwitchOn: Bool = true
        var isScanning: Bool = false
        var sensors: [UUID : BLESensorModel]
        var hrData: [HRData]
        var powerData: [PowerData]
        
        func combineData() {
            for (_, sensor) in sensors {
                hrData += sensor.hrData
                powerData += sensor.powerData
            }
        }
        
        init() {
            sensors =  [UUID : BLESensorModel]()
            
            sensors[UUID()] = BLESensorModelFactory.createHRSensor(sensorName: "Wahoo TICKR")
            sensors[UUID()] = BLESensorModelFactory.createHRSensor(sensorName: "Garmin HRDual")
            sensors[UUID()] = BLESensorModelFactory.createPowerSensor(sensorName: "Garmin Vector 3")
            sensors[UUID()] = BLESensorModelFactory.createPowerSensor(sensorName: "Quarq")
            
            hrData = [HRData]()
            powerData = [PowerData]()
            combineData()
        }
        
        func scan() {
        }
        
        func stopScan() {
        }
        
        func connect(sensorId: UUID) {
        }
    }
    
    
    static var previews: some View {
        ContentView(bleViewModel: BLEViewModelMock())
    }
}
