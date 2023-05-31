//
//  DataViewModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

enum DataNavigationPath: Codable {
    case browseDeviceData(DeviceDataBrowseCategory)
    case editDeviceData(DeviceDataSource.ItemModel)
    case addDeviceData
}

@MainActor class DataViewModel: ObservableObject {
    let session: ParticipantSessionType
    
    @Published var path = NavigationPath()
    @Published var chartModel: RemoteResult<DeviceDataChartModel> = .loading
    @Published var projectDataModel: PagedViewModel<DeviceDataSource>
    @Published var allDataCategories: RemoteResult<[DeviceDataBrowseCategory]> = .loading
    
    init(session: ParticipantSessionType) {
        self.session = session
        /// EXERCISE: projectDataModel will show any custom project-scoped device data found for the participant. Try customizing the DeviceDataQuery to filter this data.
        self.projectDataModel = DeviceDataQuery(namespace: .project, limit: 5)
            .pagedListViewModel(session)
    }
    
    func loadData() {
        Task {
            if case .success = chartModel { return }
            /// EXERCISE: customize the query and chartModel to explore using the SDK to visualize device data. To find `DeviceDataNamespace` + `type` values available for querying in your project, use the `getDataCollectionSettings` API, or browse the `SensorDataSectionView` within the example app.
            let namespace = DeviceDataNamespace.appleHealth
            let dataType = "RestingHeartRate"
            do {
                let result = try await session.queryDeviceData(DeviceDataQuery(namespace: namespace, types: Set([dataType]), limit: 15))
                chartModel = .success(DeviceDataChartModel(
                    title: "Resting Heart Rate",
                    xAxisLabel: "Date",
                    yAxisLabel: "bpm",
                    yAxisIncludesZero: false,
                    accentColor: .red,
                    allDataPath: .browseDeviceData(DeviceDataBrowseCategory(namespace: namespace, type: dataType)),
                    deviceDataResult: result))
            } catch {
                chartModel = .failure(MyDataHelpsError(error))
            }
        }
        
        Task {
            if case .success = allDataCategories { return }
            do {
                let types = try await session.getDataCollectionSettings().queryableDeviceDataTypes
                allDataCategories = .success(types
                    .map { DeviceDataBrowseCategory(namespace: $0.namespace, type: $0.type) }
                    .sorted())
            } catch {
                allDataCategories = .failure(MyDataHelpsError(error))
            }
        }
    }
    
    func refresh() async {
        await projectDataModel.reset()
    }
}

// MARK: Protocol conformances required for use in a NavigationStack's NavigationPath.

extension DataNavigationPath: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .browseDeviceData(category):
            hasher.combine(0)
            hasher.combine(category)
        case let .editDeviceData(model):
            hasher.combine(1)
            hasher.combine(model.id)
        case .addDeviceData:
            hasher.combine(2)
        }
    }
    
    static func == (lhs: DataNavigationPath, rhs: DataNavigationPath) -> Bool {
        switch (lhs, rhs) {
        case let (.browseDeviceData(category1), .browseDeviceData(category2)):
            return category1 == category2
        case let (.editDeviceData(model1), .editDeviceData(model2)):
            return model1.id == model2.id
        case (.addDeviceData, .addDeviceData):
            return true
        default:
            return false
        }
    }
}
