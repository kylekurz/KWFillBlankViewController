//
//  KWInputBar.swift
//  KWFillBlankTextView
//
//  Created by 一折 on 16/7/31.
//  Copyright © 2016年 yizhe. All rights reserved.
//

protocol KWInputBarDelegate {
    func doneBlank()
}

import UIKit

class KWInputBar: UIView {
    
    var inputField:UITextField!
    var doneButton:UIButton!
    var delegate:KWInputBarDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        let textFrame = CGRect(x:10, y:5, width:self.frame.width-20-65, height:self.frame.height-10)
        self.inputField = UITextField(frame: textFrame)
        self.addSubview(inputField)
        let buttonFrame = CGRect(x: textFrame.width+textFrame.origin.x+5, y: textFrame.origin.y, width: 60, height: textFrame.height)
        self.doneButton = UIButton(frame:buttonFrame)
        self.addSubview(doneButton)
        setInputProperty()
        setButtonProperty()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setInputProperty(){
        self.inputField.borderStyle = .roundedRect
        self.inputField.autocapitalizationType = .none
        self.inputField.keyboardType = .asciiCapable
        self.inputField.returnKeyType = .next
        self.inputField.spellCheckingType = .no
        self.inputField.autocorrectionType = .no
    }
    
    func setButtonProperty(){
        self.doneButton.backgroundColor = UIColor(red: 54.0/255.0, green: 105.0/255.0, blue: 195.0/255.0, alpha: 1)
        self.doneButton.layer.masksToBounds = true
        self.doneButton.layer.cornerRadius = 3
        self.doneButton.setTitle("Next", for: UIControlState())
        self.doneButton.addTarget(self, action: #selector(getter: next), for: .touchUpInside)
    }
    
    func next(){
        if self.delegate != nil{
            self.delegate.doneBlank()
        }
    }
}
