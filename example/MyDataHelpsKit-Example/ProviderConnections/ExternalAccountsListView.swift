//
//  ExternalAccountsListView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 8/25/21.
//

import SwiftUI
import MyDataHelpsKit

extension ExternalAccount {
    var isRefreshable: Bool {
        status != .fetchingData
    }
}

@MainActor class ExternalAccountsListViewModel: ObservableObject {
    let session: ParticipantSessionType
    @Published var accounts: RemoteResult<[ExternalAccount]>
    
    init(session: ParticipantSessionType) {
        self.session = session
        self.accounts = .loading
        Task {
            await reload()
        }
    }
    
    #if DEBUG
    // For SwiftUI previews.
    init(session: ParticipantSessionType, result: RemoteResult<[ExternalAccount]>) {
        self.session = session
        self.accounts = result
    }
    #endif
    
    func reload() async {
        accounts = await RemoteResult(wrapping: try await session.listExternalAccounts())
    }
    
    func refresh(account: ExternalAccount) async throws {
        guard account.isRefreshable else { return }
        try await session.refreshExternalAccount(account)
        NotificationCenter.default.post(name: ParticipantSession.participantDidUpdateNotification, object: nil)
    }
    
    func delete(account: ExternalAccount) async throws {
        try await session.deleteExternalAccount(account)
        NotificationCenter.default.post(name: ParticipantSession.participantDidUpdateNotification, object: nil)
    }
}

struct ExternalAccountsListView: View {
    @EnvironmentObject private var messageBanner: MessageBannerModel
    
    @StateObject var model: ExternalAccountsListViewModel
    @State private var selected: ExternalAccount?
    
    var body: some View {
        List {
            Section {
                AsyncCardView(result: model.accounts, failureTitle: "Failed to load accounts") { accounts in
                    if accounts.isEmpty {
                        PagedEmptyContentView(text: "No connected accounts. Tap + to connect to a provider.")
                            .padding(.vertical)
                            .foregroundColor(.secondary)
                            .listRowBackground(EmptyView())
                    } else {
                        ForEach(accounts) { account in
                            ExternalAccountView(account: account, listModel: model)
                                .onTapGesture {
                                    self.selected = account
                                }
                        }
                    }
                }
            }
        }
        .refreshable {
            await model.reload()
        }
        .onReceive(NotificationCenter.default.publisher(for: ParticipantSession.participantDidUpdateNotification)) { _ in
            Task {
                await model.reload()
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                NavigationLink(value: AccountNavigationPath.providerSearch) {
                    Image(systemName: "plus")
                }
            }
        }
        .actionSheet(item: $selected) { account in
            ActionSheet(title: Text(account.provider.name), message: nil, buttons: actionButtons(account: account))
        }
    }
    
    private func actionButtons(account: ExternalAccount) -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        if account.isRefreshable {
            buttons.append(.default(Text("Refresh"), action: { refresh(account: account) }))
        }
        buttons.append(.destructive(Text("Delete"), action: { delete(account: account) }))
        buttons.append(.cancel())
        return buttons
    }
    
    private func refresh(account: ExternalAccount) {
        Task {
            do {
                try await model.refresh(account: account)
                messageBanner("Refreshed \(account.provider.name)")
            } catch {
                messageBanner(MyDataHelpsError(error).localizedDescription)
            }
        }
    }
    
    private func delete(account: ExternalAccount) {
        Task {
            do {
                try await model.delete(account: account)
                messageBanner("Disconnected from \(account.provider.name)")
            } catch {
                messageBanner(MyDataHelpsError(error).localizedDescription)
            }
        }
    }
}

struct ExternalAccountView: View {
    let account: ExternalAccount
    let listModel: ExternalAccountsListViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            if let logoURL = account.provider.logoURL {
                AsyncImage(url: logoURL) { image in
                    image.resizable()
                } placeholder: {
                    Image.logoPlaceholder()
                }
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
                    Text(lastRefreshDate.formatted())
                        .font(.caption)
                }
            }
        }
    }
}

struct ExternalAccountsListView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalAccountView(account: ExternalAccount.previewList[0], listModel: ExternalAccountsListViewModel(session: ParticipantSessionPreview(), result: .success([])))
            .padding()
            .previewLayout(.sizeThatFits)
            .banner()
        
        NavigationStack {
            ExternalAccountsListView(model: .init(session: ParticipantSessionPreview()))
                .navigationTitle("External Accounts")
        }
        .banner()
        
        NavigationStack {
            ExternalAccountsListView(model: .init(session: ParticipantSessionPreview(), result: .success([])))
                .navigationTitle("External Accounts")
        }
        .banner()
        
        NavigationStack {
            ExternalAccountsListView(model: .init(session: ParticipantSessionPreview(), result: .failure(.unknown(nil))))
                .navigationTitle("External Accounts")
        }
        .banner()
    }
}
