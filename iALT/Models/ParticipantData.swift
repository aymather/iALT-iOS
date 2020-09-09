//
//  ParticipantData.swift
//  iALT
//
//  Created by Alec Mather on 8/7/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

class ParticipantData: Codable {
    
    let name: String
    let id: String
    let age: String
    let gender: String
    let handedness: String
    let buttons: String
    var training: String
    
    init(data: [String: String]) {
        
        name = data["name"]!
        id = data["id"]!
        age = data["age"]!
        gender = data["gender"]!
        handedness = data["handedness"]!
        buttons = "0"
        training = "0"
        
    }
    
    init() {
        
        name = "Alec Mather"
        id = "001"
        age = "23"
        gender = "m"
        handedness = "r"
        buttons = "1"
        training = "0"
        
    }
    
}
