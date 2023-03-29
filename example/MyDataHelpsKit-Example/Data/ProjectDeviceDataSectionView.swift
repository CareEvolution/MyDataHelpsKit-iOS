//
//  ProjectDeviceDataSectionView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

struct ProjectDeviceDataSectionView: View {
    @ObservedObject var projectDataModel: PagedViewModel<DeviceDataSource>
    
    var body: some View {
        Section {
            switch projectDataModel.state {
            case .empty:
                PagedEmptyContentView(text: "No project data")
            case let .failure(error):
                PagedFailureContentView(error: error)
            case .normal:
                PagedContentItemsView(model: projectDataModel, inlineProgressView: true) { item in
                    DeviceDataPointView(model: item)
                }
                NavigationLink(value: DataNavigationPath.browseDeviceData(DataViewModel.projectDeviceDataQuery(summaryView: false))) {
                    Text("All Project Data")
                }
            }
        } header: {
            Text("Project Data")
        } footer: {
            Text("Your app can use the SDK to store and retrieve custom project-scoped device data points for the participant.")
        }
    }
}

struct ProjectDeviceDataSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                ProjectDeviceDataSectionView(projectDataModel: DeviceDataQuery(namespace: .project).pagedListViewModel(ParticipantSessionPreview()))
                
                ProjectDeviceDataSectionView(projectDataModel: DeviceDataQuery(namespace: .project).pagedListViewModel(ParticipantSessionPreview(empty: true)))
            }
        }
    }
}
