//
//  PersistDeviceDataView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 4/1/21.
//

import SwiftUI
import MyDataHelpsKit

@MainActor class PersistDeviceDataViewModel: ObservableObject {
    @Published var identifier = ""
    @Published var type = ""
    @Published var value = ""
    
    let session: ParticipantSessionType
    let isNew: Bool
    let units: String?
    let source: DeviceDataPointSource?
    let startDate: Date?
    let observationDate: Date?
    
    /// EXERCISE: Some `DeviceDataPoint` properties are hard-coded here; set different values as appropriate for your project.
    init(session: ParticipantSessionType) {
        self.session = session
        self.isNew = true
        self.units = nil
        self.source = .init(identifier: UUID().uuidString, properties: [:])
        self.startDate = nil
        self.observationDate = nil
    }
    
    init(existing model: DeviceDataSource.ItemModel) {
        self.session = model.session
        self.isNew = false
        self.identifier = model.identifier ?? ""
        self.type = model.type
        self.value = model.value
        self.units = model.units
        self.source = model.source
        self.startDate = model.startDate
        self.observationDate = model.observationDate
    }
    
    var persistModel: DeviceDataPointPersistModel {
        .init(identifier: identifier.isEmpty ? nil : identifier, type: type, value: value, units: units, properties: [:], source: source, startDate: startDate, observationDate: observationDate)
    }
}

struct PersistDeviceDataView: View {
    enum PersistResult {
        case notPersisted
        case persisted
        case failure(MyDataHelpsError)
    }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var model: PersistDeviceDataViewModel
    @State var result = PersistResult.notPersisted
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Identifier:")
            TextField("Optional", text: $model.identifier)
                .padding(.bottom, 20)
            Text("Type:")
            TextField("Type", text: $model.type)
                .padding(.bottom, 20)
            Text("Value:")
            TextField("Value", text: $model.value)
            switch result {
            case .persisted: Text("Saved!")
            case let .failure(error):
                Text(error.localizedDescription)
                    .foregroundColor(Color(.systemRed))
            case .notPersisted: Text("")
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
        Task {
            do {
                try await model.session.persistDeviceData([persistModel])
                result = .persisted
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                result = .failure(MyDataHelpsError(error))
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
