//
//  Matlab.swift
//  iALT
//
//  Created by Alec Mather on 8/8/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

class Matlab {
    
    static func fill(matrix: [[Double]], row: Int, with value: Double) -> [[Double]] {
        let len = matrix[0].count - 1
        if row < 0 || row > len { return matrix }
        
        var m = matrix
        
        for i in 0...len {
            m[(row, i)] = value
        }
        
        return m
    }
    
    static func fill(matrix: [[Double]], column: Int, with value: Double) -> [[Double]] {
        let rows = matrix.count
        if column < 0 || column > matrix[0].count { return matrix }
        
        var m = matrix
        
        for i in 0...(rows - 1) {
            m[(i, column)] = value
        }
        
        return m
    }
    
    static func fill(matrix: [[Double]], column: Int, from row: Int, to end: Int, with value: Double) -> [[Double]] {
        
        if column < 0 || column > matrix[0].count { return matrix }
        var _end = end
        if _end > matrix.count - 1 { _end = matrix.count - 1 }

        var m = matrix
        
        for i in row..._end {
            print(i)
            m[(i, column)] = value
        }

        return m
        
    }
    
    static func zeros(rows: Int, columns: Int) -> [[Double]] {
        var matrix = [[Double]]()
        var row = [Double]()
        for _ in 0...columns - 1 { row.append(0) }
        for _ in 0...rows - 1 { matrix.append(row) }
        return matrix
    }
    
    static func zeros(rows: Int, columns: Int) -> [[UInt64]] {
        var matrix = [[UInt64]]()
        var row = [UInt64]()
        for _ in 0...columns - 1 { row.append(0) }
        for _ in 0...rows - 1 { matrix.append(row) }
        return matrix
    }
    
    static func array1d(columns: Int, with value: Double) -> [Double] {
        var row = [Double]()
        for _ in 0...columns - 1 { row.append(value) }
        return row
    }
    
    static func array2d(rows: Int, columns: Int, with value: Double) -> [[Double]] {
        var matrix = [[Double]]()
        var row = [Double]()
        for _ in 0...columns - 1 { row.append(value) }
        for _ in 0...rows - 1 { matrix.append(row) }
        return matrix
    }
    
    struct Dimensions {
        let rows: Int
        let columns: Int
        init(array2d matrix: [[Double]]) {
            self.rows = matrix.count
            self.columns = matrix[0].count
        }
    }
    
    // Get dimensions on a 2d array (rows, columns)
    static func size(matrix: [[Double]]) -> Dimensions {
        return Dimensions(array2d: matrix)
    }
    
    // Merge a 3d matrix into a 2d matrix
    static func merge(_ matrix: [[[Double]]]) -> [[Double]] {
        
        var m = matrix[0]
        
        if matrix.count == 1 { return m }
        
        // Verify dimensions are consistant
        let dims = Dimensions(array2d: m)
        for sub in matrix {
            let subDims = Dimensions(array2d: sub)
            if dims.columns != subDims.columns {
                print("Invalid dims")
                return m
            }
        }
        
        for mergableIdx in 1...(matrix.count - 1) {
            for row in 0...(matrix[mergableIdx].count - 1) {
                 m.append(matrix[mergableIdx][row])
            }

        }
        
        return m
        
    }
    
    // Get rows from matrix that meet criteria
    static func getRows(matrix: [[Double]], column: Int, is value: Double) -> [[Double]] {
        
        var m = [[Double]]()
        
        for row in matrix {
            if row[column] == value {
                m.append(row)
            }
        }
        
        return m
        
    }
    
    // Just get a single column as an array
    static func getRows(matrix: [[Double]], column: Int) -> [Double] {
        
        var a = [Double]()
        
        for row in matrix {
            a.append(row[column])
        }
        
        return a
        
    }
    
    // Get the mean of an array
    static func mean(array: [Double]) -> Double {
        
        let sum = array.reduce(0, { a, b in
            return a + b
        })
        
        return sum / Double(array.count)
        
    }
    
}
