//
//  Columns.swift
//  iALT
//
//  Created by Alec Mather on 8/8/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

struct Columns {
    
    // Columns
    let trialnum = 0
    let block = 1
    let nov = 2
    let go = 3
    let side = 4
    let resp = 5
    let rt = 6
    let time = 7
    let acc = 8
    let deadline = 9
    
    // Meta
    let total_columns = 10
    var array: [Int] {
        get {
            return [
                self.trialnum,
                self.block,
                self.nov,
                self.go,
                self.side,
                self.resp,
                self.rt,
                self.time,
                self.acc,
                self.deadline
            ]
        }
    }
    
}
