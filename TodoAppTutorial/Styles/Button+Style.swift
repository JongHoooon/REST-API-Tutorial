//
//  Button+Style.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/15.
//

import Foundation
import SwiftUI


struct MyDefaultButtonStyle: ButtonStyle {
    
    let bgColor: Color
    let textColor: Color
    
    init(bgColor: Color = Color.blue,
         textColor: Color = Color.white) {
        self.bgColor = bgColor
        self.textColor = textColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .foregroundColor(textColor)
            Spacer()
        }
        .padding()
        .background(bgColor.cornerRadius(8))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
