//
//  ProjectInfoView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 8/11/22.
//

import SwiftUI
import MyDataHelpsKit

struct ProjectInfoView: View {
    let project: ProjectInfo
    
    var body: some View {
        HStack(alignment: .top) {
            RemoteImageView(url: project.organization.logoURL, placeholderImageName: "providerLogoPlaceholder")
                .aspectRatio(contentMode: .fit)
                .frame(width: 45, height: 45)
            VStack(alignment: .leading) {
                Text(project.name)
                    .font(.subheadline)
                Text(project.organization.name)
                    .font(.footnote)
                Text(project.code)
                    .font(.caption)
                if let learnMoreURL = project.learnMoreURL,
                   let learnMoreTitle = project.learnMoreTitle {
                    Link(learnMoreTitle, destination: learnMoreURL)
                        .font(.caption)
                }
            }
        }
    }
}

struct ProjectInfoView_Previews: PreviewProvider {
    private static let projectJSON: Data = """
{
    "id": "\(UUID().uuidString)",
    "name": "Example Project",
    "description": "Project description",
    "code": "ABCDEF",
    "type": "Research Study",
    "organization": {
        "id": "\(UUID().uuidString)",
        "name": "My Organization",
        "description": "Organization description",
        "logoUrl": "https://careevolution.com/images/rkstudio-logo.png",
        "color": "#0c509b"
    },
    "supportEmail": "support@example.com",
    "supportPhone": "(555) 555-1212",
    "learnMoreLink": "https://example.com",
    "learnMoreTitle": "Learn More"
}
""".data(using: .utf8)!
    
    static var project: ProjectInfo {
        try! JSONDecoder.myDataHelpsDecoder.decode(ProjectInfo.self, from: projectJSON)
    }
    
    static var previews: some View {
        ProjectInfoView(project: project)
    }
}
