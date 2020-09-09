//
//  DataVC.swift
//  iALT
//
//  Created by Alec Mather on 8/6/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import UIKit
import ProgressHUD

class DataVC: UIViewController {
    
    // Lock orientation
    override var shouldAutorotate: Bool { return false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .portrait }
    
    class TextField: UITextField {
        let padding = UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15)
        
        override open func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
        override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
        override open func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
    }

    private lazy var nameField: TextField = self.createTextField(placeholder: "Participant Name?")
    private lazy var ageField: TextField = self.createTextField(placeholder: "Age?")
    private lazy var genderField: TextField = self.createTextField(placeholder: "Gender?")
    private lazy var handednessField: TextField = self.createTextField(placeholder: "Left or Right Handed?")
    
    private lazy var saveButton: UIButton = self.createButton(text: "Save", bgColor: .systemGreen)
    
    private lazy var stack: UIStackView = {
       
        let stack = UIStackView(arrangedSubviews: [
            self.nameField,
            self.ageField,
            self.genderField,
            self.handednessField,
            self.saveButton
        ])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.backgroundColor = .green
        stack.spacing = 10
        return stack
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        addTargets()
        setupLayout()
        constraints()
    }
    
    private func addTargets() {
        saveButton.addTarget(self, action: #selector(self.createParticipant), for: .touchUpInside)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    
    private func setupLayout() {
        view.addSubview(stack)
    }
    
    private func constraints() {
        stack.anchor(top: nil, left: view.leadingAnchor, right: view.trailingAnchor, bottom: nil, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        stack.center()
    }
    
    private func markAsInvalid(textField: TextField) {
        textField.layer.borderColor = UIColor.red.cgColor
    }
    
    private func markAsValid(textField: TextField) {
        textField.layer.borderColor = UIColor.green.cgColor
    }
    
    private func isDataValid() -> Bool {
        
        var flag = true
        
        if nameField.text?.isEmpty == true {
            flag = false
            markAsInvalid(textField: nameField)
        } else {
            markAsValid(textField: nameField)
        }
        
        if ageField.text?.isEmpty == true {
            flag = false
            markAsInvalid(textField: ageField)
        } else {
            markAsValid(textField: ageField)
        }
        
        if genderField.text?.isEmpty == true || (genderField.text! != "M" && genderField.text! != "F") {
            flag = false
            markAsInvalid(textField: genderField)
        } else {
            markAsValid(textField: genderField)
        }
        
        if handednessField.text?.isEmpty == true || (handednessField.text! != "R" && handednessField.text! != "L") {
            flag = false
            markAsInvalid(textField: handednessField)
        } else {
            markAsValid(textField: handednessField)
        }
        
        return flag
    }
    
    @objc private func createParticipant() {
        guard isDataValid() else { return }
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.show("Saving")
        let data = collectData()
        NetworkManager.shared.createParticipant(data: data) { (res) in
            switch res {
                case .success(let data):
                    print(data)
                    DispatchQueue.main.async {
                        self.nameField.text = ""
                        self.ageField.text = ""
                        self.genderField.text = ""
                        self.handednessField.text = ""
                        self.nameField.layer.borderColor = UIColor.lightGray.cgColor
                        self.ageField.layer.borderColor = UIColor.lightGray.cgColor
                        self.genderField.layer.borderColor = UIColor.lightGray.cgColor
                        self.handednessField.layer.borderColor = UIColor.lightGray.cgColor
                    }
                    ProgressHUD.showSucceed()
                case .failure(let err):
                    print("Error")
                    print(err.localizedDescription)
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func collectData() -> [String: String] {
        
        let data = [
            "name": nameField.text!,
            "age": ageField.text!,
            "gender": genderField.text!,
            "handedness": handednessField.text!,
            "training": "0",
            "buttons": "0"
        ]
        
        return data
        
    }
    
    private func createTextField(placeholder: String) -> TextField {
        let text = TextField()
        let p = NSAttributedString(string: placeholder, attributes: [ .foregroundColor: UIColor.systemGray ])
        text.attributedPlaceholder = p
        text.backgroundColor = .white
        text.layer.cornerRadius = 12
        text.textColor = .black
        text.autocorrectionType = .no
        text.layer.borderWidth = 1
        text.layer.borderColor = UIColor.lightGray.cgColor
        return text
    }
    
    private func createButton(text: String, bgColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.backgroundColor = bgColor
        return button
    }

}
