//
//  DeviceDataChartView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/28/23.
//

import SwiftUI
import Charts
import MyDataHelpsKit

struct DeviceDataChartModel {
    struct Point {
        let index: Int
        let date: Date
        let value: Double
    }
    
    let title: String
    let xAxisLabel: String
    let yAxisLabel: String
    let accentColor: Color
    let allDataPath: DataNavigationPath
    let dataPoints: [Point]
}

extension DeviceDataChartModel {
    init(title: String, xAxisLabel: String, yAxisLabel: String, accentColor: Color, allDataPath: DataNavigationPath, deviceDataResult: DeviceDataResultPage) {
        self.title = title
        self.xAxisLabel = xAxisLabel
        self.yAxisLabel = xAxisLabel
        self.accentColor = accentColor
        self.allDataPath = allDataPath
        self.dataPoints = deviceDataResult.deviceDataPoints.enumerated().compactMap { index, dataPoint in
            guard let date = dataPoint.observationDate,
                  let value = Double(dataPoint.value) else {
                return nil
            }
            return .init(index: index, date: date, value: value)
        }
    }
}

struct DeviceDataChartView: View {
    let model: DeviceDataChartModel
    
    var body: some View {
        Text(model.title)
            .font(.headline)
            .padding(.bottom, 4)
        Chart(model.dataPoints, id: \.index) {
            BarMark(
                x: .value(model.xAxisLabel, $0.date, unit: .day),
                y: .value(model.yAxisLabel, $0.value)
            )
        }
        .accentColor(model.accentColor)
        .padding(8)
        .chartBackground { _ in
            Rectangle().fill(
                Gradient(colors: [
                    .clear,
                    model.accentColor.opacity(0.1)
                ])
            )
            .cornerRadius(4)
        }
        
        NavigationLink(value: model.allDataPath) {
            Text("Show All Data")
        }
    }
}

struct DeviceDataChartSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                Section {
                    DeviceDataChartView(model: previewModel)
                }
                .listRowSeparator(.hidden)
            }
        }
    }
    
    static var previewModel: DeviceDataChartModel {
        let heartRates: [Double] = [60, 62, 67, 59, 63, 70, 74, 79, 85, 88, 75, 68, 64, 63]
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -heartRates.count, to: .now) ?? .now
        
        return DeviceDataChartModel(
            title: "Resting Heart Rate",
            xAxisLabel: "Date",
            yAxisLabel: "bpm",
            accentColor: .red,
            allDataPath: .browseDeviceData(DeviceDataBrowseCategory(namespace: .appleHealth, type: "RestingHeartRate")),
            dataPoints: heartRates.enumerated().map { index, bpm in
                .init(index: index, date: calendar.date(byAdding: .day, value: index, to: startDate) ?? .now, value: bpm)
        })
    }
}
