//
//  DataViewModel.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

enum DataNavigationPath {
    case browseDeviceData(QueryableDeviceDataType)
    case editDeviceData(DeviceDataSource.ItemModel)
    case addDeviceData
}

@MainActor class DataViewModel: ObservableObject {
    let session: ParticipantSessionType
    
    @Published var path = NavigationPath()
    @Published var allQueryableDataTypes: Result<[QueryableDeviceDataType], MyDataHelpsError>? = nil
    
    init(session: ParticipantSessionType) {
        self.session = session
    }
    
    func deviceDataQuery(browsing: QueryableDeviceDataType) -> DeviceDataQuery {
        DeviceDataQuery(namespace: browsing.namespace, types: Set([browsing.type]))
    }
    
    func loadData() {
        Task {
            if case .some(.success) = allQueryableDataTypes { return }
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
        case let .browseDeviceData(type):
            return "browseDeviceData \(type.namespace) \(type.type)"
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
