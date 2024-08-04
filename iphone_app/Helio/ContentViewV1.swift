//
//  ContentView.swift
//  Visuo
//
//  Created by Michelle Rueda on 7/18/24.
//

import SwiftUI

// New SwiftUI wrapper
struct BodyMovementDetectorView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> BodyMovementDetectorViewController {
        return BodyMovementDetectorViewController()
    }
    
    func updateUIViewController(_ uiViewController: BodyMovementDetectorViewController, context: Context) {
        // Update the view controller if needed
    }
}

//// Main app structure
//@main
//struct BodyMovementApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

struct ContentViewV1: View {
  @State private var isRecording = false
//      @State private var videoCaptureViewController: VideoCaptureViewController?
  @State private var viewControllerRepresentable = VideoCaptureView()
  
//  @State var coordinator: VideoCaptureView.Coordinator?

      var body: some View {
          ZStack {
            viewControllerRepresentable
                            .frame(width: 300, height: 300)
//              viewControllerRepresentable
//                  .onAppear {
//                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        if let viewControllerRepresentable = self.extractViewControllerRepresentable() {
//                                                self.coordinator = viewControllerRepresentable.makeCoordinator()
//                                            }
//                        coordinator = viewControllerRepresentable.makeCoordinator()
//                        print("yo")
//                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//                            if let window = windowScene.windows.first {
//                              if let controller = window.rootViewController as? VideoCaptureViewController {
//                                    self.videoCaptureViewController = controller
//                                }
//                            }
//                        }
//
//                      }
                  }

              VStack {
                  Spacer()
                  HStack {
                      Button(action: {
                          if isRecording {
//                            viewControllerRepresentable.coordinator?.someMethod()

//                              videoCaptureViewController?.stopRecording()
                          } else {
//                            coordinator?.callMyViewControllerMethod()
                            viewControllerRepresentable.viewController?.startRecording()

//                              videoCaptureViewController?.startRecording()
                          }
                          isRecording.toggle()
                      }) {
                          Text(isRecording ? "Stop Recording" : "Start Recording")
                              .padding()
                              .background(Color.red)
                              .foregroundColor(.white)
                              .cornerRadius(10)
                      }
                  }
                  .padding()
              }
          }
      }
  
  private func extractViewControllerRepresentable() -> VideoCaptureView? {
          let view = UIHostingController(rootView: VideoCaptureView()).view
          let mirror = Mirror(reflecting: view)
          for child in mirror.children {
              if let representable = child.value as? VideoCaptureView {
                  return representable
              }
          }
          return nil
      }
//    var body: some View {
//      ZStack {
//                  BodyMovementDetectorView()
//                      .edgesIgnoringSafeArea(.all)
//                  
//                  VStack {
//                      Spacer()
//                      
//                      HStack {
//                          Spacer()
//                          
//                          Button(action: {
//                              // Button action here
//                          }) {
//                              Text("Start Recording")
//                                  .padding()
//                                  .background(Color.blue)
//                                  .foregroundColor(.white)
//                                  .cornerRadius(8)
//                          }
//                          
//                          Spacer()
//                      }
//                      .padding()
//                      .background(Color.gray.opacity(0.8))
//                  }
//              }
//
//    }

// Preview provider for SwiftUI canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
