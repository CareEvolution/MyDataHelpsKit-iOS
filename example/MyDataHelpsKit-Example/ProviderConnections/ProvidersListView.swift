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

class ProvidersListViewModel: ObservableObject {
    struct NewConnection: Identifiable {
        let id: Int
        let authorizationURL: URL
        let finalRedirectURL: URL
    }
    
    private let session: ParticipantSessionType
    let query: ExternalAccountProvidersQuery
    @Published var providers: [ExternalAccountProvider]
    
    @AppStorage("settings_redirectURL") private var finalRedirectURLPreference: String = ""
    
    init(session: ParticipantSessionType) {
        self.session = session
        self.query = .init()
        self.providers = []
        session.queryExternalAccountProviders(query) {
            switch $0 {
            case let .success(list):
                self.providers = list.sorted(by: { $0.name < $1.name })
            case let .failure(error):
                print("error \(error)")
            }
        }
    }
    
    func connect(_ provider: ExternalAccountProvider, completion: @escaping (Result<ProvidersListViewModel.NewConnection, MyDataHelpsError>) -> Void) {
        guard let finalRedirectURL = URL(string: finalRedirectURLPreference) else {
            return
        }

        session.connectExternalAccount(provider: provider, finalRedirectURL: finalRedirectURL) {
            switch $0 {
            case let .success(url):
                completion(.success(.init(id: provider.id, authorizationURL: url, finalRedirectURL: finalRedirectURL)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

struct ProvidersListView: View {
    @StateObject var model: ProvidersListViewModel
    @State private var newConnection: ProvidersListViewModel.NewConnection?
    
    var body: some View {
        List(model.providers) { provider in
            ExternalAccountProviderView(provider: provider)
                .onTapGesture {
                    model.connect(provider) {
                        if case let .success(connection) = $0 {
                            newConnection = connection
                        }
                    }
                }
        }
        .sheet(item: $newConnection) { connection in
            ProviderConnectionViewRepresentable(url: connection.authorizationURL, presentation: $newConnection)
        }
        .onOpenURL { url in
            if url.scheme == newConnection?.finalRedirectURL.scheme,
               url.path == newConnection?.finalRedirectURL.path {
                newConnection = nil
            }
        }
    }
}

struct ExternalAccountProviderView: View {
    let provider: ExternalAccountProvider
    
    var body: some View {
        HStack(alignment: .center) {
            if let logoUrl = provider.logoUrl {
                RemoteImageView(url: logoUrl, placeholderImageName: "providerLogoPlaceholder")
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
