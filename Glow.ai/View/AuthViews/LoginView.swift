//
//  Login.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 10/09/2021.
//


import SwiftUI

struct LoginView: View {
    @StateObject private var loginVM = LoginViewModel(service: LoginService())
//    @Binding var isLoginPresented: Bool
    @State var alertModel:AlertModel = AlertModel()
    @EnvironmentObject var authModel:AuthViewModel
    @EnvironmentObject var sessionService: SessionService


    var body: some View {
        if !loginVM.loggedIn {
            NavigationView {
                ZStack{
                    Color.black
                    ScrollView(showsIndicators: false) {
                        
                        
                        VStack{
                            
                            Spacer()
                                .frame(height: 200)
                            Text("Login")
                                .foregroundColor(Color.newPrimaryColor)
                                .font(Font.custom("TitilliumWeb-Bold", size: 80))
                            VStack{
                                CustomTextField(
                                     placeholder: Text("Enter Your Email").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                                    text: $loginVM.credentials.email, imageName: "envelope.open.fill", isSecure: false)
                                
                                
                                CustomTextField(
                                    placeholder: Text("Enter Your Password").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                                    text: $loginVM.credentials.password, imageName: "lock.fill", isSecure: true)
                                
                            }
                            
                          
                            Button(action: {
                                        print("Login Tapped")
                                
                                if !loginVM.credentials.email.isEmpty && !loginVM.credentials.password.isEmpty {
                                    print("Not empty")
                                    self.alertModel.isAlertPresented = false
                                    loginVM.login()
                                    if loginVM.loggedIn {
                                        sessionService.state = .loggedIn
                                    }
                                 
    //                                authModel.signIn(email: loginVM.credentials.email, password: loginVM.credentials.password,compltionHandler: { (result, error) in
    //                                    guard result != nil, error == nil else {
    //                                        self.alertModel.textAlertTitle = "ERROR AUTHENTIFICATION"
    //                                        self.alertModel.textAlertMessage = "Please check your email or password"
    //                                        self.alertModel.isAlertPresented = true
    //                                        return
    //                                    }
    ////                                    isLoginPresented.toggle()
    ////                                    print(result?.user.email)
    //
    //                                })
    //
                                }else {
                                    self.alertModel.textAlertTitle = "EMPTY TEXT FIELD"
                                    self.alertModel.textAlertMessage = "Please fill all the text fields"
                                    self.alertModel.isAlertPresented = true
                                }
                                    }) {
                                        Text("Login")
                                            .customButton()
                              
                            }
                            .padding(.top,25)
                            
                            VStack{
                                Divider()
                                    
                                Text("OR").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16))
                                Divider()
                            }
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                            print("apple Tapped")
                                        }) {
                                    Image("apple")
                                        .resizable()
                                        .frame(width: 52, height: 52,alignment: .center)
                                }
                                Spacer()
                                Button(action: {
                                            print("google Tapped")
                                        }) {
                                    Image("google")
                                        .resizable()
                                        .frame(width: 52, height: 52,alignment: .center)
                                }
                                Spacer()
                            }
                            Button(action:{
                                print("go to register page tapped")
                                
                            }) {
                                NavigationLink(destination: RegisterView().navigationBarHidden(true)) {
                                    Text("Don't have an account?").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 18)).underline()
                                        .padding(.top,30)
                                }
                                .navigationBarTitleDisplayMode(.inline)
                                .navigationBarHidden(true)
                                
                               
                            }
                           
                                
                            Spacer()
                                .frame(height:130)
                        }
                        .padding(.horizontal,15)
                            
                    }
                    .alert(isPresented: $alertModel.isAlertPresented) {

                                Alert(
                                    title: Text(self.alertModel.textAlertTitle),
                                    message: Text(self.alertModel.textAlertMessage)
                                )
                            }
                    .preferredColorScheme(.dark)
                    .ignoresSafeArea(.all, edges: .all)
                    }
                
                    
            }
            .onAppear(perform: {
                sessionService.setupFirebaseHandler()
                
            })
            
        }else {
            NavigationLink(destination: CameraView(), isActive: $loginVM.loggedIn) { EmptyView() }
        }
        
     
       
    }
    
    
    
}

//struct Login_Previews: PreviewProvider {
//    static var previews: some View {
//        Login()
//    }
//}


