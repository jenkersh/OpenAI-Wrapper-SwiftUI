//
//  InfoCard.swift
//  SwiftUI-AI-Wrapper
//
//  Created by Jen Kersh on 7/13/25.
//

import SwiftUI

struct InfoCard: View {
    let heading: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(heading)
                .font(.headline)
                .foregroundColor(.accentColor)

            Text(content)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}
