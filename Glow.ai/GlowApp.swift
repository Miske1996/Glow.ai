//
//  GlowApp.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 02/09/2021.
//
import SwiftUI
import Firebase
import GoogleSignIn
@main
struct GlowApp: App {
    @StateObject var sessionService = SessionService()
    @StateObject var recording = Recording()
    init() {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID

    }
    var body: some Scene {
        WindowGroup {
                    CameraView()
                        .environmentObject(sessionService)
                        .environmentObject(recording)
                        
            
        }
    }
    
}
