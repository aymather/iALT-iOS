//
//  TestVC.swift
//  iALT
//
//  Created by Alec Mather on 9/6/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import UIKit

class TestVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Is it?: \(UIDevice.isHapticsSupported)")
    }

}

extension UIDevice {

    static var isHapticsSupported : Bool {
        let feedback = UIImpactFeedbackGenerator(style: .heavy)
        feedback.prepare()
        return feedback.description.hasSuffix("Heavy>")
    }
}
