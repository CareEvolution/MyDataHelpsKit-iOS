//
//  NotificationHistory.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 3/22/21.
//

import Foundation

/// Specifies filtering and page-navigation criteria for participant notification queries.
///
/// All query properties are optional. Set non-nil/non-default values only for the properties you want to use for filtering.
public struct NotificationHistoryQuery: PagedQuery {
    /// The default and maximum number of results per page.
    public static let defaultLimit = 100
    
    /// Name of the configured notification.
    public let identifier: String?
    /// Notifications sent after this date.
    public let sentAfter: Date?
    /// Notifications sent before this date.
    public let sentBefore: Date?
    /// Type of notification.
    public let type: NotificationType?
    /// Describes whether the notification was sent.
    public let statusCode: NotificationSendStatusCode?
    
    /// Maximum number of results per page. Default and maximum value is 100.
    public let limit: Int
    /// Identifies a specific page of notifications to fetch. Use `nil` to fetch the first page of results. To fetch the page following a given `NotificationHistoryPage` use its `nextPageID`; the other parameters should be the same as the original `NotificationHistoryQuery`.
    public let pageID: NotificationHistoryPage.PageID?
    
    /// Initializes a new query for a page of notifications with various filters.
    /// - Parameters:
    ///   - identifier: Name of the configured notification.
    ///   - sentAfter: Notifications sent after this date.
    ///   - sentBefore: Notifications sent before this date.
    ///   - type: Type of notification.
    ///   - statusCode: Describes whether the notification was sent.
    ///   - limit: Maximum number of results per page.
    ///   - pageID: Identifies a specific page of notifications to fetch.
    public init(identifier: String? = nil, sentAfter: Date? = nil, sentBefore: Date? = nil, type: NotificationType? = nil, statusCode: NotificationSendStatusCode? = nil, limit: Int = defaultLimit, pageID: NotificationHistoryPage.PageID? = nil) {
        self.identifier = identifier
        self.sentAfter = sentAfter
        self.sentBefore = sentBefore
        self.type = type
        self.statusCode = statusCode
        self.limit = Self.clampedLimit(limit, max: Self.defaultLimit)
        self.pageID = pageID
    }
    
    /// Initializes a new query for a page of results following the given page, with the same filters as the original query.
    /// - Parameter page: The previous page of results, which should have been produced with this query.
    /// - Returns: A query for results following `page`, if page has a `nextPageID`. If there are no additional pages of results available, returns `nil`. The query returned, if any, has the same filters as the original.
    public func page(after page: NotificationHistoryPage) -> NotificationHistoryQuery? {
        guard let nextPageID = page.nextPageID else { return nil }
        return NotificationHistoryQuery(identifier: identifier, sentAfter: sentAfter, sentBefore: sentBefore, type: type, statusCode: statusCode, limit: limit, pageID: nextPageID)
    }
}

/// A page of notifications.
public struct NotificationHistoryPage: PagedResult, Decodable {
    /// Identifies a specific page of notifications.
    public typealias PageID = ScopedIdentifier<NotificationHistoryPage, String>
    /// A list of notifications filtered by the query criteria, ordered by date.
    public let notifications: [NotificationHistoryModel]
    /// An ID to be used with subsequent `NotificationHistoryQuery` requests. Results from queries using this ID as the `pageID` parameter will show the next page of results. `nil` if there isn't a next page.
    public let nextPageID: PageID?
}

/// The type of notification sent to a participant.
public enum NotificationType: String, Decodable {
    /// SMS (text message) notification.
    case sms = "Sms"
    /// Push notification sent to a mobile app.
    case push = "Push"
    /// Email.
    case email = "Email"
}

/// Describes whether a notification was sent to a participant.
public struct NotificationSendStatusCode: RawRepresentable, Equatable, Decodable {
    public typealias RawValue = String
    
