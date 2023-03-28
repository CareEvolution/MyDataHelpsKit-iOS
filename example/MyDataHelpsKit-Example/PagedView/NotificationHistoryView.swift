//
//  NotificationHistoryView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

extension NotificationHistoryQuery {
    @MainActor func pagedListViewModel(_ session: ParticipantSessionType) -> PagedViewModel<NotificationHistorySource> {
        PagedViewModel(source: NotificationHistorySource(session: session, query: self))
    }
}

struct NotificationHistoryView: View {
    struct Model: Identifiable {
        let id: NotificationHistoryModel.ID
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
            /// EXERCISE: Add or modify `Text` views here to see the values of other `NotificationHistoryModel` properties.
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
        
        /// Demonstrating various ways to access the type and content of the notification model. Each switch case is written differently to show different Swift idioms for working with the NotificationContent enum. Your app can use whatever level of complexity is appropriate.
        /// EXERCISE: modify this switch statement to customize `self.content` with the NotificationContent details your project uses.
        switch item.content {
        /// The simplest option if you just need to know the type of notification.
        case .sms:
            self.content = "Text notification"
        /// Handle inner `content` var may or may not be nil, depending on whether the notification sent successfully.
        case let .push(content):
            self.content = "\(item.content.type.rawValue): \(content?.title ?? "(no title)")"
        /// This pattern requires a specific notification type, _and_ a successfully sent notification (non-nil content).
        case let .email(.some(content)):
            self.content = "Email: \(content.subject ?? "(no subject)")"
        /// Matches a specific type with _nil_ content (notification not sent).
        case .email(.none):
            self.content = "Email (unsent)"
        }
    }
}

struct NotificationHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationHistoryView(model: .init(id: .init("n1"), identifier: "NOTIFICATION_A", sentDate: Date(), statusCode: .succeeded, content: "Title Text"))
            .padding()
    }
}
