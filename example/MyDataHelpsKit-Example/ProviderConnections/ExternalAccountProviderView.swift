//
//  ExternalAccountProviderView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 3/29/23.
//

import SwiftUI
import MyDataHelpsKit

struct ExternalAccountProviderView: View {
    let provider: ExternalAccountProvider
    
    var body: some View {
        HStack(alignment: .center) {
            if let logoURL = provider.logoURL {
                AsyncImage(url: logoURL) { image in
                    image.resizable()
                } placeholder: {
                    Image.logoPlaceholder()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 45, height: 45)
            }
            VStack(alignment: .leading) {
                Text(provider.name)
                    .font(.body)
                    .fontWeight(.semibold)
                Text(provider.category.rawValue)
                    .font(.caption)
            }
            Spacer()
            Image(systemName: "plus")
                .font(.subheadline)
                .foregroundColor(.accentColor)
        }
    }
}

struct ExternalAccountProviderView_Previews: PreviewProvider {
    static var previews: some View {
        ExternalAccountProviderView(provider: PreviewData.externalAccountProvider)
            .padding()
    }
}
