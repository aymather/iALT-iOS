//
//  ParticipantVC.swift
//  iALT
//
//  Created by Alec Mather on 9/2/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import UIKit

class ParticipantVC: UIViewController {
    
    var data: ParticipantData!
    
    private lazy var infoLabel: UILabel = {
       
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        
        guard let data = self.data else { return label }
        
        let attrText = NSMutableAttributedString()
        attrText.append(NSAttributedString(string: "Id: \(data.id)", attributes: attributes))
        attrText.append(NSAttributedString(string: "\nName: \(data.name)", attributes: attributes))
        attrText.append(NSAttributedString(string: "\nAge: \(data.age)", attributes: attributes))
        attrText.append(NSAttributedString(string: "\nGender: \(data.gender)", attributes: attributes))
        attrText.append(NSAttributedString(string: "\nHandedness: \(data.handedness)", attributes: attributes))
        
        label.attributedText = attrText
        return label
        
    }()
    
    private lazy var expButton: UIButton = self.createButton(text: "Start Experiment", bgColor: .systemGreen)
    private lazy var trainingButton: UIButton = self.createButton(text: "Start Training", bgColor: .systemPink)
    
    private lazy var stackView: UIStackView = {
       
        let stackView = UIStackView(arrangedSubviews: [
            self.infoLabel,
            self.expButton,
            self.trainingButton
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        addTargets()
        addSubviews()
        constraints()
    }
    
    private func addSubviews() {
        view.addSubview(self.stackView)
    }
    
    private func constraints() {
        stackView.anchor(top: nil, left: view.leadingAnchor, right: view.trailingAnchor, bottom: nil, padding: .init(top: 0, left: 40, bottom: 0, right: 40))
        stackView.center()
    }
    
    private func addTargets() {
        expButton.addTarget(self, action: #selector(self._handleStartExp), for: .touchUpInside)
        trainingButton.addTarget(self, action: #selector(self._handleStartTraining), for: .touchUpInside)
    }
    
    @objc private func _handleStartExp() {
        print("Starting Experiment")
        self.data.training = "0"
        self.presentTask(data: self.data)
    }
    
    @objc private func _handleStartTraining() {
        print("Starting Training")
        self.data.training = "1"
        self.presentTask(data: self.data)
    }
    
    private func presentTask(data: ParticipantData) {
        let settings = Settings(data: data)
        let columns = Columns()
        let trialseq = Trialseq(settings: settings, columns: columns, data: data)
        let taskVC = TaskVC(data: data, settings: settings, columns: columns, trialseq: trialseq)
        taskVC.modalPresentationStyle = .fullScreen
        self.present(taskVC, animated: true)
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
