//
//  DeviceDataPointView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct DeviceDataPointView: View {
    static func pageView(session: ParticipantSessionType, namespace: DeviceDataNamespace, types: Set<String>?) -> PagedView<DeviceDataSource, DeviceDataPointView> {
        let query = DeviceDataQuery(namespace: namespace, types: types, limit: 25)
        let source = DeviceDataSource(session: session, query: query)
        return PagedView(model: .init(source: source) { item in
            DeviceDataPointView(model: item)
        })
    }
    
    let model: DeviceDataSource.ItemModel
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .medium
        return df
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            /// EXERCISE: Add or modify `Text` views here to see the values of other `DeviceDataPoint` properties.
            if let date = model.observationDate {
                Text("\(model.value) at \(Self.dateFormatter.string(from: date))")
            } else {
                Text(model.value)
            }
            Text(model.type)
                .font(.footnote)
                .foregroundColor(Color.gray)
            if model.namespace == .project {
                NavigationLink(
                    "",
                    destination: PersistDeviceDataView(model: .init(existing: model))
                )
            }
        }
    }
}

struct DeviceDataPointView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DeviceDataPointView(model: .init(session: ParticipantSessionPreview(), namespace: .project, id: "1", identifier: "1", type: "HeartRate", value: "62", units: nil, source: .init(identifier: "", properties: [:]), startDate: Date(), observationDate: Date()))
        }
    }
}
