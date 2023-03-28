//
//  PagedView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

/// Implements the paging idiom common to various list/query APIs in MyDataHelpsKit. Various `PagedModelSource` implementations in this example app perform the actual MyDataHelpsKit queries and produce the paged result objects. PagedListView and its component views use this source object to fetch data when it's first displayed, and to fetch the next page when scrolling to the bottom of the list view (infinite scrolling). PagedListView uses a corresponding `PagedViewModel` implementation to produce appropriate SwiftUI views for individual items shown in the list view.
///
/// `PagedListView` handles all details of a paging view, including ownership of the model object and construction of the top-level `List`. To customize or embed within another list view, use the components below instead.
struct PagedListView<SourceType, ViewType>: View where SourceType: PagedModelSource, ViewType: View {
    @StateObject var model: PagedViewModel<SourceType>
    let rowContent: (SourceType.PageModel.ItemType) -> ViewType
    
    var body: some View {
        List {
            Section {
                switch model.state {
                case .empty:
                    PagedEmptyContentView()
                case let .failure(error):
                    PagedFailureContentView(error: error)
                case .normal:
                    PagedContentItemsView(model: model, inlineProgressView: false, rowContent: rowContent)
                }
            } footer: {
                PagedLoadingView(model: model)
                    .padding(.vertical)
            }
        }
    }
}

/// Renders the items of a list view using a `PagedViewModel`. Use when the model's state is `.normal`. Place this inside a List or Section.
struct PagedContentItemsView<SourceType, ViewType>: View where SourceType: PagedModelSource, ViewType: View {
    @ObservedObject var model: PagedViewModel<SourceType>
    let inlineProgressView: Bool
    let rowContent: (SourceType.PageModel.ItemType) -> ViewType
    
    var body: some View {
        ForEach(model.items) { item in
            rowContent(item)
                .onTapGesture { model.selectedItem = item }
                .onAppear(perform: {
                    if model.isLastItem(item) {
                        model.loadNextPage()
                    }
                })
        }
        if inlineProgressView {
            PagedLoadingView(model: model)
        }
    }
}

/// A loading indicator for a paged view that displays itself only when appropriate.
struct PagedLoadingView<SourceType>: View where SourceType: PagedModelSource {
    @ObservedObject var model: PagedViewModel<SourceType>
    
    var body: some View {
        switch model.state {
        case .normal(loadMore: true):
            ProgressView()
        default:
            EmptyView()
        }
    }
}

/// Provides a default implementation for the `.empty` state of a `PagedViewModel`. Place this inside a List or Section.
struct PagedEmptyContentView: View {
    let text: String
    
    init(text: String = "No results") {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.headline)
            .fontWeight(.semibold)
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
    }
}

/// Provides a default implementation for the `.failure` state of a `PagedViewModel`. Place this inside a List or Section.
struct PagedFailureContentView: View {
    let error: MyDataHelpsError
    
    var body: some View {
        ErrorView(model: .init(title: "Failed to load", error: error))
    }
}

struct PagedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                Section("Empty") {
                    PagedEmptyContentView(text: "No items")
                }
                Section("Failure") {
                    PagedFailureContentView(error: .unknown(nil))
                }
                Section("Items") {
                    PagedContentItemsView(model: .init(source: PreviewSource(empty: false)), inlineProgressView: true) { item in
                        Self.viewProvider(item)
                    }
                }
            }
            .navigationTitle("Components")
        }
        
        NavigationStack {
            PagedListView(model: .init(source: PreviewSource(empty: false))) {
                Self.viewProvider($0)
            }
            .navigationTitle("Page of Results")
        }
        NavigationStack {
            PagedListView(model: .init(source: PreviewSource(empty: true))) {
                Self.viewProvider($0)
            }
            .navigationTitle("Empty Paged View")
        }
        NavigationStack {
            PagedListView(model: .init(source: FailureSource())) {
                Self.viewProvider($0)
            }
            .navigationTitle("Failure")
        }
    }
    
    private struct PreviewListItem: Identifiable {
        let id: String
        let text: String
    }
    
    private struct PreviewListPage: PageModelType {
        func pageItems(session: ParticipantSessionType) -> [PreviewListItem] {
            items
        }
        let items: [PreviewListItem]
        let nextPageID: ScopedIdentifier<PreviewListPage, String>? = nil
    }
    
    private class PreviewSource: PagedModelSource {
        let session: ParticipantSessionType = ParticipantSessionPreview()
        let empty: Bool
        
        init(empty: Bool) {
            self.empty = empty
        }
        
        func loadPage(after page: PreviewListPage?) async throws -> PreviewListPage? {
            if empty {
                return await delayedSuccess(page: .init(items: []))
            } else {
                return await delayedSuccess(page: .init(items: [
                    .init(id: "1", text: "abc"),
                    .init(id: "2", text: "def")
                ]))
            }
        }
        
        private func delayedSuccess(page: PreviewListPage) async -> PreviewListPage {
            return await withCheckedContinuation { continuation in
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    continuation.resume(returning: page)
                }
            }
        }
    }
    
    private class FailureSource: PagedModelSource {
        let session: ParticipantSessionType = ParticipantSessionPreview()
        
        func loadPage(after page: PreviewListPage?) async throws -> PreviewListPage? {
            throw MyDataHelpsError.unknown(nil)
        }
    }
    
    private static func viewProvider(_ item: PreviewListItem) -> Text {
        Text(item.text)
    }
}
