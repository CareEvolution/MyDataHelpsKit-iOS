//
//  MyDataHelpsClient.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 2/25/21.
//

import Foundation

/// Access to the MyDataHelps API endpoints. You can create a single instance of this for the lifetime of your app.
///
/// `MyDataHelpsClient` instances do not track the authentication state or identity of a participant. Use `ParticipantSession` in conjunction with `MyDataHelps` client to perform authenticated actions.
public final class MyDataHelpsClient {
    /// Version number for this release of MyDataHelpsKit.
    public static let SDKVersion = MyDataHelpsKitVersion
    
    /// Default base URL to use for MyDataHelps API requests.
    private static let defaultBaseURL = URL(string: "https://rkstudio.careevolution.com/ppt/")!
    private static let requestTimeoutInterval: TimeInterval = 30
    
    internal let baseURL: URL
    internal let userAgent: String
    
    /// Initializes a newly created client with the specified configuration.
    /// - Parameter baseURL: Optional. If specified, overrides the base URL to use for MyDataHelps API requests. Production apps should not supply this parameter, and use the default base URL.
    public init(baseURL: URL? = nil) {
        self.baseURL = baseURL ?? Self.defaultBaseURL
        self.userAgent = userAgentString()
    }
    
    internal func newUrlSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = Self.requestTimeoutInterval
        configuration.urlCache = nil
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: .main)
    }
    
    internal var languageTag: String {
        var acceptLanguage = Locale.current.languageCode ?? "en"
        if let regionCode = Locale.current.regionCode {
            acceptLanguage += "-\(regionCode)"
        }
        return acceptLanguage
    }
}

/// RFC 2616 User-Agent header string
fileprivate func userAgentString() -> String {
    let appBundle = Bundle.main
    let appIdentity = appBundle.bundleIdentifier ?? "UNKNOWN_CLIENT"
    let appVersionSuffix: String
    if let versionString = appBundle.infoDictionary?["CFBundleShortVersionString"] as? String {
        appVersionSuffix = "/\(versionString)"
    } else {
        appVersionSuffix = ""
    }
    let SDKInfo = "MyDataHelpsKit/\(MyDataHelpsClient.SDKVersion)"
    let deviceInfo = "\(getHardwareModelIdentifier() ?? "UNKNOWN_DEVICE") (\(getOSVersionString()))"
    return "\(appIdentity)\(appVersionSuffix) \(SDKInfo) \(deviceInfo)"
}
