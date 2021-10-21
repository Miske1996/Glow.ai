//
//  RegisterViewModel.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 23/09/2021.
//

import Foundation
import Combine
enum RegistrationState {
    case successfull
    case failed(error:Error)
    case na
}

protocol RegisterViewModelProtocol {
    func register(completionHandler: @escaping () -> Void)
    var service: RegistrationService {get}
    var state: RegistrationState {get}
    var userInfo: UserRegisterModel {get}
    init(service:RegistrationService)
}

final class RegisterViewModel: ObservableObject , RegisterViewModelProtocol{
   
    var service: RegistrationService
    
    var state: RegistrationState = .na
    
    @Published var userInfo: UserRegisterModel = UserRegisterModel(email: "", username: "", password: "", confirmedPassword: "")
    
    private var subscriptions = Set<AnyCancellable>()
    init(service: RegistrationService) {
        self.service = service
        if isTextFieldEmpty() {
             self.textFieldValidationText = ""
        }else {
             self.textFieldValidationText = "Empty Field"
        }
    }
    
    
    func register(completionHandler: @escaping () -> Void) {
        service
            .register(with: userInfo)
            .sink { [weak self] res in
                
                switch res {
                case .failure(let error):
                    self?.state = .failed(error:error)
                default:break
                }
                
            } receiveValue: { [weak self] in
                self?.state = .successfull
                completionHandler()
            }
            .store(in: &subscriptions)          
    }
    
    
    
//    @Published var user = UserRegisterModel()
    @Published var textFieldValidationText:String = ""
   
    var isTextFieldValid:Bool {
        return isTextFieldEmpty()
    }

    func isTextFieldEmpty() -> Bool {
        if !userInfo.email.isEmpty && !userInfo.username.isEmpty && !userInfo.password.isEmpty && !userInfo.confirmedPassword.isEmpty  {
            return true
        }else {
            return false
        }
    }
    
    
    
}
