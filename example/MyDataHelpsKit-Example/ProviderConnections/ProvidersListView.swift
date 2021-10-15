//
//  ProvidersListView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 8/24/21.
//

import SwiftUI
import MyDataHelpsKit

extension ExternalAccountProvider: Identifiable {
}

extension ExternalAccountAuthorization: Identifiable {
    public var id: Int { provider.id }
}

class ProvidersListViewModel: ObservableObject {
    private let session: ParticipantSessionType
    let query: ExternalAccountProvidersQuery
    @Published var providers: Result<[ExternalAccountProvider], MyDataHelpsError>?
    
    @AppStorage("settings_redirectURL") private var finalRedirectURLPreference: String = "linkprovideraccounts://sandbox"
    
    init(session: ParticipantSessionType) {
        self.session = session
        /// EXERCISE: Set non-nil `search` and `category` values to customize filtering providers.
        self.query = ExternalAccountProvidersQuery(search: nil, category: nil)
        self.providers = nil
        session.queryExternalAccountProviders(query) {
            self.providers = $0
        }
    }
    
    func connect(_ provider: ExternalAccountProvider, completion: @escaping (Result<ExternalAccountAuthorization, MyDataHelpsError>) -> Void) {
        guard let finalRedirectURL = URL(string: finalRedirectURLPreference) else {
            return
        }
        session.connectExternalAccount(provider: provider, finalRedirectURL: finalRedirectURL, completion: completion)
    }
}

struct ProvidersListView: View {
    @StateObject var model: ProvidersListViewModel
    @State private var newConnection: ExternalAccountAuthorization?
    @State private var errorModel: ErrorView.Model?
    
    var body: some View {
        Group {
            switch model.providers {
            case .none:
                ProgressView()
            case let .some(.failure(error)):
                List {
                    ErrorView(model: .init(title: "Failed to load providers", error: error))
                }
            case let .some(.success(providers)) where providers.isEmpty:
                List {
                    Text("No providers found")
                }
            case let .some(.success(providers)):
                List(providers) { provider in
                    ExternalAccountProviderView(provider: provider)
                        .onTapGesture { connect(provider) }
                }
            }
        }
        .sheet(item: $newConnection) { connection in
            ProviderConnectionAuthViewRepresentable(url: connection.authorizationURL, presentation: $newConnection)
        }
        .alert(item: $errorModel, content: {
            Alert(title: Text($0.errorDescription))
        })
        // In a UIKit app, implement this in AppDelegate as part of `application(_:open:options:)` (for custom scheme URLs) or `application(_:continue:restorationHandler:)` (for Universal Links).
        .onOpenURL { url in
            if url.scheme == newConnection?.finalRedirectURL.scheme,
               url.path == newConnection?.finalRedirectURL.path {
                newConnection = nil
            }
        }
    }
    
    private func connect(_ provider: ExternalAccountProvider) {
        guard newConnection == nil else { return }
        errorModel = nil
        model.connect(provider) {
            switch $0 {
            case let .success(connection):
                newConnection = connection
            case let .failure(error):
                errorModel = .init(title: "Error", error: error)
            }
        }
    }
}

struct ExternalAccountProviderView: View {
    let provider: ExternalAccountProvider
    
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

struct ProvidersListView_Previews: PreviewProvider {
    private static var model: ProvidersListViewModel {
        ProvidersListViewModel(session: ParticipantSessionPreview())
    }
    
    static var previews: some View {
        NavigationView {
            ProvidersListView(model: Self.model)
                .navigationTitle("External Providers")
                .environmentObject(RemoteImageCache())
        }
    }
}
