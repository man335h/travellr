//
//  MaterialImage.swift
//  Travellr
//
//  Created by Manish Gehani on 11/13/16.
//  Copyright © 2016 Manish Gehani. All rights reserved.
//

import Foundation
import UIKit

class MaterialImage: UIImageView {
    
    override func awakeFromNib() {
        
        layer.cornerRadius = frame.size.width / 2
        clipsToBounds = true
        
    }
}