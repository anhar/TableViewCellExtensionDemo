//
//  PortraitImageTableViewCell.swift
//  TableViewCellExtensionDemo
//
//  Created by Andreas Hård on 2018-07-15.
//  Copyright © 2018 Andreas Hård. All rights reserved.
//

import UIKit

class PortraitImageTableViewCell: UITableViewCell, Reusable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var activityContainerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var isLoading: Bool = false {
        didSet {
            activityContainerView.isHidden = !isLoading
            activityIndicator.isHidden = !isLoading
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        activityContainerView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        activityContainerView.layer.cornerRadius = 4.0
        activityIndicator.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        portraitImageView.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:0.6)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.titleLabel.text = nil
        self.portraitImageView.image = nil
    }
    
    func updateCell(with title: String, image: UIImage?) {
        self.titleLabel.text = title
        self.portraitImageView.image = image
    }
    
}
