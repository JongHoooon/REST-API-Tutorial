//
//  TodoCell.swift
//  TodoAppTutorial
//
//  Created by JongHoon on 2023/01/15.
//

import UIKit

class TodoCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var selectionSwitch: UISwitch!
    override class func awakeFromNib() {
        super.awakeFromNib()
        
        print("DEBUG -", #fileID, #function, #line)
    }
    
    @IBAction func onEditBtnClicked(_ sender: UIButton) {
        print("DEBUG -", #fileID, #function, #line)
    }
    
    @IBAction func onDeleteBtnClicked(_ sender: UIButton) {
        print("DEBUG -", #fileID, #function, #line)
    }
}
