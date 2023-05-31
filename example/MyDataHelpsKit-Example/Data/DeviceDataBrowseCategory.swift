//
//  DeviceDataBrowseCategory.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/30/23.
//

import Foundation
import MyDataHelpsKit

struct DeviceDataBrowseCategory: Identifiable, Comparable, Hashable, Codable {
    static func < (lhs: DeviceDataBrowseCategory, rhs: DeviceDataBrowseCategory) -> Bool {
        if lhs.namespace == rhs.namespace {
            return (lhs.type ?? "") < (rhs.type ?? "")
        } else {
            return lhs.namespace.rawValue < rhs.namespace.rawValue
        }
    }
    
    let id: String
    let namespace: DeviceDataNamespace
    let type: String?
    
    var query: DeviceDataQuery {
        if let type {
            return DeviceDataQuery(namespace: namespace, types: Set([type]))
        } else {
            return DeviceDataQuery(namespace: namespace)
        }
    }
    
    var title: String {
        if let type {
            return "\(query.namespace.rawValue): \(type)"
        } else {
            return query.namespace.rawValue
        }
    }
    
    init(namespace: DeviceDataNamespace, type: String?) {
        self.id = "\(namespace.rawValue)|\(type ?? "")"
        self.namespace = namespace
        self.type = type
    }
}
