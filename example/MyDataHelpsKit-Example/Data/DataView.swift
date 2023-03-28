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
                Section {
                    AsyncCardView(result: model.allQueryableDataTypes, failureTitle: "Failed to load settings") { types in
                        if types.isEmpty {
                            Text("No queryable data types available for this project.")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(Array(types)) { item in
                                NavigationLink(value: DataNavigationPath.browseDeviceData(item)) {
                                    VStack(alignment: .leading) {
                                        Text(item.type)
                                        Text(item.namespace.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text("All Data")
                } footer: {
                    Text("Explore all data available for the participant based on the project's data collection settings.")
                }
            }
            .listStyle(.insetGrouped)
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
                    
                case .addDeviceData:
                    PersistDeviceDataView(model: PersistDeviceDataViewModel(session: model.session))
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
