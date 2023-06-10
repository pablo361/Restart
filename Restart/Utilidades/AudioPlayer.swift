//
//  AudioPlayer.swift
//  Restart
//
//  Created by Pablo Pizarro on 17/06/2023.
//

import Foundation
import AVFoundation

var audioPlayer: AVAudioPlayer?

func playSound(sound: String, type: String){
    if let path = Bundle.main.path(forResource: sound, ofType: type){
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        }catch{
                print("No se puede reproducir")
            }
        }
    }

