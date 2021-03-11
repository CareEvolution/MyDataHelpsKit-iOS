//
//  PersistDeviceDataView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 4/1/21.
//

import SwiftUI
import MyDataHelpsKit

class PersistDeviceDataViewModel: ObservableObject {
    @Published var type = ""
    @Published var value = ""
    
    let session: ParticipantSessionType
    let isNew: Bool
    let identifier: String
    let units: String?
    let source: DeviceDataPointSource
    let startDate: Date?
    let observationDate: Date?
    
    init(session: ParticipantSessionType) {
        self.session = session
        self.isNew = true
        self.identifier = UUID().uuidString
        self.units = nil
        self.source = .init(identifier: UUID().uuidString, properties: [:])
        self.startDate = nil
        self.observationDate = nil
    }
    
    init(existing model: DeviceDataSource.ItemModel) {
        self.session = model.session
        self.isNew = false
        self.identifier = model.identifier
        self.type = model.type
        self.value = model.value
        self.units = model.units
        self.source = model.source
        self.startDate = model.startDate
        self.observationDate = model.observationDate
    }
    
    var persistModel: DeviceDataPointPersistModel {
        .init(identifier: identifier, type: type, value: value, units: units, properties: [:], source: source, startDate: startDate, observationDate: observationDate)
    }
}

struct PersistDeviceDataView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var model: PersistDeviceDataViewModel
    @State var result: Result<Void, MyDataHelpsError>? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Type:")
            TextField("Type", text: $model.type)
                .padding(.bottom, 20)
            Text("Value:")
            TextField("Value", text: $model.value)
            switch result {
            case .success: Text("Saved!")
            case let .failure(error):
                Text(error.localizedDescription)
                    .foregroundColor(Color(.systemRed))
            case .none: Text("")
            }
        }
        .padding()
        .navigationTitle(title)
        .navigationBarItems(trailing: Button("Save", action: save))
    }
    
    var title: String {
        model.isNew ? "New Device Data" : "Edit Device Data"
    }
    
    func save() {
        let persistModel = model.persistModel
        model.session.persistDeviceData([persistModel]) {
            self.result = $0
            if case .success = $0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct PersistDeviceDataView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PersistDeviceDataView(model: .init(session: ParticipantSessionPreview()))
        }
    }
}
