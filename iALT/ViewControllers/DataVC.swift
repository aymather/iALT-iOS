//
//  DataVC.swift
//  iALT
//
//  Created by Alec Mather on 8/6/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import UIKit

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
    
    private lazy var startExpButton: UIButton = self.createButton(text: "Full Experiment", bgColor: .systemGreen)
    private lazy var startTrainingButton: UIButton = self.createButton(text: "Training", bgColor: .systemRed)
    
    private lazy var stack: UIStackView = {
       
        let stack = UIStackView(arrangedSubviews: [
            self.nameField,
            self.ageField,
            self.genderField,
            self.handednessField,
            self.startExpButton,
            self.startTrainingButton
        ])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.backgroundColor = .green
        stack.spacing = 10
        return stack
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        addTargets()
        setupLayout()
        constraints()
    }
    
    private func addTargets() {
        startExpButton.addTarget(self, action: #selector(startExperiment), for: .touchUpInside)
        startTrainingButton.addTarget(self, action: #selector(startTraining), for: .touchUpInside)
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
    
    private func presentTask(data: ParticipantData) {
        let settings = Settings(data: data)
        let columns = Columns()
        let trialseq = Trialseq(settings: settings, columns: columns, data: data)
        let taskVC = TaskVC(data: ParticipantData(), settings: settings, columns: columns, trialseq: trialseq)
        taskVC.modalPresentationStyle = .fullScreen
        self.present(taskVC, animated: true)
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
    
    @objc private func startExperiment() {
        print("Starting experiment")
        guard isDataValid() else { return }
        let data = collectData(training: 0)
        NetworkManager.shared.createParticipant(data: data) { (res) in
            switch res {
                case .success(let data):
                    print("Success!")
                    print(data)
                    NetworkManager.shared.updateParticipant(participant: data, sequence: [[4, 4, 2], [9, 9, 8]]) { (res) in
                        switch res {
                            case .success(let p):
                                print("Another success!")
                                print(p)
                            case .failure(let err):
                                print("Another error :(")
                                print(err.localizedDescription)
                        }
                }
                case .failure(let err):
                    print("Error!")
                    print(err)
            }
        }
//        presentTask(data: data)
        
    }
    
    @objc private func startTraining() {
        print("Starting training")
        guard isDataValid() else { return }
        let data = collectData(training: 1)
        let p = ParticipantData(data: data)
        presentTask(data: p)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func collectData(training: Int) -> [String: String] {
        
        let data = [
            "name": nameField.text!,
            "age": ageField.text!,
            "gender": genderField.text!,
            "handedness": handednessField.text!,
            "training": "\(training)",
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
        text.layer.borderWidth = 2
        text.layer.borderColor = UIColor.clear.cgColor
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
