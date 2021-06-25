//
//  ContentView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionModel: SessionModel
    
    var body: some View {
        NavigationView {
            if let session = sessionModel.session {
                RootMenuView(participant: .init(session: session))
                    .navigationTitle("Example App")
                    .navigationBarItems(trailing: Button("Log Out", action: logOut))
            } else {
                TokenView()
                    .navigationTitle("Example App")
            }
        }
    }
    
    private func logOut() {
        sessionModel.logOut()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionModel())
    }
}
