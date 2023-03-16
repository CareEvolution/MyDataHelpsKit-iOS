//
//  MyDataHelpsKit_ExampleApp.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI

@main
struct MyDataHelpsKit_ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SessionModel())
        }
    }
}
