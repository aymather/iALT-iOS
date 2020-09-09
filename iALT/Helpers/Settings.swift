//
//  Settings.swift
//  iALT
//
//  Created by Alec Mather on 8/8/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import UIKit

struct Settings {
    
    let general: General
    let durations: Durations
    let layout: Layout
    
    struct General {
        
        init(buttonMap: [String: String], training: String) {
            self.buttonMap = buttonMap
            if training == "0" {
                self.blocks = 8 // 8 blocks
                self.trials = 60.0 // per block
                self.nov = 1.0/5.0 // ratio of novelty (haptic trials
                self.nogo = 1.0/3.0 // ratio of nogo trials
            } else {
                self.blocks = 1 // 1 blocks
                self.trials = 24.0 // per block
                self.nov = 0 // ratio of novelty (haptic trials
                self.nogo = 1.0/3.0 // ratio of nogo trials
            }
        }
        
        let blocks: Int // 8 blocks
        let trials: Double // per block
        let nov: Double // ratio of novelty (haptic trials
        let nogo: Double // ratio of nogo trials
        var buttonMap: [String: String]
        
    }
    
    struct Durations {
        
        let deadline = 0.5 // amount of time alloted to respond
        let iti = 0.8 // inter-trial interval
        let fixation = 0.5 // duration of fixation cross
        let feedback = 1.0 // duration of the "Too Slow!" feedback on missed responses
        let delay = 0.05
        let cue = 0.2
        let deadline_adjustment = 0.025
        
    }
    
    struct Layout {
        
        let backgroundColor = UIColor.black
        let textColor = UIColor.white
        let feedbackColor = UIColor.red
        
    }
    
    init(data: ParticipantData) {
        
        let buttonMap: [String: String]
        if data.buttons == "0" {
            buttonMap = ["go": "W", "nogo": "M"]
        } else {
            buttonMap = ["go": "M", "nogo": "W"]
        }
        
        self.general = General(buttonMap: buttonMap, training: data.training)
        self.durations = Durations()
        self.layout = Layout()
        
    }
    
}
