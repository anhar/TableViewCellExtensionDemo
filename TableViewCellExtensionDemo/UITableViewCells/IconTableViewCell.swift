//
//  XibTableViewCell.swift
//  TableViewCellExtensionDemo
//
//  Created by Andreas Hård on 2018-07-13.
//  Copyright © 2018 Andreas Hård. All rights reserved.
//

import UIKit

class IconTableViewCell: UITableViewCell, Reusable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        titleImageView.image = nil
    }

    func updateCell(with cellViewModel: LocalImageCellCapable) {
        titleLabel.text = cellViewModel.title
        titleImageView.image = cellViewModel.image
    }
    
}
