//
//  TokenView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI

struct TokenView: View {
    @EnvironmentObject var sessionModel: SessionModel
    
    var body: some View {
        HStack {
            TextField("Participant Token", text: $sessionModel.token)
            Button(action: useToken, label: {
                Image(systemName: "person.crop.circle.badge.checkmark")
            })
        }
    }
    
    private func useToken() {
        sessionModel.authenticate()
    }
}

struct TokenView_Previews: PreviewProvider {
    static var previews: some View {
        TokenView()
            .environmentObject(SessionModel())
    }
}
