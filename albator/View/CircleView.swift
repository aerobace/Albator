//
//  CircleView.swift
//  albator
//
//  Created by Vincent Pacquet on 1/8/18.
//  Copyright © 2018 aerobace. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
    }

}
