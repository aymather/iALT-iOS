//
//  ParticipantsCell.swift
//  iALT
//
//  Created by Alec Mather on 9/2/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import UIKit

class ParticipantsCell: UICollectionViewCell {
    
    var data: ParticipantData! {
        didSet {
            DispatchQueue.main.async {
                self.nameLabel.text = self.data.name
            }
        }
    }
    
    private let nameLabel: UILabel = {
       
        let label = UILabel()
        label.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        return label
        
    }()
    
    private let separator: UIView = {
       
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
        return view
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        
        setupViews()
        constraints()
    }
    
    private func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(separator)
    }
    
    private func constraints() {
        separator.anchor(top: nil, left: contentView.leadingAnchor, right: contentView.trailingAnchor, bottom: contentView.bottomAnchor)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        nameLabel.anchor(top: contentView.topAnchor, left: contentView.leadingAnchor, right: contentView.trailingAnchor, bottom: contentView.bottomAnchor, padding: .init(top: 0, left: 30, bottom: 0, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
