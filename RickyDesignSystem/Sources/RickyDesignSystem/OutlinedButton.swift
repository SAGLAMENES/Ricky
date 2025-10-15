//
//  OutlinedButton.swift
//  RickyDesignSystem
//
//  Created by Burak Arslan on 14.10.2025.
//

import Foundation
import SwiftUI

public struct OutlineButton: View {
    let title: String
    var action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.blue, lineWidth: 1.5)
        )
    }
}
