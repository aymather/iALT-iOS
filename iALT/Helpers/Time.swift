//
//  Time.swift
//  iALT
//
//  Created by Alec Mather on 8/28/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import Foundation

class Time {
    
    var m = [[UInt64]]()
    
    // By trial measurements
    let starttime = 0
    let starttime2FixationDispatch = 1
    let starttime2FixationDispatchFinished = 2
    let stimDisplayDispatch = 3
    let stimDisplayDispatchFinished = 4
    let noveltyOnset = 5
    let noveltyOnsetFinished = 6
    let stimDisplayEndDispatch = 7
    let stimDisplayEndDispatchFinished = 8
    let feedbackDispatch = 9
    let feedbackDispatchFinished = 10
    let feedbackDispatchEnd = 11
    let feedbackDispatchEndFinished = 12
    let endtime = 13
    
    // Block measurements
    let blockstart = 14
    let blockend = 15
    
    // Overall experiment measurements
    var expStart: UInt64?
    var expEnd: UInt64?
    
    let totalColumns = 16
    
    init(trials: Int) {
        self.m = self.buildMatrix(trials: trials)
    }
    
    private func buildMatrix(trials: Int) -> [[UInt64]] {
        
        return Matlab.zeros(rows: trials, columns: self.totalColumns)
        
    }
    
}
