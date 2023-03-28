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
        PagedViewModel(source: DeviceDataSource(session: session, query: self))
    }
}

struct DeviceDataPointView: View {
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
            DeviceDataPointView(model: .init(session: ParticipantSessionPreview(), namespace: .project, id: .init("1"), identifier: "1", type: "HeartRate", value: "62", units: nil, source: .init(identifier: "", properties: [:]), startDate: Date(), observationDate: Date()))
        }
    }
}
