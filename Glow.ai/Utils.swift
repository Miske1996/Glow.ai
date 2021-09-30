//
//  Utils.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 10/09/2021.
//

import SwiftUI


extension Color {
    static let oldPrimaryColor = Color(UIColor.systemIndigo)
    static let newPrimaryColor = Color("PrimaryColor")
}

extension View {
    func customButton() -> ModifiedContent<Self, ButtonModifier> {
        return modifier(ButtonModifier())
    }
}


struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.custom("TitilliumWeb-Bold", size: 24))
            .foregroundColor(.white)
            .padding()
            .frame(width: UIScreen.main.bounds.width - 30, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 8, style:   .circular).fill(Color.newPrimaryColor))
            .padding(.bottom, 8)
    }
}
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
