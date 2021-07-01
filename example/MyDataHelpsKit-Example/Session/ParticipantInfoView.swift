//
//  ParticipantInfoView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct ParticipantInfoViewModel {
    let name: String
    let linkIdentifier: String?
    let email: String?
    let phone: String?
}

extension ParticipantInfoViewModel {
    init(info: ParticipantInfo) {
        var tokens = [info.demographics.firstName, info.demographics.lastName]
        if tokens.isEmpty { tokens = ["(no name)"] }
        self.name = tokens.compactMap { $0 }.joined(separator: " ")
        self.linkIdentifier = info.linkIdentifier
        self.email = info.demographics.email
        self.phone = info.demographics.mobilePhone
    }
}

struct ParticipantInfoView: View {
    let model: ParticipantInfoViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(model.name)
                .font(.headline)
            if let email = model.email {
                Text(email)
            }
            if let phone = model.phone {
                Text(phone)
            }
        }
        .font(.caption)
    }
}

struct ParticipantInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantInfoView(
            model: .init(
                name: "Firstname Lastname",
                linkIdentifier: nil,
                email: nil,
                phone: "555-555-1212"))
    }
}
