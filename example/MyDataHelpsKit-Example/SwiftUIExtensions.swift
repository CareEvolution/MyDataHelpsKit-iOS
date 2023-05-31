//
//  SwiftUIExtensions.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/16/23.
//

import SwiftUI

extension Image {
    static func logoPlaceholder() -> some View {
        Image(systemName: "building.2")
            .resizable()
            .foregroundColor(.secondary)
    }
}
