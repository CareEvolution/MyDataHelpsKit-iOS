//
//  ErrorView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

extension MyDataHelpsError {
    var localizedDescription: String {
        switch self {
        case let .decodingError(underlying):
            return "Decoding error: \(underlying.localizedDescription)"
        case let .encodingError(underlying):
            return "Encoding error: \(underlying.localizedDescription)"
        case .invalidSurvey:
            return "Survey not found"
        case let .serverError(underlying):
            return "Server error: HTTP \(underlying.statusCode): \(underlying.message ?? underlying.localizedDescription)"
        case let .tooManyRequests(limit, underlying):
            return "Too many requests: exceeded \(limit.maxRequestsPerHour), reset at \(limit.nextReset.formatted(.dateTime.hour().minute().second())) [\(underlying.message ?? "")]"
        case let .timedOut(.some(underlying)):
            return "Timed out: \(underlying.localizedDescription)"
        case .timedOut(.none):
            return "Timed out"
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

struct ErrorView: View {
    struct Model: Identifiable {
        let id = UUID().uuidString
        let title: String
        let error: MyDataHelpsError
    }
    
    let model: Model
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(model.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.red)
                
            Text(model.error.localizedDescription)
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
