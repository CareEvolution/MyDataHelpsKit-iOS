//
//  DataViewModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

enum DataNavigationPath {
    case browseDeviceData(DeviceDataQuery)
    case editDeviceData(DeviceDataSource.ItemModel)
    case addDeviceData
    
    static func browsing(dataType: QueryableDeviceDataType) -> DataNavigationPath {
        .browseDeviceData(DeviceDataQuery(namespace: dataType.namespace, types: Set([dataType.type])))
    }
}

@MainActor class DataViewModel: ObservableObject {
    static func projectDeviceDataQuery(summaryView: Bool) -> DeviceDataQuery {
        DeviceDataQuery(namespace: .project, limit: summaryView ? 5 : DeviceDataQuery.defaultLimit)
    }
    
    let session: ParticipantSessionType
    
    @Published var path = NavigationPath()
    @Published var chartModel: RemoteResult<DeviceDataChartModel> = .loading
    @Published var projectDataModel: PagedViewModel<DeviceDataSource>
    @Published var allQueryableDataTypes: RemoteResult<[QueryableDeviceDataType]> = .loading
    
    init(session: ParticipantSessionType) {
        self.session = session
        /// EXERCISE: projectDataModel will show any custom project-scoped device data found for the participant. Try customizing the DeviceDataQuery to filter this data.
        self.projectDataModel = Self.projectDeviceDataQuery(summaryView: true)
            .pagedListViewModel(session)
    }
    
    func loadData() {
        Task {
            if case .success = chartModel { return }
            /// EXERCISE: customize the query and chartModel to explore using the SDK to visualize device data. To find `DeviceDataNamespace` + `type` values available for querying in your project, use the `getDataCollectionSettings` API or browse the `SensorDataSectionView`.
            let query = DeviceDataQuery(namespace: .appleHealth, types: Set(["RestingHeartRate"]), limit: 15)
            do {
                let result = try await session.queryDeviceData(query)
                chartModel = .success(DeviceDataChartModel(
                    title: "Resting Heart Rate",
                    xAxisLabel: "Date",
                    yAxisLabel: "bpm",
                    accentColor: .red,
                    allDataQuery: DeviceDataQuery(namespace: query.namespace, types: query.types),
                    deviceDataResult: result))
            } catch {
                chartModel = .failure(MyDataHelpsError(error))
            }
        }
        
        Task {
            if case .success = allQueryableDataTypes { return }
            do {
                let types = try await session.getDataCollectionSettings().queryableDeviceDataTypes
                allQueryableDataTypes = .success(Array(types).sorted { a, b in
                    if a.namespace == b.namespace {
                        return a.type < b.type
                    } else {
                        return a.namespace.rawValue < b.namespace.rawValue
                    }
                })
            } catch {
                allQueryableDataTypes = .failure(MyDataHelpsError(error))
            }
        }
    }
}

// Protocol conformances required for use in a NavigationStack's NavigationPath.
extension DataNavigationPath: Codable, Hashable, RawRepresentable {
    typealias RawValue = String // for Encodable
    
    init?(rawValue: String) {
        return nil
    }
    
    var rawValue: String {
        switch self {
        case let .browseDeviceData(query):
            return "browseDeviceData \(DataView.summaryText(query: query))"
        case let .editDeviceData(point):
            return "editDeviceData \(point.id)"
        case .addDeviceData:
            return "addDeviceData"
        }
    }
}

// Identifiable conformance used for SwiftUI List/ForEach constructs.
extension QueryableDeviceDataType: Identifiable {
    public var id: String {
        "\(namespace.rawValue)|\(type)"
    }
}
