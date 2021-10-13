//
//  ContentView.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 02/09/2021.
//
import SwiftUI


struct CameraView: View {
  @State var isPresented = true
  @State var isRecording = false
  @StateObject var camera = CameraViewModel()
  @EnvironmentObject var sessionService: SessionService
    
  var body: some View {
   
        ZStack {
          Image(uiImage: camera.displayImage)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .ignoresSafeArea(.all, edges: .all)
          
          VStack {
            Text( "Hello, " + sessionService.userDetails.username + ".")
                .foregroundColor(Color.newPrimaryColor)
                .font(Font.custom("TitilliumWeb-Bold", size: 24))
            HStack {
              Spacer()
              Button {
                  camera.switchCamera()
              } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                  .font(.system(size: 30))
                  .foregroundColor(.white)
              }
                
                Button {
                    sessionService.logout()
                    print(sessionService.state)
                } label: {
                    Image(systemName: "power")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    
                    
                }
                
            }
            .padding(15)
            Spacer()
            HStack {
              Spacer()
              Button {
                if !isRecording {
                    camera.videoWriterViewModel.start()
                } else {
                  camera.videoWriterViewModel.stop { (success) in
                              if success == true {
                                camera.videoWriterViewModel = VideoWriterViewModel()
                              }
                          }
                }
                isRecording.toggle()
              } label: {
                Image(systemName: "record.circle")
                  .font(.system(size: 70))
                  .foregroundColor(isRecording ? Color.red : Color.white)
              }
              Spacer()
            }
            
        
          }
          .padding(20)
         
         
        }
        .onAppear {
            camera.setupCamera()
        }
        .navigationBarHidden(true)
        
//        .sheet(isPresented: $isPresented,content:{
//            LoginView()
//                .onTapGesture {
//                    dismissKeyboard()
//                }
//        })
  
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
