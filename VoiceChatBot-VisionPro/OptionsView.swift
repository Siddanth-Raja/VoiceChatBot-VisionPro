//
//  OptionsView.swift
//  VoiceChatBot-VisionPro
//
//  Created by Siddanth Raja on 3/6/24.
//

import SwiftUI

struct OptionsView: View {
    @Binding var transcribedText: String  // Bind to the transcribed text
    var speechRecognizer: SpeechRecognitionManager
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Transcribed Text")) {
                    Text(transcribedText).padding()
                }

                Section(header: Text("Options")) {
                    Button("Summarize") {
                        speechRecognizer.summarizeText(speechRecognizer.recognizedText)
                    }


                    Button("Translate") {
                        // Implement translation feature
                    }
                }
            }
            .navigationTitle("Text Options")
        }
    }
}


