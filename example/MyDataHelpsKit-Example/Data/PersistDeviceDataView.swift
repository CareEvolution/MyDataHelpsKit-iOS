//
//  PersistDeviceDataView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 4/1/21.
//

import SwiftUI
import MyDataHelpsKit

extension DeviceDataNamespace {
    /// Only `project` device data can be directly edited via the SDK.
    var isEditable: Bool {
        self == .project
    }
}

@MainActor class PersistDeviceDataViewModel: ObservableObject {
    @Published var isValid = false
    @Published var identifier = ""
    @Published var type = "" {
        didSet {
            validate()
        }
    }
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
        validate()
    }
    
    func validate() {
        isValid = !type.trimmingCharacters(in: .whitespaces).isEmpty
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
    
    @StateObject var model: PersistDeviceDataViewModel
    @State private var result = PersistResult.notPersisted
    @FocusState private var typeFocus: Bool
    @FocusState private var valueFocus: Bool
    
    var body: some View {
        Form {
            Section("Identity") {
                TextField("Type", text: $model.type)
                    .focused($typeFocus)
                    .autocorrectionDisabled()
                TextField("Identifier (optional)", text: $model.identifier)
                    .autocorrectionDisabled()
            }
            
            Section("Value") {
                TextField("Value", text: $model.value)
                    .focused($valueFocus)
            }
            
            Section {
                switch result {
                case .persisted:
                    Text("Saved!")
                case let .failure(error):
                    ErrorView(model: .init(title: "Failed to save data point", error: error))
                case .notPersisted:
                    EmptyView()
                }
            }
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(!model.isValid)
            }
        }
        .onAppear {
            if model.isNew {
                typeFocus = true
            } else {
                valueFocus = true
            }
        }
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
            } catch {
                result = .failure(MyDataHelpsError(error))
            }
        }
    }
}

struct PersistDeviceDataView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PersistDeviceDataView(model: .init(session: ParticipantSessionPreview()))
        }
        NavigationStack {
            PersistDeviceDataView(model: .init(existing: .init(session: ParticipantSessionPreview(), namespace: .project, id: .init(UUID().uuidString), identifier: nil, type: "DataType1", value: "ExistingValue", units: nil, source: nil, startDate: nil, observationDate: Date())))
        }
    }
}
