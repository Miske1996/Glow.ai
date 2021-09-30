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
    
    func signIn(email: String , password: String){
        auth.signIn(withEmail: email, password: password) {resutl,error in
            guard resutl != nil, error == nil else {
                return
            }
            print(resutl?.user.refreshToken)
            print("hello")
            //Success
        }
        
    }
    
    func signUp(email:String,password:String){
        
        auth.createUser(withEmail: email, password: password){resutl,error in
            guard resutl != nil, error == nil else {
                return
            }
            print(resutl?.user.email)
            print("hello")
            //Success
        }
            
        
    }
}
