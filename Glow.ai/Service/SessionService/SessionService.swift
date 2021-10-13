//
//  SessionService.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 04/10/2021.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase
enum SessionState {
    case loggedIn
    case loggedOut
}

protocol SessionServiceProtocol {
    var state: SessionState {get}
    var userDetails: SessionUserDetails {get}
    func logout()
}

final class SessionService: ObservableObject,SessionServiceProtocol {

    
    @Published var state: SessionState = .loggedOut
    @Published var userDetails: SessionUserDetails = SessionUserDetails(email: "", username: "")
    
    private var handler: AuthStateDidChangeListenerHandle?
    func logout() {
        try? Auth.auth().signOut()
        self.state = .loggedOut
    }
    
    
    
}

extension SessionService {
    
    func setupFirebaseHandler() {
        handler = Auth
                    .auth()
                    .addStateDidChangeListener {[weak self] res,user in
                
                        guard let self = self else {return}
                        self.state = user == nil ? .loggedOut : .loggedIn
                        if let uid = user?.uid {
                            self.handleRefresh(with: uid)
                        }
                    }
        }
    
    func handleRefresh(with uid:String) {
        Database
            .database(url: "https://glow-ai-default-rtdb.europe-west1.firebasedatabase.app")
            .reference()
            .child("users")
            .child(uid)
            .observe(.value) { [weak self] snapshot in
               
                guard let self = self,
                      let value = snapshot.value as? NSDictionary,
                      let email = value[RegistrationKeys.email.rawValue] as? String,let username = value[RegistrationKeys.name.rawValue] as? String else {
                    return
                }

                DispatchQueue.main.async {
                    print("****")
                    print(email)
                    print("****")
                    self.userDetails = SessionUserDetails(email: email, username: username)
                } 
            }
    }
}
