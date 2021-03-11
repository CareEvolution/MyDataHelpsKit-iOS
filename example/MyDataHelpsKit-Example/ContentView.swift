//
//  ContentView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct ContentView: View {
    @EnvironmentObject var sessionModel: SessionModel
    
    var body: some View {
        NavigationView {
            if let session = sessionModel.session {
                RootMenuView(participant: .init(session: session))
                    .navigationTitle(title)
                    .navigationBarItems(trailing: Button("Log Out", action: logOut))
            } else {
                VStack(alignment: .leading) {
                    Text("Log In")
                        .font(.headline)
                    TokenView()
                }.padding()
                .navigationTitle(title)
            }
        }
    }
    
    var title: String {
        "MyDataHelpsKit v\(MyDataHelpsClient.SDKVersion)"
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
