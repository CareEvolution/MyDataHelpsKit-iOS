//
//  MyDataHelpsKit_ExampleApp.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI

@main
struct MyDataHelpsKit_ExampleApp: App {
    @StateObject var sessionModel = SessionModel()
    
    var body: some Scene {
        WindowGroup {
            if let session = sessionModel.session {
                ContentView(session: session)
                    .environmentObject(sessionModel)
            } else {
                NavigationStack {
                    TokenView()
                        .navigationTitle("Example App")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .environmentObject(sessionModel)
            }
        }
    }
}
