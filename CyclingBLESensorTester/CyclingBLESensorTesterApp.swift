//
//  CyclingBLESensorTesterApp.swift
//  CyclingBLESensorTester
//
//  Created by JB Baudens on 4/5/23.
//

import SwiftUI

@main
struct CyclingBLESensorTesterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(bleViewModel: BLEViewModel())
        }
    }
}
