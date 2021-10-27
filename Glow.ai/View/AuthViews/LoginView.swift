//
//  Login.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 10/09/2021.
//


import SwiftUI
import FirebaseAuth
struct LoginView: View {
    @StateObject private var loginVM = LoginViewModel(service: LoginService())
    @State var alertModel:AlertModel = AlertModel()
    @EnvironmentObject var authModel:AuthViewModel
    @EnvironmentObject var sessionService: SessionService
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
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
                                    loginVM.login {
                                        sessionService.state = .loggedIn
                                    }



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
//                                Button(action: {
//
//                                            print("apple Tapped")
//                                        }) {
//                                    Image("apple")
//                                        .resizable()
//                                        .frame(width: 52, height: 52,alignment: .center)
//                                }
                                SignInWithAppleToFirebase({ response in
                                            if response == .success {
                                                print("logged into Firebase through Apple!")
                                                
                                                sessionService.setupFirebaseHandler {
                                                }
                                            } else if response == .error {
                                                print("error. Maybe the user cancelled or there's no internet")
                                            }
                                },sessionService: self.sessionService)
                               
                                Spacer()
                                Button(action: {
                                            print("google Tapped")
                                            sessionService.signInWithGoogle()
                                            
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
                                NavigationLink(destination: RegisterView().environmentObject(sessionService).navigationBarHidden(true)) {
                                    Text("Don't have an account?").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 18)).underline()
                                        .padding(.top,30)
                                }
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
            .navigationBarHidden(true)
           
            
            
        
        
     
       
    }
    
    
    
}

//struct Login_Previews: PreviewProvider {
//    static var previews: some View {
//        Login()
//    }
//}


