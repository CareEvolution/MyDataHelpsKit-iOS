//
//  DataView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI

struct DataView: View {
    static let tabTitle = "My Data"
    
    @StateObject var model: DataViewModel
    
    var body: some View {
        NavigationStack(path: $model.path) {
            List {
                ProjectDeviceDataSectionView(projectDataModel: model.projectDataModel)
                
                SensorDataSectionView(allQueryableDataTypes: model.allQueryableDataTypes)
            }
            .listStyle(.sidebar)
            .navigationTitle(Self.tabTitle)
            .navigationDestination(for: DataNavigationPath.self) { destination in
                switch destination {
                case let .browseDeviceData(type):
                    PagedListView(model: model.deviceDataQuery(browsing: type).pagedListViewModel(model.session)) { item in
                        DeviceDataPointView(model: item)
                    }
                    .navigationTitle(type.type)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        if type.namespace.isEditable {
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                Button("Add Data") {
                                    model.path.append(DataNavigationPath.addDeviceData)
                                }
                            }
                        }
                    }
                
                case let .editDeviceData(point):
                    PersistDeviceDataView(model: PersistDeviceDataViewModel(existing: point))
                        .navigationBarTitleDisplayMode(.inline)
                
                case .addDeviceData:
                    PersistDeviceDataView(model: PersistDeviceDataViewModel(session: model.session))
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .onAppear { model.loadData() }
        }
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView(model: DataViewModel(session: ParticipantSessionPreview()))
        DataView(model: DataViewModel(session: ParticipantSessionPreview(empty: true)))
    }
}
