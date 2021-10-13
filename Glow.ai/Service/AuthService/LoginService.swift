//
//  LoginService.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 05/10/2021.
//

import Foundation
import Combine
import FirebaseAuth
protocol LoginServiceProtocol {
    func login(with credentials: UserLoginModel ) -> AnyPublisher<Void,Error>
}

final class LoginService: LoginServiceProtocol {
    
    
    func login(with credentials: UserLoginModel) -> AnyPublisher<Void, Error> {
        
        Deferred {
            Future { promise in
                Auth
                    .auth()
                    .signIn(withEmail: credentials.email, password: credentials.password) { (result, error) in
                        if let err = error {
                            promise(.failure(err))
                        } else {
                            promise(.success(()))
                        }
                    }
            }
            
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    
}
