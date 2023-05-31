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
struct PagedListView<SourceType, Content>: View where SourceType: PagedModelSource, Content: View {
    @StateObject var model: PagedViewModel<SourceType>
    @ViewBuilder var rowContent: (SourceType.PageModel.ItemType) -> Content
    
    var body: some View {
        List {
            Section {
                switch model.state {
                case .empty:
                    PagedEmptyContentView()
                        .padding(.vertical)
                        .foregroundColor(.secondary)
                        .listRowBackground(EmptyView())
                case let .failure(error):
                    PagedFailureContentView(error: error)
                case .normal:
                    PagedContentItemsView(model: model, inlineProgressViewVisibility: .never, rowContent: rowContent)
                }
            } footer: {
                PagedLoadingView(model: model)
                    .padding(.vertical)
            }
        }
        .refreshable {
            await model.reset()
        }
    }
}

/// Renders the items of a list view using a `PagedViewModel`. Use when the model's state is `.normal`. Place this inside a List or Section.
struct PagedContentItemsView<SourceType, Content>: View where SourceType: PagedModelSource, Content: View {
    
    @ObservedObject var model: PagedViewModel<SourceType>
    let inlineProgressViewVisibility: PagedLoadingViewVisibility
    @ViewBuilder var rowContent: (SourceType.PageModel.ItemType) -> Content
    
    var body: some View {
        ForEach(model.items) { item in
            rowContent(item)
                .onTapGesture { model.selectedItem = item }
                .onAppear(perform: {
                    if model.isLastItem(item) {
                        Task {
                            await model.loadNextPage()
                        }
                    }
                })
        }
        PagedLoadingView(model: model, visibility: inlineProgressViewVisibility)
    }
}

enum PagedLoadingViewVisibility {
    case allFetches
    case initialFetch
    case never
}

/// A loading indicator for a paged view that displays itself only when appropriate.
struct PagedLoadingView<SourceType>: View where SourceType: PagedModelSource {
    
    @ObservedObject var model: PagedViewModel<SourceType>
    let visibility: PagedLoadingViewVisibility
    
    init(model: PagedViewModel<SourceType>, visibility: PagedLoadingViewVisibility = .allFetches) {
        self.model = model
        self.visibility = visibility
    }
    
    var body: some View {
        switch (visibility, model.state) {
        case (.allFetches, .normal(loadMore: true)):
            ProgressView()
        case (.initialFetch, .normal(loadMore: true))
            where model.items.isEmpty:
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
                    PagedContentItemsView(model: .init(source: PreviewSource(empty: false)), inlineProgressViewVisibility: .allFetches) { item in
                        Self.viewProvider(item)
                    }
                }
            }
            .navigationTitle("Components")
        }
        
        NavigationStack {
            PagedListView(model: .init(source: PreviewSource(empty: false))) {
                Self.viewProvider($0)
                    .padding(.vertical)
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
    
    private static func viewProvider(_ item: PreviewListItem) -> some View {
        Text(item.text)
    }
}
