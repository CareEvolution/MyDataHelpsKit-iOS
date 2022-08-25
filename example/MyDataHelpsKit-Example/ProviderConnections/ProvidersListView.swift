//
//  ProvidersListView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 8/24/21.
//

import SwiftUI
import MyDataHelpsKit

struct ExternalAccountProviderView: View {
    let provider: ExternalAccountProvider
    
    static func pageView(session: ParticipantSessionType, search: String?, category: ExternalAccountProviderCategory?) -> some View {
        let query = ExternalAccountProvidersQuery(search: search, category: category, limit: 25)
        let source = ExternalAccountProvidersSource(session: session, query: query)
        return ExternalAccountProviderPagedView(session: session, model: .init(source: source) { item in
            ExternalAccountProviderView(provider: item)
        })
    }
    
    var body: some View {
        HStack(alignment: .center) {
            if let logoURL = provider.logoURL {
                RemoteImageView(url: logoURL, placeholderImageName: "providerLogoPlaceholder")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 45, height: 45)
            }
            VStack(alignment: .leading) {
                Text(provider.name)
                    .font(.body)
                    .fontWeight(.semibold)
                Text(provider.category.rawValue)
                    .font(.caption)
            }
            Spacer()
            Image(systemName: "plus")
                .font(.subheadline)
                .foregroundColor(.accentColor)
        }
    }
}

struct ExternalAccountProviderPagedView: View {
    @AppStorage("settings_redirectURL") private var finalRedirectURLPreference: String = "linkprovideraccounts://sandbox"
    let session: ParticipantSessionType
    @StateObject var model: PagedViewModel<ExternalAccountProvidersSource, ExternalAccountProviderView>
    @State private var newConnection: ExternalAccountAuthorization?
    @State private var errorModel: ErrorView.Model?
    
    var body: some View {
        PagedView(model: model)
            .sheet(item: $newConnection) { connection in
                ProviderConnectionAuthViewRepresentable(url: connection.authorizationURL, presentation: $newConnection)
            }
            .alert(item: $errorModel, content: {
                Alert(title: Text($0.errorDescription))
            })
            // In a UIKit app, implement this in AppDelegate as part of `application(_:open:options:)` (for custom scheme URLs) or `application(_:continue:restorationHandler:)` (for Universal Links).
            .onChange(of: model.selectedItem, perform: beginConnection)
            .onOpenURL { url in
                if url.scheme == newConnection?.finalRedirectURL.scheme,
                   url.path == newConnection?.finalRedirectURL.path {
                    newConnection = nil
                    model.selectedItem = nil
                }
            }
    }
    
    private func beginConnection(_ provider: ExternalAccountProvider?) {
        guard let provider = provider, newConnection == nil else { return }
        errorModel = nil
        guard let finalRedirectURL = URL(string: finalRedirectURLPreference) else {
            return
        }
        
        session.connectExternalAccount(provider: provider, finalRedirectURL: finalRedirectURL) {
            switch $0 {
            case let .success(connection):
                newConnection = connection
            case let .failure(error):
                errorModel = .init(title: "Error", error: error)
                newConnection = nil
                model.selectedItem = nil
            }
        }
    }
}

struct ExternalAccountProvidersResultPageViewModel: PageModelType {
    let page: ExternalAccountProvidersResultPage
    let query: ExternalAccountProvidersQuery
    
    /// For compatibility with PagedView; just indicates whether there is another page to load. The query itself uses numeric `pageNumber` instead of `nextPageID`.
    var nextPageID: ScopedIdentifier<ExternalAccountProvidersResultPageViewModel, String>? {
        if query.page(after: page) == nil {
            return nil
        } else {
            return .init("next")
        }
    }
    
    func pageItems(session: ParticipantSessionType) -> [ExternalAccountProvider] {
        page.externalAccountProviders
    }
}

class ExternalAccountProvidersSource: PagedModelSource {
    let session: ParticipantSessionType
    private let query: ExternalAccountProvidersQuery
    
    init(session: ParticipantSessionType, query: ExternalAccountProvidersQuery) {
        self.session = session
        self.query = query
    }
    
    func loadPage(after result: ExternalAccountProvidersResultPageViewModel?, completion: @escaping (Result<ExternalAccountProvidersResultPageViewModel, MyDataHelpsError>) -> Void) {
        if let query = query(after: result) {
            session.queryExternalAccountProviders(query) { result in
                completion(result.map { .init(page: $0, query: query) })
            }
        }
    }
    
    private func query(after result: ExternalAccountProvidersResultPageViewModel?) -> ExternalAccountProvidersQuery? {
        if let result = result {
            return query.page(after: result.page)
        } else {
            return query
        }
    }
}

// Equatable conformance required for `.onChange(of: model.selectedItem)` below.
extension ExternalAccountProvider: Equatable {
    public static func == (lhs: ExternalAccountProvider, rhs: ExternalAccountProvider) -> Bool {
        lhs.id == rhs.id
    }
}

// Identifiable conformance required for `.sheet(item: $newConnection)` below.
extension ExternalAccountAuthorization: Identifiable {
    public var id: ExternalAccountProvider.ID { provider.id }
}

struct ProvidersListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExternalAccountProviderView.pageView(session: ParticipantSessionPreview(), search: nil, category: nil)
                .navigationTitle("External Providers")
        }
        .environmentObject(RemoteImageCache())
    }
}
