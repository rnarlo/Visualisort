//
//  ButtonStyle.swift
//  Visualisort
//
//  Created by chr1s on 2/12/25.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding(.horizontal)
            .padding(.vertical, 20)
            .foregroundColor(configuration.isPressed ? ColorPalette.white.opacity(0.8) : ColorPalette.white)
            .background(configuration.isPressed ? ColorPalette.darkGray.opacity(0.8) : ColorPalette.darkGray)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay (
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(ColorPalette.black, lineWidth: 1)
                }
            )
    }
}

struct SortButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .padding(.horizontal)
            .padding(.vertical, 20)
            .foregroundColor(configuration.isPressed ? Color.black.opacity(0.8) : Color.black)
            .background(configuration.isPressed ? ColorPalette.pink.opacity(0.8) : ColorPalette.pink)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay (
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(ColorPalette.black, lineWidth: 1)
                }
            )
    }
}
