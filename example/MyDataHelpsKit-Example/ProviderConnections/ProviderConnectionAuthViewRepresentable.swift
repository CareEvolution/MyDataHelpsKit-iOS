//
//  ProviderConnectionAuthViewRepresentable.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 8/26/21.
//

import SwiftUI
import MyDataHelpsKit
import SafariServices

/// This is a SwiftUI wrapper for SFSafariViewController, used for presenting a provider connection authorization flow to the user. This view is constructed using the `authorizationURL` property of an ``ExternalAccountAuthorization`` object produced by ParticipantSession's `connectExternalAccount` function.
///
/// See `ParticipantSession.connectExternalAccount` documentation for details.
struct ProviderConnectionAuthViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = SFSafariViewController
    
    let url: URL
    var presentation: Binding<ExternalAccountAuthorization?>
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safari = SFSafariViewController(url: url)
        safari.dismissButtonStyle = .cancel
        return safari
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}
