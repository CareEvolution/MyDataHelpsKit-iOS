//
//  ExternalAccountsListView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 8/25/21.
//

import SwiftUI
import MyDataHelpsKit

extension ExternalAccount: Identifiable { }

class ExternalAccountsListViewModel: ObservableObject {
    let session: ParticipantSessionType
    @Published var accounts: Result<[ExternalAccount], MyDataHelpsError>?
    
    init(session: ParticipantSessionType) {
        self.session = session
        self.accounts = nil
        self.reload()
    }
    
    #if DEBUG
    init(session: ParticipantSessionType, result: Result<[ExternalAccount], MyDataHelpsError>) {
        self.session = session
        self.accounts = result
    }
    #endif
    
    func reload() {
        session.listExternalAccounts {
            self.accounts = $0
        }
    }
    
    func refresh(account: ExternalAccount) {
        session.refreshExternalAccount(account) { [weak self] _ in
            self?.reload()
        }
    }
    
    func delete(account: ExternalAccount) {
        session.deleteExternalAccount(account) { [weak self] _ in
            self?.reload()
        }
    }
}

struct ExternalAccountsListView: View {
    @StateObject var model: ExternalAccountsListViewModel
    
    var body: some View {
        Group {
            switch model.accounts {
            case .none:
                ProgressView()
            case let .some(.failure(error)):
                List {
                    ErrorView(model: .init(title: "Failed to load accounts", error: error))
                }
            case let .some(.success(accounts)) where accounts.isEmpty:
                List {
                    Text("No connected accounts")
                }
            case let .some(.success(accounts)):
                List(accounts) { account in
                    ExternalAccountView(account: account, listModel: model)
                }
            }
        }
        .navigationBarItems(trailing: NavigationLink(destination:
            ProvidersListView(model: ProvidersListViewModel(session: model.session))
                .navigationTitle("External Account Providers"), label: {
            Image(systemName: "plus")
        }))
    }
}

struct ExternalAccountView: View {
    let account: ExternalAccount
    let listModel: ExternalAccountsListViewModel
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    var body: some View {
        HStack(alignment: .center) {
            if let logoUrl = account.provider.logoUrl {
                RemoteImageView(url: logoUrl, placeholderImageName: "providerLogoPlaceholder")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 45, height: 45)
            }
            VStack(alignment: .leading) {
                Text(account.provider.name)
                    .font(.body)
                    .fontWeight(.semibold)
                Text(account.status.rawValue)
                    .font(.caption)
                if let lastRefreshDate = account.lastRefreshDate {
                    Text(Self.dateFormatter.string(from: lastRefreshDate))
                        .font(.caption)
                }
            }
            Button(action: {
                listModel.refresh(account: account)
            }, label: {
                Image(systemName: "arrow.clockwise")
            }).disabled(account.status == .fetchingData)
            Button(action: {
                listModel.delete(account: account)
            }, label: {
                Image(systemName: "trash")
            }).accentColor(.red)
        }
    }
}

struct ExternalAccountsListView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalAccountView(account: ExternalAccount.previewList[0], listModel: ExternalAccountsListViewModel(session: ParticipantSessionPreview(), result: .success([])))
            .padding()
            .previewLayout(.sizeThatFits)
            .environmentObject(RemoteImageCache())
        NavigationView {
            ExternalAccountsListView(model: .init(session: ParticipantSessionPreview()))
                .navigationTitle("External Accounts")
                .environmentObject(RemoteImageCache())
        }
        NavigationView {
            ExternalAccountsListView(model: .init(session: ParticipantSessionPreview(), result: .success(ExternalAccount.previewList)))
                .navigationTitle("External Accounts")
                .environmentObject(RemoteImageCache())
        }
        NavigationView {
            ExternalAccountsListView(model: .init(session: ParticipantSessionPreview(), result: .success([])))
                .navigationTitle("External Accounts")
                .environmentObject(RemoteImageCache())
        }
        NavigationView {
            ExternalAccountsListView(model: .init(session: ParticipantSessionPreview(), result: .failure(.unknown(nil))))
                .navigationTitle("External Accounts")
                .environmentObject(RemoteImageCache())
        }
    }
}
