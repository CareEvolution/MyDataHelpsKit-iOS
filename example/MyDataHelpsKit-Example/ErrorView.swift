//
//  ErrorView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct ErrorView: View {
    struct Model: Identifiable {
        let id = UUID().uuidString
        let title: String
        let error: MyDataHelpsError
        
        var errorDescription: String {
            switch error {
            case let .decodingError(underlying):
                return "Decoding error: \(underlying.localizedDescription)"
            case let .encodingError(underlying):
                return "Encoding error: \(underlying.localizedDescription)"
            case let .serverError(underlying):
                return "Server error: HTTP \(underlying.statusCode): \(underlying.message ?? underlying.localizedDescription)"
            case let .tooManyRequests(limit, underlying):
                let resetDate: String
                if #available(iOS 15.0, *) {
                    resetDate = limit.nextReset.formatted(.dateTime.hour().minute().second())
                } else {
                    resetDate = "\(limit.nextReset)"
                }
                return "Too many requests: exceeded \(limit.maxRequestsPerHour), reset at \(resetDate) [\(underlying.message ?? "")]"
            case let .timedOut(underlying):
                return "Timed out: \(underlying.localizedDescription)"
            case let .unauthorizedRequest(underlying):
                return "Unauthorized: \(underlying.localizedDescription)"
            case let .unknown(.some(underlying)):
                return "Unknown error: \(underlying.localizedDescription)"
            case .unknown(.none):
                return "Unknown error"
            case let .webContentError(.some(underlying)):
                return "Web content error: \(underlying.localizedDescription)"
            case .webContentError(.none):
                return "Web content error"
            }
        }
    }
    
    let model: Model
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(model.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.red)
                
            Text(model.errorDescription)
                .font(.caption)
                .foregroundColor(Color.red)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(model: .init(title: "Error Doing X", error: .unknown(nil)))
            .padding()
    }
}
