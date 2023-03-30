//
//  AsyncCardView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

struct AsyncCardView<Model, Content>: View where Content: View {
    let result: RemoteResult<Model>
    let failureTitle: String
    @ViewBuilder var content: (Model) -> Content
    
    var body: some View {
        switch result {
        case .loading:
            ProgressView()
        case let .success(model):
            content(model)
        case let .failure(error):
            ErrorView(model: .init(title: failureTitle, error: error))
        }
    }
}

struct AsyncCardView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                AsyncCardView(result: makeResult(.success("Successful result")), failureTitle: "Failure") { text in
                    Text(text)
                        .font(.headline)
                }
            }
            Section {
                AsyncCardView(result: makeResult(.failure(.invalidSurvey)), failureTitle: "Failure") { text in
                    Text(text)
                }
            }
            Section {
                AsyncCardView(result: makeResult(.loading), failureTitle: "Failure") { text in
                    Text(text)
                }
            }
        }
    }
    
    private static func makeResult(_ result: RemoteResult<String>) -> RemoteResult<String> {
        result
    }
}
