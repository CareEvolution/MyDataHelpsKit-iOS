//
//  TokenView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct TokenView: View {
    @EnvironmentObject private var sessionModel: SessionModel
    @EnvironmentObject private var messageBanner: MessageBannerModel
    
    private let documentationURL = URL(string: "https://developer.mydatahelps.org/embeddables/participant_tokens.html")!
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("MyDataHelpsKit v\(MyDataHelpsClient.SDKVersion)")
                        .font(.headline)
                        .padding(.bottom)
                    Text("To get started with this example app, you need a participant access token. Paste a participant access token below to initialize the app with a ParticipantSession and access views that demonstrate the functionality provided by MyDataHelpsKit.\n\nSee MyDataHelpsKit documentation for more information.")
                        .font(.subheadline)
                    Link(destination: documentationURL) {
                        Label("Participant Token Documentation", systemImage: "safari")
                    }
                    .font(.subheadline)
                    .padding(.top)
                }
                .padding(.bottom)
            }
            
            Spacer()
            
            GroupBox("Participant access token:") {
                HStack {
                    TextField("Token", text: $sessionModel.token)
                        .textFieldStyle(.roundedBorder)
                    Button(action: useToken, label: {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                    })
                    .disabled(sessionModel.token.isEmpty)
                    .buttonStyle(.borderedProminent)
                }
            }
        }.padding(.horizontal)
    }
    
    private func useToken() {
        Task {
            do {
                try await sessionModel.authenticate()
            } catch {
                messageBanner(MyDataHelpsError(error).localizedDescription)
            }
        }
    }
}

struct TokenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TokenView()
                .navigationTitle("Example App")
                .environmentObject(SessionModel())
        }
        .banner()
    }
}
