//
//  ProviderConnectionAuthViewRepresentable.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 8/26/21.
//

import SwiftUI
import MyDataHelpsKit
import SafariServices

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
