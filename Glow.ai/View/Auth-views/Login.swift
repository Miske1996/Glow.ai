//
//  Login.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 10/09/2021.
//


import SwiftUI

struct Login: View {
    @StateObject var registerVM = RegisterViewModel()
    @Binding var isPresented: Bool
    @EnvironmentObject var authModel:AuthViewModel
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
                                promptText: registerVM.textFieldValidationText, placeholder: Text("Enter Your Email").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                                text: $registerVM.email, imageName: "envelope.open.fill", isSecure: false)
                            
                            
                            CustomTextField(
                                promptText: registerVM.textFieldValidationText, placeholder: Text("Enter Your Password").foregroundColor(Color.gray).font(.custom("TitilliumWeb-ExtraLight", size: 16)),
                                text: $registerVM.password, imageName: "lock.fill", isSecure: true)
                            
                        }
                        
                      
                        Button(action: {
                                    print("Login Tapped")
                            authModel.signIn(email: registerVM.email, password: registerVM.password)
//                            guard !email.isEmpty , !password.isEmpty else {
//                                return
//                            }
                            
                                    isPresented.toggle()
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
                        Button(action:{
                            print("go to register page tapped")
                            
                        }) {
                            NavigationLink(destination: Register().navigationBarHidden(true)) {
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
                .preferredColorScheme(.dark)
                .ignoresSafeArea(.all, edges: .all)
                }
            
                
        }
     
       
    }
    
    
}

//struct Login_Previews: PreviewProvider {
//    static var previews: some View {
//        Login()
//    }
//}


