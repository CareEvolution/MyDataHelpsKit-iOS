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
    var nextPageID: String? { get }
}

protocol PagedModelSource {
    associatedtype PageModel: PageModelType
    var session: ParticipantSessionType { get }
    func loadPage(after page: PageModel?, completion: @escaping (Result<PageModel, MyDataHelpsError>) -> Void)
}

class PagedViewModel<SourceType: PagedModelSource, ItemViewType: View>: ObservableObject {
    typealias ItemType = SourceType.PageModel.ItemType
    
    enum State {
        case normal(loadMore: Bool)
        case empty
        case failure(MyDataHelpsError)
    }
    
    let source: SourceType
    let viewProvider: (ItemType) -> ItemViewType
    private var loading: Bool
    private var lastPage: SourceType.PageModel?
    
    @Published var state: State
    @Published var items: [ItemType]

    init(source: SourceType, viewProvider: @escaping (ItemType) -> ItemViewType) {
        self.source = source
        self.viewProvider = viewProvider
        self.lastPage = nil
        self.state = .normal(loadMore: true)
        self.items = []
        self.loading = false
        loadNextPage()
    }
    
    func loadNextPage() {
        guard case .normal(true) = state, !loading else { return }
        
        loading = true
        source.loadPage(after: lastPage) { [weak self] result in
            switch result {
            case let .success(page):
                self?.loaded(page)
            case let .failure(error):
                self?.state = .failure(error)
            }
            self?.loading = false
        }
    }
    
    func isLastItem(_ item: ItemType) -> Bool {
        item.id == items.last?.id
    }
    
    private func loaded(_ page: SourceType.PageModel) {
        lastPage = page
        items.append(contentsOf: page.pageItems(session: source.session))
        if items.isEmpty {
            state = .empty
        } else {
            state = .normal(loadMore: page.nextPageID != nil)
        }
    }
}
