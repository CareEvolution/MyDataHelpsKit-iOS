//
//  PagedViewModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

protocol PageModelType {
    associatedtype ItemType: Identifiable
    func pageItems(session: ParticipantSessionType) -> [ItemType]
    var nextPageID: ScopedIdentifier<Self, String>? { get }
}

protocol PagedModelSource {
    associatedtype PageModel: PageModelType
    var session: ParticipantSessionType { get }
    func loadPage(after page: PageModel?) async throws -> PageModel?
}

@MainActor class PagedViewModel<SourceType: PagedModelSource>: ObservableObject {
    typealias ItemType = SourceType.PageModel.ItemType
    
    enum State {
        case normal(loadMore: Bool)
        case empty
        case failure(MyDataHelpsError)
    }
    
    @Published private(set) var source: SourceType
    private var loading: Bool
    private var lastPage: SourceType.PageModel?
    
    @Published var state: State
    @Published var items: [ItemType]
    @Published var selectedItem: ItemType?
    
    init(source: SourceType) {
        self.source = source
        self.lastPage = nil
        self.state = .normal(loadMore: true)
        self.items = []
        self.loading = false
        loadNextPage()
    }
    
    func reset(newSource: SourceType? = nil) {
        // TODO: wait if loading == true
        lastPage = nil
        state = .normal(loadMore: true)
        items = []
        loading = false
        if let newSource {
            source = newSource
        }
        loadNextPage()
    }
    
    func loadNextPage() {
        guard case .normal(true) = state, !loading else { return }
        
        loading = true
        Task {
            do {
                let nextPage = try await source.loadPage(after: lastPage)
                loaded(nextPage)
            } catch {
                state = .failure(MyDataHelpsError(error))
            }
            loading = false
        }
    }
    
    func isLastItem(_ item: ItemType) -> Bool {
        item.id == items.last?.id
    }
    
    private func loaded(_ page: SourceType.PageModel?) {
        lastPage = page
        if let page = page {
            items.append(contentsOf: page.pageItems(session: source.session))
        }
        if items.isEmpty {
            state = .empty
        } else {
            state = .normal(loadMore: page?.nextPageID != nil)
        }
    }
}
