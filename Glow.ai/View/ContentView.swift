//
//  ContentView.swift
//  Glow.ai
//
//  Created by Miske Elvilaly on 02/09/2021.
//
import SwiftUI
import FirebaseAuth
import Combine
struct CameraView: View {
  @State var isPresented = false
  @State var isRecording = false
  @State var previousDragGesturePoint:CGPoint?
  @State var isDark:Bool = true
  @StateObject var camera = CameraViewModel()
  @EnvironmentObject var sessionService: SessionService
  @EnvironmentObject var recording: Recording
  var sessionStatePublisher: AnyPublisher<SessionState, Never>?
  var body: some View {
   
        ZStack {
          Image(uiImage: camera.displayImage)
              .resizable()
              .aspectRatio(contentMode: .fill)
              .ignoresSafeArea(.all, edges: .all)
              .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged({ (value) in
                    if (self.previousDragGesturePoint != nil ) {
                        if (self.previousDragGesturePoint!.y > value.location.y) && (camera.alpha <= 1 ){
                            camera.alpha += 0.02
                        }
                        if (self.previousDragGesturePoint!.y < value.location.y) && (camera.alpha >= 0 ){
                            camera.alpha -= 0.02
        
                        }
                    }
                    self.previousDragGesturePoint = value.location
                }))
          VStack {
           
            if sessionService.user?.displayName == nil {
                Text( sessionService.userDetails.username != "" ?  "Hello, " + sessionService.userDetails.username.uppercased() + "." : "")
                    .foregroundColor(Color.newPrimaryColor)
                    .font(Font.custom("TitilliumWeb-Bold", size: 24))
            }
            if  (sessionService.user != nil) && (sessionService.user!.displayName != nil) {
                Text( "Hello, " + sessionService.user!.displayName!.uppercased() + "." )
                    .foregroundColor(Color.newPrimaryColor)
                    .font(Font.custom("TitilliumWeb-Bold", size: 24))
            }else if (sessionService.user != nil) && (sessionService.user!.displayName == nil) && (sessionService.user!.email != nil) {
                Text( "Hello, " + sessionService.user!.email!.uppercased() + "." )
                    .foregroundColor(Color.newPrimaryColor)
                    .font(Font.custom("TitilliumWeb-Bold", size: 24))
            }
            
            
          
           
            HStack {
              Spacer()
              Toggle(LocalizedStringKey("Dark Mode"), isOn: $isDark)
                .toggleStyle(SwitchToggleStyle(tint: Color.red))
                .foregroundColor(Color.newPrimaryColor)
                .font(Font.custom("TitilliumWeb-Light", size: 20))
                .frame(width: 150, height: 20)
                .onChange(of: isDark) { value in
                    if isDark {
                        self.camera.alpha = 0
                    }else {
                        self.camera.alpha = 1
                    }
                }
              Button {
                  camera.switchCamera()
              } label: {
                Image(systemName: "arrow.triangle.2.circlepath.camera")
                  .font(.system(size: 30))
                  .foregroundColor(.white)
              }
                if sessionService.state != .loggedOut {
                    Button {
                        sessionService.logout {
                            sessionService.userDetails = SessionUserDetails(email: "", username: "")
                           
                        }
                        sessionService.logoutFromGoogle()
                        
                    } label: {
                        Image(systemName: "power")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    }
                }else {
                    Button {
                            self.isPresented = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                    }
                }
                
                
                
            }
            .padding(15)
            
        
            
                
            Spacer()
            HStack {
              Spacer()
              Button {

                if (recording.numberOfRecordings <= 3) || (sessionService.state == .loggedIn) {
                    recording.numberOfRecordings += 1
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
                }else {
                    self.isPresented = true
                }
                
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
            sessionService.setupFirebaseHandler {
            }
            print(self.isPresented)
        
        }
        .navigationBarHidden(true)

        .sheet(isPresented: $isPresented,content:{
                LoginView()
                    .environmentObject(sessionService)
                    .onTapGesture {
                        dismissKeyboard()
                    }
 
        })
        .onReceive(sessionService.$state) { (_) in
            if sessionService.state == .loggedIn || sessionService.user != nil {
                self.isPresented = false
            }
            else  {
                print("Entered here")
                self.isPresented = true
            }
        }
        
        
    }
}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        CameraView()
//    }
//}
