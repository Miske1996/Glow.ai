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
import GoogleSignIn
import AuthenticationServices


enum SessionState {
    case loggedIn
    case loggedOut
}

protocol SessionServiceProtocol {
    var state: SessionState {get}
    var userDetails: SessionUserDetails {get}
    func logout(completionHandler: @escaping () -> Void)
}

final class SessionService:NSObject, ObservableObject,SessionServiceProtocol, GIDSignInDelegate {

    
    @Published var state: SessionState = .loggedOut
    @Published var userDetails: SessionUserDetails = SessionUserDetails(email: "", username: "")
    @Published var user = Auth.auth().currentUser
    override init() {
        super.init()
        setupGoogleSignIn()
    }
    
    private var handler: AuthStateDidChangeListenerHandle?
    func logout(completionHandler: @escaping () -> Void) {
        do {
            
            try Auth.auth().signOut()
            self.state = .loggedOut
            completionHandler()
        }
            catch { print("already logged out") }
        
        
    }
    
    
    
    
}

extension SessionService {
    
    func setupFirebaseHandler(completionHandler: @escaping () -> Void) {
        handler = Auth
                    .auth()
                    .addStateDidChangeListener {[weak self] res,user in
                
                        guard let self = self else {return}
                        self.state = user == nil ? .loggedOut : .loggedIn
                        if let uid = user?.uid {
                            self.handleRefresh(with: uid,completionHandler: completionHandler)
                        }
                    }
        }
    
    func handleRefresh(with uid:String,completionHandler: @escaping () -> Void) {
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
                    self.state = .loggedIn
                    completionHandler()
                } 
            }
    }
}

extension SessionService {
    // MARK: - LOGIN WITH GOOGLE
  
  
    
    func signInWithGoogle() {
        if GIDSignIn.sharedInstance().currentUser == nil {
          GIDSignIn.sharedInstance().presentingViewController = UIApplication.shared.windows.first?.rootViewController
          GIDSignIn.sharedInstance().signIn()
        }else {
            print("NOT NIL")
        }
      }
    
    func logoutFromGoogle() {
      GIDSignIn.sharedInstance().signOut()

      do {
        try Auth.auth().signOut()
        self.user = Auth.auth().currentUser
        self.state = .loggedOut
          
      } catch let signOutError as NSError {
        print(signOutError.localizedDescription)
      }
    }

      // 6
       func setupGoogleSignIn() {
        GIDSignIn.sharedInstance().delegate = self
      }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            firebaseAuthentication(withUser: user)
        } else {
          print(error.debugDescription)
        }
      }

      // 2
      private func firebaseAuthentication(withUser user: GIDGoogleUser) {
        if let authentication = user.authentication {
          let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)

          Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
              print(error.localizedDescription)
            } else {
                self.user = Auth.auth().currentUser
                self.state = .loggedIn
            }
          }
        }
      }
}


