//
//  ContentView.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 02/09/2021.
//
import SwiftUI


struct ContentView: View {
  @State var isPresented = true
  @State var isRecording = false
  @StateObject var camera = CameraViewModel()
    
    
  var body: some View {
   
        ZStack {
          Image(uiImage: camera.displayImage)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .ignoresSafeArea(.all, edges: .all)
          
          VStack {
            HStack {
              Spacer()
              Button {
                  camera.switchCamera()
              } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                  .font(.system(size: 30))
                  .foregroundColor(.white)
              }
            }
            .padding(30)
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
            .padding(15)
          }
         
        }
        .onAppear {
            camera.setupCamera()
        }
        .sheet(isPresented: $isPresented,content:{
            Login(isPresented: $isPresented)
                .onTapGesture {
                    dismissKeyboard()
                }
        })
  
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
