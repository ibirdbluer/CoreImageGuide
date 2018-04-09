//
//  DetailDescriptionCell.swift
//  CoreImageGuide
//
//  Created by Gregory Qian on 29/03/2018.
//  Copyright © 2018 Gregory Qian. All rights reserved.
//

import UIKit

class DetailDescriptionCell: UITableViewCell {
    @IBOutlet weak var theTitleLabel: UILabel!
    @IBOutlet weak var theDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
