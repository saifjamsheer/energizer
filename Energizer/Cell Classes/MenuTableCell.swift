//
//  SimpleTableCell.swift
//  UBottomSheet
//
//  Created by ugur on 9.09.2018.
//  Copyright © 2018 otw. All rights reserved.
//

import UIKit
import Foundation

class MenuTableCell: UITableViewCell {

    var iconView = UIImageView()
    let menuTitleLabel = UILabel()
    let iconBackground = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: 0, y: 0, width:  self.frame.width, height: 70)
        self.contentView.frame = CGRect(x: 0, y: 0, width:  self.contentView.frame.width, height: 70)
        self.backgroundColor = UIColor.clear
        
        self.iconView.layer.cornerRadius = iconView.frame.height/2
        
        self.iconView.clipsToBounds = true

        self.iconView.frame = CGRect(x: self.contentView.frame.height*0.35, y: self.contentView.frame.height*0.25, width: self.contentView.frame.height*0.5, height: self.contentView.frame.height*0.5)
        self.iconView.layer.cornerRadius = self.iconView.frame.height/2
        
        self.iconBackground.frame = CGRect(x: self.contentView.frame.height*0.28, y: self.contentView.frame.height*0.18, width: self.contentView.frame.height*0.64, height: self.contentView.frame.height*0.64)
        self.iconBackground.layer.cornerRadius = self.iconBackground.frame.height/2
        self.iconBackground.clipsToBounds = true

        // center of icon is 0.35 + 0.25 from left = 0.6 of height
        //center of background is 0.26 + 0.32 = 0.6 of height


        self.menuTitleLabel.frame = CGRect(x: (1.2 * self.frame.height), y: (self.contentView.frame.height * 0.25), width: (self.contentView.frame.width - (1.2 * self.frame.height)), height: (self.contentView.frame.height * 0.5))
        self.contentView.addSubview(iconBackground)
        self.contentView.addSubview(menuTitleLabel)
        self.contentView.addSubview(iconView)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
