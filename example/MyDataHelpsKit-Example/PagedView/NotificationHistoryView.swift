//
//  NotificationHistoryView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct NotificationHistoryView: View {
    static func pageView(session: ParticipantSessionType) -> PagedView<NotificationHistorySource, NotificationHistoryView> {
        let source = NotificationHistorySource(session: session, query: .init())
        return PagedView(model: .init(source: source) { item in
            NotificationHistoryView(model: item)
        })
    }
    
    struct Model: Identifiable {
        let id: String
        let identifier: String
        let sentDate: Date
        let statusCode: NotificationSendStatusCode
        let content: String?
    }
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .medium
        return df
    }()
    
    let model: Model
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(model.content ?? "(no content)")
            Text(model.identifier).font(.footnote)
            HStack {
                Text(model.statusCode.rawValue)
                Text("•")
                Text(Self.dateFormatter.string(from: model.sentDate))
            }.font(.footnote)
            .foregroundColor(Color(.systemGray))
        }
    }
}

extension NotificationHistoryView.Model {
    init(item: NotificationHistoryModel) {
        self.id = item.id
        self.identifier = item.identifier
        self.sentDate = item.sentDate
        self.statusCode = item.statusCode
        
        // Demonstrating various ways to access the type and content of the notification model
        switch item.content {
        case .sms:
            self.content = "Text notification"
        case let .push(content):
            self.content = "\(item.content.type.rawValue): \(content?.title ?? "(no title)")"
        case let .email(.some(content)):
            self.content = "Email: \(content.subject ?? "(no subject)")"
        case .email(.none):
            self.content = "Email (unsent)"
        }
    }
}

struct NotificationHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationHistoryView(model: .init(id: "1", identifier: "NOTIFICATION_A", sentDate: Date(), statusCode: .succeeded, content: "Title Text"))
            .padding()
    }
}
