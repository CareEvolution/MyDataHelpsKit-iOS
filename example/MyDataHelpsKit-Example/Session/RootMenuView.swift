//
//  RootMenuView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI

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

struct RootMenuView: View {
    @StateObject var participant: ParticipantModel
    
    var body: some View {
        VStack {
            switch participant.info {
            case let .some(.success(model)):
                ParticipantInfoView(model: model)
                    .roundRectComponent()
            case let .some(.failure(error)):
                ErrorView(title: "Error loading participant info", error: error)
                    .roundRectComponent()
            case .none:
                LoadingView()
                    .onAppear(perform: loadParticipantInfo)
                    .roundRectComponent()
            }
            
            NavigationLink(
                destination: DeviceDataPointView.pageView(session: participant.session, namespace: .appleHealth, types: Set(["HeartRate"]))
                    .navigationTitle("Query Device Data")
            ) {
                Label("Device Data: Apple Health", systemImage: "heart")
            }.roundRectComponent()
            
            VStack {
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
            
            NavigationLink(
                destination: SurveyTaskView.pageView(session: participant.session)
                    .navigationTitle("Query Survey Tasks")
            ) {
                Label("Query Survey Tasks", systemImage: "checkmark.square")
            }.roundRectComponent()
            
            NavigationLink(
                destination: SurveyAnswerView.pageView(session: participant.session, surveyID: nil)
                    .navigationTitle("Query Survey Answers")
            ) {
                Label("Query Survey Answers", systemImage: "square.and.pencil")
            }.roundRectComponent()
            
            NavigationLink(
                destination: NotificationHistoryView.pageView(session: participant.session)
                    .navigationTitle("Query Notifications")
            ) {
                Label("Query Notifications", systemImage: "app.badge")
            }.roundRectComponent()
        }
    }
    
    func loadParticipantInfo() {
        participant.loadInfo()
    }
}

struct RootMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RootMenuView(participant: ParticipantModel(session: ParticipantSessionPreview()))
        }
    }
}
