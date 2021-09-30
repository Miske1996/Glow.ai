//
//  GlowApp.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 02/09/2021.
//
import SwiftUI
import Firebase
@main
struct GlowApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            let authModel = AuthViewModel()
            ContentView()
                .environmentObject(authModel)
        }
    }
}
