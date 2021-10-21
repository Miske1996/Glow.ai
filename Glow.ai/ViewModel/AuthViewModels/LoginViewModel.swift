//
//  LoginViewModel.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 30/09/2021.
//

import Foundation
import Combine
import GoogleSignIn

enum LoginState {
    case successfull
    case failed(error:Error)
    case na
}

protocol LoginViewModelProtocol {
    func login(completionHandler: @escaping () -> Void)
    var service: LoginServiceProtocol {get}
    var state: LoginState {get}
    var credentials: UserLoginModel {get}
    init(service: LoginServiceProtocol)
}

class LoginViewModel: ObservableObject , LoginViewModelProtocol{
   
    
 
    
    var service: LoginServiceProtocol
    
    @Published var state: LoginState = .na
    
    @Published var credentials: UserLoginModel = UserLoginModel(email: "", password: "")
    
    @Published var loggedIn:Bool = false
    private var subscriptions = Set<AnyCancellable>()
    
    required init(service: LoginServiceProtocol) {
        self.service = service
        if isTextFieldEmpty() {
             self.isTextFieldsEmpty = ""
        }else {
             self.isTextFieldsEmpty = "Fill All The Fields"
        }
    }
    @Published var isTextFieldsEmpty:String = ""
    var isTextFieldValid:Bool {
        return isTextFieldEmpty()
    }
    
    func isTextFieldEmpty() -> Bool {
        if !credentials.email.isEmpty &&  !credentials.password.isEmpty   {
            return true
        }else {
            return false
        }
    }
    
    
    func login(completionHandler: @escaping () -> Void) {
        
        service
            .login(with: credentials)
            .sink { res in
                
                switch res {
                case .failure(let err):
                    print("FAILED")
                    self.state = .failed(error:err)
                    self.loggedIn = false
                default: break
                }
                
            } receiveValue: { [weak self] in
                print("SUCCESSSSS")
                self?.state = .successfull
                self?.loggedIn = true
                completionHandler()
            }
            .store(in: &subscriptions)
    }
    
}
