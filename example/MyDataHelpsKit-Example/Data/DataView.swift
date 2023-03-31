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
                
                SensorDataSectionView(allDataCategories: model.allDataCategories)
            }
            .listStyle(.sidebar) // Enables collapsible sections
            .refreshable {
                await model.refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: ParticipantSession.participantDidUpdateNotification)) { _ in
                Task {
                    await model.refresh()
                }
            }
            .onAppear { model.loadData() }
            .navigationTitle(Self.tabTitle)
            .navigationDestination(for: DataNavigationPath.self) { destination in
                switch destination {
                case let .browseDeviceData(category):
                    browseDeviceDataView(category: category)
                
                case let .editDeviceData(point):
                    PersistDeviceDataView(model: PersistDeviceDataViewModel(session: model.session, existing: point))
                        .navigationBarTitleDisplayMode(.inline)
                
                case .addDeviceData:
                    PersistDeviceDataView(model: PersistDeviceDataViewModel(session: model.session))
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    private func browseDeviceDataView(category: DeviceDataBrowseCategory) -> some View {
        PagedListView(model: category.query.pagedListViewModel(model.session)) { item in
            DeviceDataPointView(model: item)
        }
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if category.namespace.isEditable {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Add Data") {
                        model.path.append(DataNavigationPath.addDeviceData)
                    }
                }
            }
        }
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView(model: DataViewModel(session: ParticipantSessionPreview()))
        DataView(model: DataViewModel(session: ParticipantSessionPreview(empty: true)))
    }
}
