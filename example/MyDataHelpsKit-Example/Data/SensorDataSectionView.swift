//
//  SensorDataSectionView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import MyDataHelpsKit

struct SensorDataSectionView: View {
    let allDataCategories: RemoteResult<[DeviceDataBrowseCategory]>
    
    var body: some View {
        Section {
            AsyncCardView(result: allDataCategories, failureTitle: "Failed to load settings") { categories in
                if categories.isEmpty {
                    Text("No queryable data types available for this project.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(categories) { category in
                        NavigationLink(value: DataNavigationPath.browseDeviceData(category)) {
                            VStack(alignment: .leading) {
                                if let type = category.type {
                                    Text(type)
                                }
                                Text(category.namespace.rawValue)
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
                SensorDataSectionView(allDataCategories: .success([
                    .init(namespace: .appleHealth, type: "HeartRate"),
                    .init(namespace: .fitbit, type: "Sleep"),
                    .init(namespace: .googleFit, type: "HeartRate")
                ]))
                SensorDataSectionView(allDataCategories: .success([]))
                SensorDataSectionView(allDataCategories: .loading)
                SensorDataSectionView(allDataCategories: .failure(.timedOut(nil)))
            }
        }
    }
}
