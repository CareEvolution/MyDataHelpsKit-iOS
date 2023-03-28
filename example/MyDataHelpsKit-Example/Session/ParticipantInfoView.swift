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
    let email: String?
    let phone: String?
    let enrollmentDate: Date?
    let isUnsubscribedFromEmails: Bool
}

extension ParticipantInfoViewModel {
    init(info: ParticipantInfo) {
        let tokens = [info.demographics.firstName, info.demographics.lastName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        if tokens.isEmpty {
            self.name = "(no name)"
        } else {
            self.name = tokens.joined(separator: " ")
        }
        self.email = info.demographics.email
        self.phone = info.demographics.mobilePhone
        self.enrollmentDate = info.enrollmentDate
        self.isUnsubscribedFromEmails = info.demographics.isUnsubscribedFromEmails
    }
}

struct ParticipantInfoView: View {
    let model: ParticipantInfoViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(model.name)
                .font(.headline)
                .padding(.bottom, 2)
            if let email = model.email {
                Label(email, systemImage: model.isUnsubscribedFromEmails ? "slash.circle" : "checkmark.circle")
            }
            if let phone = model.phone {
                Label(phone, systemImage: "phone")
            }
            if let enrollmentDate = model.enrollmentDate {
                Label("Enrolled \(enrollmentDate.formatted())", systemImage: "person.crop.circle.badge.checkmark")
            }
        }
        .font(.caption)
    }
}

struct ParticipantInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantInfoView(model: .init(
            name: "FirstName LastName",
            email: nil,
            phone: "555-555-1212",
            enrollmentDate: Date().addingTimeInterval(-86400),
            isUnsubscribedFromEmails: true))
    }
}
