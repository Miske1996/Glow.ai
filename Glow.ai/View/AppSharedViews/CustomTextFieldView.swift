//
//  CustomTextFieldView.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 30/09/2021.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var commit: ()->() = { }
    let imageName:String
    let isSecure:Bool
    var body: some View {
        ZStack(alignment: .leading) {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(Color.newPrimaryColor)
                ZStack{
                    if text.isEmpty { placeholder }
                    VStack {
                        if !isSecure {
                            TextField("", text: $text).foregroundColor(Color.white).font(Font.custom("TitilliumWeb-ExtraLight", size: 16))
                                .accentColor(Color.newPrimaryColor)
                        } else {
                            SecureField("", text: $text).foregroundColor(Color.white).font(Font.custom("TitilliumWeb-ExtraLight", size: 16))
                                .accentColor(Color.newPrimaryColor)
                        }                   
                    }
                }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(Color.newPrimaryColor))
            
            
        }
    }
    
    
}
