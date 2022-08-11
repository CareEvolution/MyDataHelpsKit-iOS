//
//  RootMenuView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

extension View {
    func roundRectComponent() -> some View {
        GeometryReader { geometry in
            self
                .padding(8.0)
                .frame(width: geometry.size.width)
                .background(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(.systemGray2), lineWidth: 1)
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

/// Links to sub-views that demonstrate the capabilities of MyDataHelpsKit.
///
/// EXERCISE: This view configures the query objects for the content of various sub-views. Modify the query objects passed to various `pageView` functions here to see how filtering and sorting works in data queries.
struct RootMenuView: View {
    @StateObject var participant: ParticipantModel
    @State private var embeddableSurvey: EmbeddableSurveySelection? = nil
    @State private var embeddableSurveyError: MyDataHelpsError? = nil
    @State private var errorAlertModel: ErrorView.Model? = nil
    
    var body: some View {
        VStack {
            switch participant.info {
            case let .some(.success(model)):
                ParticipantInfoView(model: model)
                    .roundRectComponent()
            case let .some(.failure(error)):
                ErrorView(model: .init(title: "Error loading participant info", error: error))
                    .roundRectComponent()
            case .none:
                LoadingView()
                    .onAppear(perform: loadParticipantInfo)
                    .roundRectComponent()
            }
            
            if case let .some(.success(project)) = participant.project {
                ProjectInfoView(project: project)
                    .roundRectComponent()
            }
            
            /// EXERCISE: Modify the `types` set to filter for different types of HealthKit data used by your project, or add additional optional parameters to the `DeviceDataQuery` to further customize filtering.
            NavigationLink(
                destination: DeviceDataPointView.pageView(session: participant.session, namespace: .appleHealth, types: Set(["StandHourInterval"]))
                    .navigationTitle("Query Device Data")
            ) {
                Label("Device Data: Apple Health", systemImage: "heart")
            }.roundRectComponent()
            
            VStack {
                /// EXERCISE: Modify the `types` set to filter by the identifiers of project-scoped data used by your project, or add additional optional parameters to the `DeviceDataQuery` to further customize filtering.
                NavigationLink(
                    destination: DeviceDataPointView.pageView(session: participant.session, namespace: .project, types: nil)
                        .navigationTitle("Query Device Data")
                ) {
                    Label("Device Data: Project", systemImage: "ellipsis.rectangle")
                }.padding(.bottom, 10)
                
                NavigationLink(
                    destination: PersistDeviceDataView(model: .init(session: participant.session))
                ) {
                    Label("Persist New Device Data", systemImage: "rectangle.and.pencil.and.ellipsis")
                }
            }.roundRectComponent()
            
            if case let .some(.success(info)) = participant.info {
                NavigationLink(
                    destination: SurveyTaskView.pageView(session: participant.session, participantInfo: info, embeddableSurveySelection: $embeddableSurvey)
                        .navigationTitle("Query Survey Tasks")
                        .sheet(item: $embeddableSurvey, onDismiss: {
                            // Delay presenting error alert until after sheet is fully dismissed
                            if let embeddableErrorModel = embeddableSurveyError.map({ ErrorView.Model(title: "Survey error", error: $0) }) {
                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                                    errorAlertModel = embeddableErrorModel
                                }
                            }
                        }) { selection in
                            /// RootView is responsible for modally presenting any Embeddable Survey that the user selects from the `SurveyTaskView`. See `EmbeddableSurveyViewController` documentation.
                            EmbeddableSurveyViewRepresentable(model: selection, presentation: $embeddableSurvey, error: $embeddableSurveyError)
                        }
                ) {
                    Label("Query Survey Tasks", systemImage: "checkmark.square")
                }.roundRectComponent()
            }
            
            /// This presents a list of all of the participant's survey answers.  See SurveyAnswerView.swift to further customize the query. The SurveyTaskView above also presents SurveyAnswerViews filtered to specific surveys.
            NavigationLink(
                destination: SurveyAnswerView.pageView(session: participant.session, surveyID: nil)
                    .navigationTitle("Query Survey Answers")
            ) {
                Label("Query Survey Answers", systemImage: "square.and.pencil")
            }.roundRectComponent()
            
            /// Modify NotificationHistoryView.swift to customize the notifications shown here.
            NavigationLink(
                destination: NotificationHistoryView.pageView(session: participant.session)
                    .navigationTitle("Query Notifications")
            ) {
                Label("Query Notifications", systemImage: "app.badge")
            }.roundRectComponent()
            
            /// ExternalAccountsListView lists all of the participant's connected accounts, and has a button to query external account providers and establish new connected accounts.
            NavigationLink(
                destination: ExternalAccountsListView(model: ExternalAccountsListViewModel(session: participant.session))
                    .navigationTitle("External Accounts")
            ) {
                Label("External Accounts", systemImage: "link")
            }.roundRectComponent()
        }
        .alert(item: $errorAlertModel) {
            Alert(title: Text($0.title), message: Text($0.errorDescription), dismissButton: nil)
        }
    }
    
    func loadParticipantInfo() {
        participant.loadInfo()
        participant.loadProject()
    }
}

struct RootMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RootMenuView(participant: ParticipantModel(session: ParticipantSessionPreview()))
        }
    }
}
