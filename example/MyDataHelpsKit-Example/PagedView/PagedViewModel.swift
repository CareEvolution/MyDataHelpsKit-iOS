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
    enum State {
        case ready
        case loading
        case done
        case failed(MyDataHelpsError)
    }
    
    let source: SourceType
    let viewProvider: (SourceType.PageModel.ItemType) -> ItemViewType
    
    private var lastPage: SourceType.PageModel? {
        didSet {
            if let lastPage = lastPage {
                items.append(contentsOf: lastPage.pageItems(session: source.session))
            }
        }
    }
    
    @Published var state: State
    @Published var items: [SourceType.PageModel.ItemType]
    
    init(source: SourceType, viewProvider: @escaping (SourceType.PageModel.ItemType) -> ItemViewType) {
        self.source = source
        self.viewProvider = viewProvider
        self.lastPage = nil
        self.state = .ready
        self.items = []
    }
    
    func loadFirstPage() {
        lastPage = nil
        state = .ready
        items = []
        loadNextPage()
    }
    
    func loadNextPage() {
        guard case .ready = state else { return }
        state = .loading
        source.loadPage(after: lastPage) { [weak self] result in
            switch result {
            case let .success(page):
                self?.lastPage = page
                self?.state = page.nextPageID == nil ? .done : .ready
            case let .failure(error):
                self?.state = .failed(error)
            }
        }
    }
    
    func isLastItem(_ item: SourceType.PageModel.ItemType) -> Bool {
        item.id == items.last?.id
    }
}
