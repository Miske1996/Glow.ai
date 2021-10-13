//
//  Auth.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 22/09/2021.
//

import FirebaseAuth

class AuthViewModel:ObservableObject {
    
    let auth = Auth.auth()
    
    var isSignedIn: Bool {
        return auth.currentUser != nil
    }
    
    func signIn(email: String , password: String,compltionHandler: ((AuthDataResult?,Error?) -> Void)?){
        auth.signIn(withEmail: email, password: password,completion: compltionHandler)
    }
    
    func signUp(email:String,password:String,compltionHandler: ((AuthDataResult?,Error?) -> Void)?){
        auth.createUser(withEmail: email, password: password,completion: compltionHandler)
    }
}
