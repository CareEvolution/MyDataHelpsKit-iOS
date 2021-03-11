//
//  Diagnostics.swift
//  MyDataHelpsKit
//
//  Created by CareEvolution on 3/11/21.
//

import Foundation

// https://stackoverflow.com/a/25467259
internal func getHardwareModelIdentifier() -> String? {
    var size: size_t = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    var machine = [CChar](repeating: 0, count: Int(size))
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    let model = String(cString: &machine, encoding: String.Encoding.utf8)
    return model
}

internal func getOSVersionString() -> String {
    let version = ProcessInfo().operatingSystemVersion
    return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
}
