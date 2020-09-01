//
//  Orientation.swift
//  iALT
//
//  Created by Alec Mather on 8/9/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import UIKit

extension UIViewController {

    func forceLandscape() {
        UIView.setAnimationsEnabled(false)
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        UIView.setAnimationsEnabled(false)
    }
    
    func forcePortrait() {
        UIView.setAnimationsEnabled(false)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIView.setAnimationsEnabled(false)
    }

}
