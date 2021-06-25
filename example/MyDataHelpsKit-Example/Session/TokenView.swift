//
//  TokenView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct TokenView: View {
    @EnvironmentObject var sessionModel: SessionModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("MyDataHelpsKit v\(MyDataHelpsClient.SDKVersion)")
                .font(.headline)
                .padding(.bottom)
            Text("To get started with this example app, you need a participant access token. Paste the participant access token below to initialize the app with a ParticipantSession and access views that demonstrate the functionality provided by MyDataHelpsKit.\n\nSee MyDataHelpsKit documentation for more information.")
                .font(.subheadline)
            Spacer()
            Text("Participant access token:")
                .font(.headline)
            HStack {
                TextField("Token", text: $sessionModel.token)
                Button(action: useToken, label: {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                })
            }
        }.padding()
    }
    
    private func useToken() {
        sessionModel.authenticate()
    }
}

struct TokenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TokenView()
                .navigationTitle("Example App")
                .environmentObject(SessionModel())
        }
    }
}
