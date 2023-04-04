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
    @Published var accountChangeResult: String? {
        didSet {
            Task {
                // Dismiss the result after a few seconds.
                try? await Task.sleep(for: .seconds(3))
                accountChangeResult = nil
            }
        }
    }
    
    init(session: ParticipantSessionType) {
        self.session = session
        self.accounts = .loading
        self.accountChangeResult = nil
        Task {
            await reload()
        }
    }
    
    #if DEBUG
    // For SwiftUI previews.
    init(session: ParticipantSessionType, result: RemoteResult<[ExternalAccount]>, accountChangeResult: String?) {
        self.session = session
        self.accounts = result
        self.accountChangeResult = accountChangeResult
    }
    #endif
    
    func reload() async {
        accounts = await RemoteResult(wrapping: try await session.listExternalAccounts())
    }
    
    func refresh(account: ExternalAccount) {
        guard account.isRefreshable else { return }
        Task {
            do {
                try await session.refreshExternalAccount(account)
                accountChangeResult = "Refreshed \(account.provider.name)"
            } catch {
                accountChangeResult = error.localizedDescription
            }
            NotificationCenter.default.post(name: ParticipantSession.participantDidUpdateNotification, object: nil)
        }
    }
    
    func delete(account: ExternalAccount) {
        Task {
            do {
                try await session.deleteExternalAccount(account)
                accountChangeResult = "Deleted \(account.provider.name)"
            } catch {
                accountChangeResult = error.localizedDescription
            }
            NotificationCenter.default.post(name: ParticipantSession.participantDidUpdateNotification, object: nil)
        }
    }
}

struct ExternalAccountsListView: View {
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
            } header: {
                if let accountChangeResult = model.accountChangeResult {
                    // TODO: show pill shaped banner instead
                    Text(accountChangeResult)
                } else {
                    EmptyView()
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
            buttons.append(.default(Text("Refresh"), action: { model.refresh(account: account) }))
        }
        buttons.append(.destructive(Text("Delete"), action: { model.delete(account: account) }))
        buttons.append(.cancel())
        return buttons
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
        ExternalAccountView(account: ExternalAccount.previewList[0], listModel: ExternalAccountsListViewModel(session: ParticipantSessionPreview(), result: .success([]), accountChangeResult: nil))
            .padding()
            .previewLayout(.sizeThatFits)
        NavigationStack {
            ExternalAccountsListView(model: .init(session: ParticipantSessionPreview()))
                .navigationTitle("External Accounts")
        }
        NavigationStack {
            ExternalAccountsListView(model: .init(session: ParticipantSessionPreview(), result: .success(ExternalAccount.previewList), accountChangeResult: "Refreshed Account"))
                .navigationTitle("External Accounts")
        }
        NavigationStack {
            ExternalAccountsListView(model: .init(session: ParticipantSessionPreview(), result: .success([]), accountChangeResult: nil))
                .navigationTitle("External Accounts")
        }
        NavigationStack {
            ExternalAccountsListView(model: .init(session: ParticipantSessionPreview(), result: .failure(.unknown(nil)), accountChangeResult: nil))
                .navigationTitle("External Accounts")
        }
    }
}
