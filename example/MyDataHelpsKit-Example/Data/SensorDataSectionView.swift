//
//  SensorDataSectionView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

struct SensorDataSectionView: View {
    let allQueryableDataTypes: Result<[QueryableDeviceDataType], MyDataHelpsError>?
    
    var body: some View {
        Section {
            AsyncCardView(result: allQueryableDataTypes, failureTitle: "Failed to load settings") { types in
                if types.isEmpty {
                    Text("No queryable data types available for this project.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(types)) { item in
                        NavigationLink(value: DataNavigationPath.browsing(dataType: item)) {
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
            Text("Browse Sensor Data")
        } footer: {
            Text("Explore all data available for the participant based on the project's data collection settings.")
        }
    }
}

struct SensorDataSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                SensorDataSectionView(allQueryableDataTypes: .success(Array(ProjectInfoView_Previews.projectDataCollectionSettings.queryableDeviceDataTypes)))
                SensorDataSectionView(allQueryableDataTypes: .success([]))
                SensorDataSectionView(allQueryableDataTypes: nil)
                SensorDataSectionView(allQueryableDataTypes: .failure(.timedOut(nil)))
            }
        }
    }
}