    /// The notification was sent. This does not guarantee it was received nor read.
    public static let succeeded = NotificationSendStatusCode(rawValue: "Succeeded")
    /// The notification could not be sent because the recipient unsubscribed their contact info from notifications.
    public static let unsubscribed = NotificationSendStatusCode(rawValue: "Unsubscribed")
    /// The notification could not be sent because contact info was not available.
    public static let missingContactInfo = NotificationSendStatusCode(rawValue: "MissingContactInfo")
    /// The notification could not be sent because a verified mobile device was not available.
    public static let noRegisteredMobileDevice = NotificationSendStatusCode(rawValue: "NoRegisteredMobileDevice")
    /// The notification could not be sent because the participant has not registered an account on MyDataHelps.
    public static let noAssociatedUser = NotificationSendStatusCode(rawValue: "NoAssociatedUser")
    /// The notification was not sent due to an error.
    public static let serviceError = NotificationSendStatusCode(rawValue: "serviceError")
    
    /// The raw value for the status code as stored in MyDataHelps.
    public let rawValue: String
    
    /// Initializes a `NotificationSendStatusCode` with an arbitrary value. Consider using static members such as `NotificationSendStatusCode.succeeded` instead for known values.
    /// - Parameter rawValue: The raw value for the status code as stored in MyDataHelps.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// The content of a notification, varying based on the type of the notification. The actual content is in the enum associated value, and may be nil.
public enum NotificationContent {
    /// The content of an SMS notification.
    case sms(SMSContent?)
    /// The content of a push notification.
    case push(PushContent?)
    /// The content of an email notification.
    case email(EmailContent?)
    
    /// The notification type.
    public var type: NotificationType {
        switch self {
        case .sms: return .sms
        case .push: return .push
        case .email: return .email
        }
    }
    
    /// The content of an SMS notification.
    public struct SMSContent: Decodable {
        enum CodingKeys: String, CodingKey {
            case body
        }
        
        /// The content of the notification.
        public let body: String?
    }
    
    /// The content of a push notification.
    public struct PushContent: Decodable {
        enum CodingKeys: String, CodingKey {
            case title
            case body
        }
        
        /// The title of the notification.
        public let title: String?
        /// The content of the notification.
        public let body: String?
    }
    
    /// The content of an email notification.
    public struct EmailContent: Decodable {
        enum CodingKeys: String, CodingKey {
            case subject
        }
        
        /// The subject line of the email. The content of the email is not available.
        public let subject: String?
    }
}

/// Information about a notification for a participant.
public struct NotificationHistoryModel: Identifiable, Decodable {
    /// Auto-generated, globally-unique identifier for a NotificationHistoryModel.
    public typealias ID = ScopedIdentifier<NotificationHistoryModel, String>
    
    enum CodingKeys: String, CodingKey {
        case id
        case identifier
        case sentDate
        case statusCode
        case type
        case content
    }
    
    /// Auto-generated, globally-unique identifier for this notification.
    public let id: ID
    /// Identifier for the notification configuration.
    public let identifier: String
    /// If the notification was sent, the date at which the notification was sent.
    public let sentDate: Date
    /// Describes whether the notification was sent.
    public let statusCode: NotificationSendStatusCode
    
    /// The content of the notification, varying by the notification type.
    ///
    /// Use `content.type` to determine the `NotificationType` value. The associated enum value of `content` contains the actual content, and may be nil if the notification was not sent successfully.
    public let content: NotificationContent
    
    /// Initializes from a decoder.
    /// - Parameter decoder: The decoder.
    /// - Throws: DecodingError on failure to decode.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(ID.self, forKey: .id)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.sentDate = try container.decode(Date.self, forKey: .sentDate)
        self.statusCode = try container.decode(NotificationSendStatusCode.self, forKey: .statusCode)
        
        switch try container.decode(NotificationType.self, forKey: .type) {
        case .sms:
            let content = try container.decodeIfPresent(NotificationContent.SMSContent.self, forKey: .content)
            self.content = .sms(content)
        case .push:
            let content = try container.decodeIfPresent(NotificationContent.PushContent.self, forKey: .content)
            self.content = .push(content)
        case .email:
            let content = try container.decodeIfPresent(NotificationContent.EmailContent.self, forKey: .content)
            self.content = .email(content)
        }
    }
}
