//
//  ProvidersListView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 8/24/21.
//

import SwiftUI
import Combine
import MyDataHelpsKit

struct ProviderConnectionSession: Identifiable {
    var id: ExternalAccountProvider.ID { authorization.providerID }
    let providerName: String
    let authorization: ExternalAccountAuthorization
}

struct ExternalAccountProviderPagedView: View {
    
    @AppStorage("settings_redirectURL") private var finalRedirectURLPreference: String = "linkprovideraccounts://sandbox"
    
    @EnvironmentObject private var messageBanner: MessageBannerModel
    
    @StateObject var model: PagedViewModel<ExternalAccountProvidersSource>
    
    @State private var searchText = ""
    @State private var newConnection: ProviderConnectionSession? = nil
    @State private var errorModel: ErrorView.Model? = nil
    private let searchTextPublisher = PassthroughSubject<String, Never>()
    
    var body: some View {
        PagedListView(model: model) { item in
            ExternalAccountProviderView(provider: item)
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            searchTextPublisher.send(searchText)
        }
        .onChange(of: searchText, perform: searchTextPublisher.send)
        .onReceive(searchTextPublisher.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)) { _ in
            applySearchText()
        }
        .onChange(of: model.selectedItem, perform: beginConnection)
        .sheet(item: $newConnection) { connection in
            ProviderConnectionAuthViewRepresentable(url: connection.authorization.authorizationURL, presentation: $newConnection)
        }
        .alert(item: $errorModel, content: {
            Alert(title: Text($0.error.localizedDescription))
        })
        // In a UIKit app, implement this in AppDelegate as part of `application(_:open:options:)` (for custom scheme URLs) or `application(_:continue:restorationHandler:)` (for Universal Links).
        .onOpenURL { url in
            if url.scheme == newConnection?.authorization.finalRedirectURL.scheme,
               let connection = newConnection,
               url.path() == connection.authorization.finalRedirectURL.path() {
                newConnection = nil
                model.selectedItem = nil
                messageBanner("Completed connection to \(connection.providerName)")
                NotificationCenter.default.post(name: ParticipantSession.participantDidUpdateNotification, object: nil)
            }
        }
    }
    
    private func applySearchText() {
        Task {
            await model.reset(newSource: model.source.withSearchText(searchText))
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
                let authorization = try await model.source.session.connectExternalAccount(providerID: provider.id, finalRedirectURL: finalRedirectURL)
                newConnection = ProviderConnectionSession(providerName: provider.name, authorization: authorization)
            } catch {
                errorModel = .init(title: "Error", error: MyDataHelpsError(error))
                newConnection = nil
                model.selectedItem = nil
            }
        }
    }
}

// Equatable conformance required for `.onChange(of: model.selectedItem)` above.
extension ExternalAccountProvider: Equatable {
    public static func == (lhs: ExternalAccountProvider, rhs: ExternalAccountProvider) -> Bool {
        lhs.id == rhs.id
    }
}

struct ProvidersListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExternalAccountProviderPagedView(model: ExternalAccountProvidersQuery(limit: 25).pagedListViewModel(ParticipantSessionPreview()))
            .navigationTitle("External Providers")
        }
        .banner()
        
        NavigationStack {
            ExternalAccountProviderPagedView(model: ExternalAccountProvidersQuery(limit: 25).pagedListViewModel(ParticipantSessionPreview(empty: true)))
            .navigationTitle("External Providers")
        }
        .banner()
    }
}
