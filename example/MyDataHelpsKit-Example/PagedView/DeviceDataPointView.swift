//
//  DeviceDataPointView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

extension DeviceDataQuery {
    @MainActor func pagedListViewModel(_ session: ParticipantSessionType) -> PagedViewModel<DeviceDataSource> {
        PagedViewModel(source: DeviceDataSource(session: session, criteria: self))
    }
}

struct DeviceDataPointView: View {
    let model: DeviceDataSource.ItemModel
    
    var body: some View {
        if model.namespace.isEditable {
            NavigationLink(value: DataNavigationPath.editDeviceData(model)) {
                content
            }
        } else {
            content
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading) {
            /// EXERCISE: Add or modify views here to see the values of other `DeviceDataPoint` properties.
            if let date = model.observationDate {
                Text("\(model.value) at \(date.formatted(date: .numeric, time: .standard))")
            } else {
                Text(model.value)
            }
            Text(model.type)
                .font(.footnote)
                .foregroundColor(Color.gray)
        }
    }
}

struct DeviceDataPointView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                DeviceDataPointView(model: .init(namespace: .appleHealth, id: .init("1"), identifier: "1", type: "HeartRate", value: "62", units: nil, source: nil, startDate: Date(), observationDate: Date()))
                DeviceDataPointView(model: .init(namespace: .project, id: .init("2"), identifier: "2", type: "PersistType1", value: "ABC", units: nil, source: nil, startDate: Date(), observationDate: Date()))
            }
        }
    }
}
