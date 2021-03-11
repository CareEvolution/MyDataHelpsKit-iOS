//
//  ErrorView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/26/21.
//

import SwiftUI
import MyDataHelpsKit

struct ErrorView: View {
    let title: String
    let error: MyDataHelpsError
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.red)
                
            Text(error.localizedDescription)
                .font(.caption)
                .foregroundColor(Color.red)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(title: "Error Doing X", error: .unknown(nil))
            .padding()
    }
}
