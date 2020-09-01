//
//  UpdateParticipant.swift
//  iALT
//
//  Created by Alec Mather on 8/31/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import Foundation

class UpdateParticipant: Codable {
    
    let participant: ParticipantData
    let sequence: [[Double]]
    
    init(participant: ParticipantData, sequence: [[Double]]) {
        
        self.participant = participant
        self.sequence = sequence
        
    }
    
}
