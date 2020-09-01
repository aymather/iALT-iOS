//
//  Trialseq.swift
//  iALT
//
//  Created by Alec Mather on 8/7/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

class Trialseq {
    
    var seq = [[Double]]()
    let data: ParticipantData
    let columns: Columns
    let settings: Settings
    
    init(settings: Settings, columns: Columns, data: ParticipantData) {
        
        self.data = data
        self.columns = columns
        self.settings = settings
        self.seq = self.buildSequence()
        
    }
    
    private func buildSequence() -> [[Double]] {
        
        var sequence = [[Double]]()
        
        for blocknum in 1...settings.general.blocks {
            
            // First get the number of each type of trial
            let go_standard = Int(settings.general.trials * (1 - settings.general.nogo) * (1 - settings.general.nov))
            let nogo_standard = Int(settings.general.trials * settings.general.nogo * (1 - settings.general.nov))
            let go_novelty = Int(settings.general.trials * (1 - settings.general.nogo) * settings.general.nov)
            let nogo_novelty = Int(settings.general.trials * settings.general.nogo * settings.general.nov)
            
            // Create trial chunks
            
            /// Standard go trials
            let go_stan_side1 = Matlab.fill(matrix: Matlab.zeros(rows: go_standard / 2, columns: columns.total_columns), column: columns.side, with: 1)
            let go_stan_side2 = Matlab.fill(matrix: Matlab.zeros(rows: go_standard / 2, columns: columns.total_columns), column: columns.side, with: 2)
            let go_stan = Matlab.fill(matrix: Matlab.merge([go_stan_side1, go_stan_side2]), column: columns.go, with: 1)
            
            /// Standard nogo trials
            let nogo_stan_side1 = Matlab.fill(matrix: Matlab.zeros(rows: nogo_standard / 2, columns: columns.total_columns), column: columns.side, with: 1)
            let nogo_stan_side2 = Matlab.fill(matrix: Matlab.zeros(rows: nogo_standard / 2, columns: columns.total_columns), column: columns.side, with: 2)
            let nogo_stan = Matlab.merge([nogo_stan_side1, nogo_stan_side2])
            
            /// Novelty go trials
            let go_nov_side1 = Matlab.fill(matrix: Matlab.zeros(rows: go_novelty / 2, columns: columns.total_columns), column: columns.side, with: 1)
            let go_nov_side2 = Matlab.fill(matrix: Matlab.zeros(rows: go_novelty / 2, columns: columns.total_columns), column: columns.side, with: 2)
            let go_nov = Matlab.fill(matrix: Matlab.fill(matrix: Matlab.merge([go_nov_side1, go_nov_side2]), column: columns.go, with: 1), column: columns.nov, with: 1)
            
            /// Novelty nogo trials
            let nogo_nov_side1 = Matlab.fill(matrix: Matlab.zeros(rows: nogo_novelty / 2, columns: columns.total_columns), column: columns.side, with: 1)
            let nogo_nov_side2 = Matlab.fill(matrix: Matlab.zeros(rows: nogo_novelty / 2, columns: columns.total_columns), column: columns.side, with: 2)
            let nogo_nov = Matlab.fill(matrix: Matlab.merge([nogo_nov_side1, nogo_nov_side2]), column: columns.nov, with: 1)
            
            var block = Matlab.merge([ go_stan, nogo_stan, go_nov, nogo_nov ]).shuffled()
            
            // Shuffle
            if data.training == "0" {
                block = shuffleForFullExperiment(matrix: block)
            }
            
            // Fill with block number
            block = Matlab.fill(matrix: block, column: columns.block, with: Double(blocknum))
            
            // Merge with master sequence
            if sequence.count == 0 {
                sequence = block // assign directly if we don't have dimensions on sequence yet
            } else {

                sequence = Matlab.merge([ sequence, block ]) // merge with previous sequence
            }
            
        }
        
        /// Assign trial numbers to each trial
        for trialnum in 0...(sequence.count - 1) {
            sequence[(trialnum, columns.trialnum)] = Double(trialnum) + 1.0
            sequence[(trialnum, columns.deadline)] = settings.durations.deadline
        }
        
        return sequence
    }
    
    private func shuffleForFullExperiment(matrix: [[Double]]) -> [[Double]] {
        
        var _matrix = matrix
        while(!isFullExperimentValid(matrix: _matrix)) {
            _matrix.shuffle()
        }
        
        return _matrix
        
    }
    
    private func isFullExperimentValid(matrix: [[Double]]) -> Bool {
        
        if first3TrialsDontContainNovelty(matrix: matrix) && no2NoveltiesInARow(matrix: matrix) {
            return true
        } else {
            return false
        }
        
    }
    
    private func first3TrialsDontContainNovelty(matrix: [[Double]]) -> Bool {
        if matrix[0][columns.nov] != 1 && matrix[1][columns.nov] != 1 && matrix[2][columns.nov] != 1 {
            return true
        } else {
            return false
        }
    }
    
    private func no2NoveltiesInARow(matrix: [[Double]]) -> Bool {
        
        for rowIndex in 0...matrix.count - 1 {
            if (rowIndex + 1 < matrix.count) && matrix[rowIndex][columns.nov] == 1 && matrix[rowIndex + 1][columns.nov] == 1 {
                return true
            }
        }
        
        return false
        
    }
    
    func fillRows(column: Int, from row: Int, to end: Int, with value: Double) {
        
        if column < 0 || column > self.seq[0].count { return }
        var _end = end
        if _end > self.seq.count - 1 { _end = self.seq.count - 1 }
        
        for i in row..._end {
            self.seq[(i, column)] = value
        }
        
    }
    
    func isPast3GoTrialsAccurate(trialnum: Int) -> Bool {
        
        // First get only the trials before or equal to the current trial
        var trials = [[Double]]()
        for i in 0...trialnum {
            trials.append(seq[i])
        }
        
        // First get all the go trials
        trials = Matlab.getRows(matrix: trials, column: columns.go, is: 1)
        
        // Check that there are at least 5 trials
        if trials.count <= 4 {
            return false
        }
        
        // Make sure the past 3 trials that were go trials were accurate
        if trials[(trials.count - 1, columns.acc)] == 1 && trials[(trials.count - 2, columns.acc)] == 1 && trials[(trials.count - 3, columns.acc)] == 1 {
            return true
        } else {
            return false
        }
        
    }
    
    func getBlock(blocknum: Double) -> [[Double]] {
        
        return Matlab.getRows(matrix: seq, column: columns.block, is: blocknum)
        
    }
    
    func printTrialseq() {
        
        print("Trial Sequence: \n")
        
        print("Trial Number: \(columns.trialnum)")
        print("Block Number: \(columns.block)")
        print("Is novelty trial? (0=no, 1=yes): \(columns.nov)")
        print("Is go trial? (1=yes, 0=no): \(columns.go)")
        print("Side? (1=left, 2=right): \(columns.side)")
        print("Response (1=left, 2=right): \(columns.resp)")
        print("Reaction time: \(columns.rt)")
        print("Time: \(columns.time)")
        print("Accuracy: \(columns.acc)")
        print("Deadline: \(columns.deadline)")
        
        print(" | \(columns.trialnum) | \(columns.block) | \(columns.nov) | \(columns.go) | \(columns.side) | \(columns.resp) | \(columns.rt) | \(columns.time) | \(columns.acc) | \(columns.deadline) | ")
        print("---------------------------------------------\n")
        for row in self.seq {
            var str = " | "
            for col in row { str += "\(col) | " }
            print(str)
        }
    }
    
}
