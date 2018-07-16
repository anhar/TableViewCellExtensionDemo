//
//  SectionHeaderView.swift
//  TableViewCellExtensionDemo
//
//  Created by Andreas Hård on 2018-07-14.
//  Copyright © 2018 Andreas Hård. All rights reserved.
//

import UIKit

class SectionHeaderView: UITableViewHeaderFooterView, Reusable {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func prepareForReuse() {
        titleLabel.text = nil
    }
    
    func updateView(title: String) {
        titleLabel.text = title.uppercased()
    }

}
