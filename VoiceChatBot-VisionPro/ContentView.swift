//
//  ContentView.swift
//  VoiceChatBot-VisionPro
//
//  Created by Siddanth Raja on 2/24/24.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognitionManager()
    
    var body: some View {
        VStack {
            // Your 3D model or other content here
            Model3D(named: "Scene", bundle: Bundle.main)
                .padding(.bottom, 50)

            // Display the recognized text
            Text(speechRecognizer.recognizedText)
                .padding()
            
            // Start and stop recording buttons
            HStack {
                Button(action: {
                    // Request permissions if needed and start recording
                    self.speechRecognizer.checkPermissions()
                    try? self.speechRecognizer.startRecording()
                }) {
                    Image(systemName: "mic.fill")
                    Text("Start Recording")
                }
                .padding()
                .disabled(speechRecognizer.isRecording)
                
                Button(action: {
                    self.speechRecognizer.stopRecording()
                }) {
                    Image(systemName: "mic.slash.fill")
                    Text("Stop Recording")
                }
                .padding()
                .disabled(!speechRecognizer.isRecording)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
