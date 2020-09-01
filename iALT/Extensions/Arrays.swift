//
//  Arrays.swift
//  iALT
//
//  Created by Alec Mather on 8/8/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

extension MutableCollection where Self.Element: MutableCollection {
    subscript(_ indexTuple: (row: Self.Index, column: Self.Element.Index)) -> Self.Element.Element {
        get {
            return self[indexTuple.row][indexTuple.column]
        }
        set {
            self[indexTuple.row][indexTuple.column] = newValue
        }
    }
}
