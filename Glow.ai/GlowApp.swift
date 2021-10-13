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
    @StateObject var sessionService = SessionService()
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            
            NavigationView {
                switch sessionService.state {
                case .loggedIn:
                    CameraView()
                case .loggedOut:
                    LoginView()
                
                }
               
            }
            .environmentObject(sessionService)
            
        }
        
        
        
        
    }
    
}
