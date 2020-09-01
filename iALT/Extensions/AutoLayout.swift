//
//  AutoLayout.swift
//  iALT
//
//  Created by Alec Mather on 8/6/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import UIKit

class AnchoredConstraints {
    var top, bottom, left, right: NSLayoutConstraint?
}

extension UIView {
    
    func center() {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let sv = self.superview {
            
            centerYAnchor.constraint(equalTo: sv.centerYAnchor).isActive = true
            centerXAnchor.constraint(equalTo: sv.centerXAnchor).isActive = true
            
        }
        
    }
    
    func fillSuperview() {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let sv = self.superview {
            
            topAnchor.constraint(equalTo: sv.topAnchor).isActive = true
            leadingAnchor.constraint(equalTo: sv.leadingAnchor).isActive = true
            trailingAnchor.constraint(equalTo: sv.trailingAnchor).isActive = true
            bottomAnchor.constraint(equalTo: sv.bottomAnchor).isActive = true
            
        }
        
    }
    
    func fillSuperview(top: CGFloat, left: CGFloat, right: CGFloat, bottom: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let sv = self.superview {
            
            topAnchor.constraint(equalTo: sv.topAnchor, constant: top).isActive = true
            leadingAnchor.constraint(equalTo: sv.leadingAnchor, constant: left).isActive = true
            trailingAnchor.constraint(equalTo: sv.trailingAnchor, constant: -right).isActive = true
            bottomAnchor.constraint(equalTo: sv.bottomAnchor, constant: -bottom).isActive = true
            
        }
        
    }
    
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, right: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?) -> AnchoredConstraints {
        
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = AnchoredConstraints()
        
        if let top = top {
            constraints.top = topAnchor.constraint(equalTo: top)
        }
        
        if let left = left {
            constraints.left = leadingAnchor.constraint(equalTo: left)
        }
        
        if let right = right {
            constraints.right = trailingAnchor.constraint(equalTo: right)
        }
        
        if let bottom = bottom {
            constraints.bottom = bottomAnchor.constraint(equalTo: bottom)
        }
        
        [constraints.top, constraints.bottom, constraints.left, constraints.right].forEach({ $0?.isActive = true })
        
        return constraints
        
    }
    
    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, right: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, padding: UIEdgeInsets) -> AnchoredConstraints {
        
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = AnchoredConstraints()
        
        if let top = top {
            constraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }
        
        if let left = left {
            constraints.left = leadingAnchor.constraint(equalTo: left, constant: padding.left)
        }
        
        if let right = right {
            constraints.right = trailingAnchor.constraint(equalTo: right, constant: -padding.right)
        }
        
        if let bottom = bottom {
            constraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }
        
        [constraints.top, constraints.left, constraints.right, constraints.bottom].forEach({ $0?.isActive = true })
        
        return constraints
        
    }
    
    func height(height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        heightAnchor.constraint(equalToConstant: height).isActive = true
        
    }
    
    func width(width: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        widthAnchor.constraint(equalToConstant: width).isActive = true
        
    }
    
    func size(width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
        
    }
    
}

