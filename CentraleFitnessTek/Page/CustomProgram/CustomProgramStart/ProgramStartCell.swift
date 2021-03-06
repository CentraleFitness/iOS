//
//  PrgramStartCell.swift
//  CentraleFitnessTek
//
//  Created by Fabien Santoni on 19/09/2018.
//  Copyright © 2018 Fabien Santoni. All rights reserved.
//

import UIKit

class ProgramStartCell: UITableViewCell {

    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelStat: UILabel!
    
    var seconds: Int = 0{
        didSet{
            labelTime.text = String(seconds)
        }
    }
    
    var stat: String = ""  {
        didSet{
                labelStat.text = stat
                if (stat == "Fini"){
                labelStat.textColor = .green
                }
                else if (stat == "Plus tard") {
                labelStat.textColor = .red
                }
                else{
                labelStat.textColor = .gray
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
