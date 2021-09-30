//
//  Register.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 08/09/2021.
//

import SwiftUI

struct Register: View {
    @ObservedObject var registerVM = RegisterViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authModel:AuthViewModel

    var body: some View {
        
        ZStack{
            Color.black
            ScrollView{
                VStack{
                    
                    Spacer()
                        .frame(height: 125)
                    Text("Register")
                        .foregroundColor(Color.newPrimaryColor)
                        .font(Font.custom("TitilliumWeb-Bold", size: 80))
                    VStack{
                        CustomTextField(
                            promptText: registerVM.textFieldValidationText, placeholder: Text("Enter Your Email").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                            text: $registerVM.email, commit:  {
                                print(registerVM.email)
                            }, imageName: "envelope.open.fill", isSecure: false)
                        
                        CustomTextField(
                            promptText: registerVM.textFieldValidationText, placeholder: Text("Enter Your Username").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                            text: $registerVM.username, commit:  {
                                print(registerVM.username)
                            }, imageName: "person.fill", isSecure: false)
                        CustomTextField(
                            promptText: registerVM.textFieldValidationText, placeholder: Text("Enter Your Password").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                            text: $registerVM.password, commit:  {
                                print(registerVM.username)
                            }, imageName: "lock.fill", isSecure: true)
                        CustomTextField(
                            promptText: registerVM.textFieldValidationText, placeholder: Text("Confirm Your Password").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                            text: $registerVM.confirmedPassword, commit:  {
                                print(registerVM.username)
                            }, imageName: "lock.fill", isSecure: true)
                    }
                    
                  
                    Button(action: {
                                print("Register Tapped")
                        authModel.signUp(email: registerVM.email, password: registerVM.password)
                            }) {
                                Text("Register")
                                    .customButton()
                      
                    }
                    .padding(.top,40)
                    Spacer()
                        .frame(height: 40)
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
                                    print("facebook Tapped")
                                }) {
                            Image("facebook")
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
            .preferredColorScheme(.dark)
            .ignoresSafeArea(.all, edges: .all)
            }
            
       
    }
    
    
}

struct Register_Previews: PreviewProvider {
    static var previews: some View {
        Register()
    }
}




