//
//  UserCell.swift
//  NanoChallange2
//
//  Created by Hai on 19/09/19.
//  Copyright © 2019 Asep Abdaz. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    
    @IBOutlet weak var userAccountLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var emotionImageView: UIImageView!
    @IBOutlet weak var statusUiView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        statusUiView.layer.cornerRadius = 10
    }
}


