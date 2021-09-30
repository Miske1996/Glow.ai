//
//  RegisterViewModel.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 23/09/2021.
//

import Foundation

class RegisterViewModel: ObservableObject {
     @Published var email = ""
     @Published var username = ""
     @Published var password = ""
     @Published var confirmedPassword = ""
    
    var isTextFieldValid:Bool {
        return isTextFieldEmpty()
    }
    
    func isTextFieldEmpty() -> Bool {
        if !email.isEmpty && !username.isEmpty && !password.isEmpty && !confirmedPassword.isEmpty  {
            return true
        }else {
            return false
        }
    }
    var textFieldValidationText:String {
      print("TEST")
       if isTextFieldEmpty() {
           return ""
       }else {
           return "Empty Field"
       }
   }
    
    
}
