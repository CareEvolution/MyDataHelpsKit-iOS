//
//  PagedView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct PagedView<SourceType, ViewType>: View where SourceType: PagedModelSource, ViewType: View {
    @StateObject var model: PagedViewModel<SourceType, ViewType>
    
    var body: some View {
        Group {
            switch model.state {
            case .loading:
                // TODO actually append this to the last item in the list
                // PagedViewModel's item array might need to be an enum with cases .loading and .item
                LoadingView()
            case .ready, .done:
                // TODO if zero results, show an EmptyView rather than a List
                List(model.items) { item in
                    model.viewProvider(item)
                        .onAppear {
                            if model.isLastItem(item) {
                                model.loadNextPage()
                            }
                        }
                }
            case let .failed(error):
                ErrorView(title: "Failed to load X", error: error)
            }
        }
        .onAppear(perform: model.loadFirstPage)
    }
}

struct PagedView_Previews: PreviewProvider {
    struct PreviewListItem: Identifiable {
        let id: String
        let text: String
    }
    
    struct PreviewListPage: PageModelType {
        func pageItems(session: ParticipantSessionType) -> [PreviewListItem] {
            items
        }
        let items: [PreviewListItem]
        let nextPageID: String? = nil
    }
    
    class PreviewSource: PagedModelSource {
        let session: ParticipantSessionType = ParticipantSessionPreview()
        
        func loadPage(after page: PreviewListPage?, completion: @escaping (Result<PreviewListPage, MyDataHelpsError>) -> Void) {
            completion(.success(.init(items: [
                .init(id: "1", text: "abc"),
                .init(id: "2", text: "def")
            ])))
        }
    }
    
    private static func viewProvider(_ item: PreviewListItem) -> some View {
        Text(item.text)
    }
    
    static var previews: some View {
        PagedView(model: .init(source: PreviewSource(), viewProvider: { Self.viewProvider($0) }))
    }
}
