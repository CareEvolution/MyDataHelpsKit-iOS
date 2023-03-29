//
//  DataView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

struct DataView: View {
    static let tabTitle = "My Data"
    
    static func summaryText(query: DeviceDataQuery) -> String {
        if let types = query.types,
           !types.isEmpty {
            return "\(query.namespace.rawValue): \(types.joined(separator: ", "))"
        } else {
            return query.namespace.rawValue;
        }
    }
    
    @StateObject var model: DataViewModel
    
    var body: some View {
        NavigationStack(path: $model.path) {
            List {
                Section("Highlights") {
                    AsyncCardView(result: model.chartModel, failureTitle: "Failed to load chart data") { chartModel in
                        if chartModel.dataPoints.isEmpty {
                            PagedEmptyContentView(text: "No data available for chart")
                        } else {
                            DeviceDataChartView(model: chartModel)
                        }
                    }
                }
                
                ProjectDeviceDataSectionView(projectDataModel: model.projectDataModel)
                
                SensorDataSectionView(allQueryableDataTypes: model.allQueryableDataTypes)
            }
            .listStyle(.sidebar)
            .navigationTitle(Self.tabTitle)
            .navigationDestination(for: DataNavigationPath.self) { destination in
                switch destination {
                case let .browseDeviceData(query):
                    PagedListView(model: query.pagedListViewModel(model.session)) { item in
                        DeviceDataPointView(model: item)
                    }
                    .navigationTitle(Self.summaryText(query: query))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        if query.namespace.isEditable {
                            ToolbarItemGroup(placement: .primaryAction) {
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
