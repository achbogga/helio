//
//  ContentView.swift
//  Helio
//
//  Created by Michelle Rueda on 7/20/24.
//
import SwiftUI


struct ContentView: View {
    @State private var isRecording = false
    
    var body: some View {
        VStack {
            CameraView(isRecording: $isRecording)
            
            Button(action: {
                isRecording.toggle()
            }) {
                Text(isRecording ? "Stop Recording" : "Start Recording")
            }
        }
    }
}
