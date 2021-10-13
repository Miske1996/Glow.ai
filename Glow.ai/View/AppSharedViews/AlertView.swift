//
//  AlertView.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 01/10/2021.
//

import SwiftUI

struct AlertView: View {
    @Binding var isPresented:Bool
    var body: some View {
        Button("Show Alert") {
                    
                }
                .alert(isPresented: $isPresented) {
                    Alert(title: Text("Important message"), message: Text("Wear sunscreen"), dismissButton: .default(Text("Got it!")))
                }
    }
}
