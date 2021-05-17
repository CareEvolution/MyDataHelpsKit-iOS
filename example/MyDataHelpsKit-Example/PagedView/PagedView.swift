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
        switch model.state {
        case .empty:
            Text("No results")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding()
        case let .failure(error):
            ErrorView(title: "Failed to load", error: error)
        case let .normal(loadMore):
            List {
                Section {
                    ForEach(model.items) { item in
                        model.viewProvider(item)
                            .onAppear(perform: {
                                if model.isLastItem(item) {
                                    model.loadNextPage()
                                }
                            })
                    }
                }
                if loadMore {
                    Section {
                        ProgressView()
                    }
                }
            }
        }
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
