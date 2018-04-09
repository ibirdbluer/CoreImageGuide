//
//  OutputImageView.swift
//  CoreImageGuide
//
//  Created by Gregory Qian on 27/03/2018.
//  Copyright © 2018 Gregory Qian. All rights reserved.
//

import UIKit

class OutputImageView: UIView {

    var image: UIImage?
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        image?.draw(in: rect)
    }
    

}
