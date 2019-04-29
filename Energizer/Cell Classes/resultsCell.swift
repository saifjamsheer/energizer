//
//  TableViewCell.swift
//  GetAPI
//
//  Created by Michalis Neophytou on 30/01/2019.
//  Copyright © 2019 Michalis Neophytou. All rights reserved.
//

import UIKit
import Foundation

class resultsCell: UITableViewCell {

    
    let distanceLabel = UILabel()
    let nameLabel = UILabel()
    let connectionNumberLabel = UILabel()
    let pillShape = UIView()
    let compatibilityIndicator = UIView()
    let type2Image = UIImage(named: "Type2")
    let favouritePicture = UIImage.init(named: "heartIcon")?.withRenderingMode(.alwaysTemplate)
    let nonFavouritePicture = UIImage.init(named: "hollowHeartIcon")?.withRenderingMode(.alwaysTemplate)
    let heartView = UIImageView()
    let favouriteButton = faveButton()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: 0, y: 0, width:  self.frame.width, height: 48)
        self.contentView.frame = CGRect(x: 0, y: 0, width:  self.contentView.frame.width, height: 48)
        heartView.image = favouritePicture
        heartView.frame = CGRect(x: self.contentView.frame.width * 0.9, y: self.contentView.frame.height * 0.3, width: self.contentView.frame.width * 0.1, height: self.contentView.frame.height * 0.4)
        heartView.contentMode = .scaleAspectFit
        heartView.tintColor = UIColor(red: 255/255, green: 0/255, blue: 101/255, alpha: 1)
        self.pillShape.frame = CGRect(x: (self.contentView.frame.height * 0.1), y: (self.contentView.frame.height * 0.1), width: (self.contentView.frame.height * 1.6), height: (self.contentView.frame.height * 0.8))
        self.pillShape.layer.cornerRadius = self.pillShape.frame.height/2        
        self.pillShape.layer.backgroundColor = UIColor.init(white: 0.5, alpha: 0.2).cgColor
        self.pillShape.layer.borderWidth = 1
        self.pillShape.layer.borderColor = UIColor.gray.cgColor
        
        self.compatibilityIndicator.frame = CGRect(x: pillShape.frame.minX, y: pillShape.frame.minY, width: pillShape.frame.midX - pillShape.frame.minX, height: pillShape.frame.maxY - pillShape.frame.minY)
        self.compatibilityIndicator.layer.cornerRadius = self.compatibilityIndicator.frame.height/2
        self.compatibilityIndicator.layer.backgroundColor = UIColor.green.cgColor
        
        let imageView = UIImageView(image: type2Image)
        imageView.frame = CGRect(x: pillShape.frame.minX + ((pillShape.frame.midX - pillShape.frame.minX) * 0.05),
                                 y: pillShape.frame.minY + 1 + pillShape.frame.height * 0.05,
                                 width: 0.9 * (pillShape.frame.midX - pillShape.frame.minX),
                                 height: 0.9 * (pillShape.frame.maxY - pillShape.frame.minY))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = imageView.frame.height/2
        
        self.connectionNumberLabel.frame = CGRect(x: pillShape.frame.midX, y: pillShape.frame.minY, width: pillShape.frame.maxX - pillShape.frame.midX, height: pillShape.frame.maxY - pillShape.frame.minY)
        
        self.distanceLabel.frame =  CGRect(x: self.contentView.frame.height * 2, y: pillShape.frame.midY, width: (0.9 * self.contentView.frame.width - (self.contentView.frame.height * 2)), height: (self.pillShape.frame.height/2))
        
        self.nameLabel.frame = CGRect(x: self.contentView.frame.height * 2, y: pillShape.frame.minY, width: (0.9 * self.contentView.frame.width - (self.contentView.frame.height * 2)), height: (self.pillShape.frame.height/2))
        
        
        self.contentView.addSubview(pillShape)
        self.contentView.addSubview(compatibilityIndicator)
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(distanceLabel)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(connectionNumberLabel)
        self.contentView.addSubview(favouriteButton)
        

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
