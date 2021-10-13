//
//  Register.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 08/09/2021.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var registerVM = RegisterViewModel(service: RegistrationServiceImpl())
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authModel:AuthViewModel
    @State var alertModel:AlertModel = AlertModel()
    var body: some View {
        
        ZStack{
            Color.black
            ScrollView(showsIndicators: false) {
                VStack{
                    
                    Spacer()
                        .frame(height: 125)
                    Text("Register")
                        .foregroundColor(Color.newPrimaryColor)
                        .font(Font.custom("TitilliumWeb-Bold", size: 80))
                    VStack{
                        CustomTextField(
                             placeholder: Text("Enter Your Email").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                            text: $registerVM.userInfo.email, commit:  {
                                print(registerVM.userInfo.email)
                            }, imageName: "envelope.open.fill", isSecure: false)
                        
                        CustomTextField(
                             placeholder: Text("Enter Your Username").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                            text: $registerVM.userInfo.username, commit:  {
                                print(registerVM.userInfo.username)
                            }, imageName: "person.fill", isSecure: false)
                        CustomTextField(
                           placeholder: Text("Enter Your Password").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                            text: $registerVM.userInfo.password, commit:  {
                                print(registerVM.userInfo.username)
                            }, imageName: "lock.fill", isSecure: true)
                        CustomTextField(
                            placeholder: Text("Confirm Your Password").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                            text: $registerVM.userInfo.confirmedPassword, commit:  {
                                print(registerVM.userInfo.username)
                            }, imageName: "lock.fill", isSecure: true)
                    }
                    
                  
                    Button(action: {
                            
                            if !registerVM.userInfo.email.isEmpty && !registerVM.userInfo.password.isEmpty && !registerVM.userInfo.username.isEmpty && !registerVM.userInfo.confirmedPassword.isEmpty {
                                print("Not empty")
                                self.alertModel.isAlertPresented = false
                                registerVM.register()
//                                authModel.signUp(email: registerVM.user.email, password: registerVM.user.password,compltionHandler: { (result, error) in
//                                    guard result != nil, error == nil else {
//                                        self.alertModel.textAlertTitle = "ERROR"
//                                        self.alertModel.textAlertMessage = "Please check your information"
//                                        self.alertModel.isAlertPresented = true
//                                        return
//                                    }
//                                   
//                             print(result?.user.email)
//                                    print("SUCCESS")
//                                })
                                
                            }else {
                                self.alertModel.textAlertTitle = "EMPTY TEXT FIELD"
                                self.alertModel.textAlertMessage = "Please fill all the text fields"
                                self.alertModel.isAlertPresented = true
                            }}) {
                                Text("Register")
                                    .customButton()
                      
                    }
                    .padding(.top,40)
                    Spacer()
                        .frame(height: 30)
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
                    .padding(.top,20)
                    Button(action:{
                        print("go to login page tapped")
                        self.presentationMode.wrappedValue.dismiss()
                        
                    }) {
                        Text("Already have an account?").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 18)).underline()
                            .padding(.top,30)
                    }
                    Spacer()
                        .frame(height: 100)
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
    
    
}

struct Register_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}




