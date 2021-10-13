//
//  RegistrationService.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 03/10/2021.
//

import Combine
import Foundation
import FirebaseDatabase
import FirebaseAuth

enum RegistrationKeys:String {
    case email
    case password
    case name
}

protocol RegistrationService {
    func register(with userInfo:UserRegisterModel) -> AnyPublisher<Void,Error>
}

final class RegistrationServiceImpl: RegistrationService {
    
    
    func register(with userInfo: UserRegisterModel) -> AnyPublisher<Void, Error> {
        
        Deferred {
            Future { promise in
                Auth.auth()
                    .createUser(withEmail: userInfo.email, password: userInfo.password) { (result, error) in
                        if let err = error {
                            promise(.failure(err))
                        }else {
                            if let uid = result?.user.uid {
                                let values = [RegistrationKeys.email.rawValue:userInfo.email,
                                              RegistrationKeys.password.rawValue:userInfo.password,RegistrationKeys.name.rawValue:userInfo.username  ] as [String:Any]
                                
                                Database.database(url: "https://glow-ai-default-rtdb.europe-west1.firebasedatabase.app")
                                    .reference()
                                    .child("users")
                                    .child(uid)
                                    .updateChildValues(values){err, ref in
                                        if let err = error {
                                            promise(.failure(err))
                                        } else {
                                            print("success")
                                            promise(.success(()))
                                        }
                                    }
                            }else {
                                promise(.failure(NSError(domain: "Invalid User id", code: 0, userInfo: nil)))
                            }
                        }
                    }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
