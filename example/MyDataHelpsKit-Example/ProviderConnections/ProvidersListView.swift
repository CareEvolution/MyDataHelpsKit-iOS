//
//  ProvidersListView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 8/24/21.
//

import SwiftUI
import MyDataHelpsKit

extension ExternalAccountAuthorization: Identifiable {
    public var id: ExternalAccountProvider.ID { provider.id }
}

extension ExternalAccountProvidersQuery {
    @MainActor func pagedListViewModel(_ session: ParticipantSessionType) -> PagedViewModel<ExternalAccountProvidersSource> {
        PagedViewModel(source: ExternalAccountProvidersSource(session: session, query: self))
    }
}

struct ExternalAccountProviderView: View {
    let provider: ExternalAccountProvider
    
    var body: some View {
        HStack(alignment: .center) {
            if let logoURL = provider.logoURL {
                AsyncImage(url: logoURL) { image in
                    image.resizable()
                } placeholder: {
                    Image.logoPlaceholder()
                }
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
    @StateObject var model: PagedViewModel<ExternalAccountProvidersSource>
    @State private var newConnection: ExternalAccountAuthorization?
    @State private var errorModel: ErrorView.Model?
    
    var body: some View {
        PagedListView(model: model) { item in
            ExternalAccountProviderView(provider: item)
        }
        .sheet(item: $newConnection) { connection in
            ProviderConnectionAuthViewRepresentable(url: connection.authorizationURL, presentation: $newConnection)
        }
        .alert(item: $errorModel, content: {
            Alert(title: Text($0.error.localizedDescription))
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
        
        Task {
            do {
                newConnection = try await session.connectExternalAccount(provider: provider, finalRedirectURL: finalRedirectURL)
            } catch {
                errorModel = .init(title: "Error", error: MyDataHelpsError(error))
                newConnection = nil
                model.selectedItem = nil
            }
        }
    }
}

struct ExternalAccountProvidersResultPageViewModel: PageModelType {
    let page: ExternalAccountProvidersResultPage
    let query: ExternalAccountProvidersQuery
    
    /// For compatibility with PagedListView; just indicates whether there is another page to load. The query itself uses numeric `pageNumber` instead of `nextPageID`.
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
    
    func loadPage(after page: ExternalAccountProvidersResultPageViewModel?) async throws -> ExternalAccountProvidersResultPageViewModel? {
        if let query = query(after: page) {
            let result = try await session.queryExternalAccountProviders(query)
            return .init(page: result, query: query)
        } else {
            return nil
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

struct ProvidersListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PagedListView(model: ExternalAccountProvidersQuery(limit: 25).pagedListViewModel(ParticipantSessionPreview())) { item in
                ExternalAccountProviderView(provider: item)
            }
            .navigationTitle("External Providers")
        }
    }
}
