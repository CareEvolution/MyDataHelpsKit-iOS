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
}

extension ParticipantInfoViewModel {
    init(info: ParticipantInfo) {
        var tokens = [info.demographics.firstName, info.demographics.lastName]
        if tokens.isEmpty { tokens = ["(no name)"] }
        self.name = tokens.compactMap { $0 }.joined(separator: " ")
        self.email = info.demographics.email
        self.phone = info.demographics.mobilePhone
        self.enrollmentDate = info.enrollmentDate
    }
}

struct ParticipantInfoView: View {
    let model: ParticipantInfoViewModel
    
    private static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
    
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
            if let enrollmentDate = model.enrollmentDate {
                Text("Enrolled \(Self.dateFormatter.string(from: enrollmentDate))")
            }
        }
        .font(.caption)
    }
}

struct ParticipantInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantInfoView(
            model: .init(
                name: "FirstName LastName",
                email: nil,
                phone: "555-555-1212",
                enrollmentDate: Date().addingTimeInterval(-86400)))
    }
}
