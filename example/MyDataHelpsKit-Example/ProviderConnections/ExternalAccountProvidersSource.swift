//
//  ExternalAccountProvidersSource.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/29/23.
//

import SwiftUI
import MyDataHelpsKit

extension ExternalAccountProvidersQuery {
    @MainActor func pagedListViewModel(_ session: ParticipantSessionType) -> PagedViewModel<ExternalAccountProvidersSource> {
        PagedViewModel(source: ExternalAccountProvidersSource(session: session, query: self))
    }
}

class ExternalAccountProvidersSource: PagedModelSource {
    let session: ParticipantSessionType
    let query: ExternalAccountProvidersQuery
    
    init(session: ParticipantSessionType, query: ExternalAccountProvidersQuery) {
        self.session = session
        self.query = query
    }
    
    func withSearchText(_ searchText: String?) -> ExternalAccountProvidersSource {
        var cleanSearchText = searchText?.trimmingCharacters(in: .whitespaces)
        if cleanSearchText?.isEmpty == true {
            cleanSearchText = nil
        }
        let newQuery = ExternalAccountProvidersQuery(search: cleanSearchText, category: self.query.category, limit: self.query.limit)
        return ExternalAccountProvidersSource(session: session, query: newQuery)
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
