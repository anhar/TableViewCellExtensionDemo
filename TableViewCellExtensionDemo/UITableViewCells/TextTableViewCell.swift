//
//  TextTableViewCell.swift
//  TableViewCellExtensionDemo
//
//  Created by Andreas Hård on 2018-07-13.
//  Copyright © 2018 Andreas Hård. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell, Reusable {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.textLabel?.text = nil
    }
    
    func updateCell(with cellViewModel: CellCapable) {
        self.textLabel?.text = cellViewModel.title
    }
    
}
