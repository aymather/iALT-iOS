//
//  ParticipantsVC.swift
//  iALT
//
//  Created by Alec Mather on 9/2/20.
//  Copyright © 2020 Alec Mather. All rights reserved.
//

import UIKit
import ProgressHUD

class ParticipantsVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "Cell"
    var data: [ParticipantData]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = .white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView!.register(ParticipantsCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = .systemBlue
        ProgressHUD.show("Loading...")
        NetworkManager.shared.getParticipants { (res) in
            switch res {
                case .success(let data):
                    self.data = data
                    ProgressHUD.showSucceed()
                case .failure(let err):
                    print(err)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ParticipantsCell
        if let data = self.data {
            cell.data = data[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = data else { return }
        let pVC = ParticipantVC()
        pVC.data = data[indexPath.row]
        navigationController?.pushViewController(pVC, animated: true)
    }

}
