//
//  KWFillBlankViewController.swift
//  KWFillBlankTextView
//
//  Created by 一折 on 16/7/31.
//  Copyright © 2016年 yizhe. All rights reserved.
//

public protocol KWFillBlankDelegate {
    func fillBlankView(_ fillBlankView:UIView, didSelectedBlankRange range:NSRange)->Void
}

import UIKit

class KWFillBlankViewController: UIViewController,UITextViewDelegate,UITextFieldDelegate,KWInputBarDelegate {

    var textView:KWFillBlankTextView!
    var inputBar:KWInputBar!
    var delegate:KWFillBlankDelegate!
    fileprivate var selectedRange:NSRange!
    
    var showInputBar:Bool! = true{
        willSet{
            self.showInputAction()
        }
    }
    
    init(contentText:String, withTextViewFrame frame:CGRect=CGRect.zero, blankTag:String="_"){
        super.init(nibName: nil, bundle: nil)
        var textViewFrame:CGRect = frame
        if frame == CGRect.zero {
            textViewFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height-44)
        }
        self.textView = KWFillBlankTextView(contentText: contentText,frame: textViewFrame,blankTag: "_")
        self.view.addSubview(self.textView)
        self.textView.delegate = self

        
        let inputFrame = CGRect(x: 0, y: self.view.frame.height-44, width: self.view.frame.width, height: 44)
        self.inputBar = KWInputBar(frame: inputFrame)
        self.showInputBar = true
        self.inputBar.inputField.delegate = self
        self.inputBar.delegate = self
        showInputAction()
        
        self.listenToKeyboard()
        let tap = UITapGestureRecognizer(target: self, action: #selector(KWFillBlankViewController.keyBoardResign))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(KWFillBlankViewController.keyBoardResign))
        swipe.direction = .down
        self.textView.addGestureRecognizer(tap)
        self.textView.addGestureRecognizer(swipe)
    }
    
    fileprivate func showInputAction(){
        if showInputBar == true {
            self.view.addSubview(self.inputBar)
        }
        else{
            self.inputBar.removeFromSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.absoluteString == "blank" {
            self.inputBar.inputField.becomeFirstResponder()
            self.selectedRange = characterRange
            self.textView.highlightTextInRange(characterRange)
            self.textView.updateRange(characterRange)
            self.inputBar.inputField.text = self.textView.selectedText()
            if self.delegate != nil {
                self.delegate.fillBlankView(self.view, didSelectedBlankRange: characterRange)
            }
            return false
        }
        return true
    }
    
    func keyBoardResign(){
        self.inputBar.inputField.resignFirstResponder()
    }
    
    func listenToKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(KWFillBlankViewController.changeInputBarPosition(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    func changeInputBarPosition(_ notif:Notification){
        let userinfo = notif.userInfo
        var start = (userinfo![UIKeyboardFrameBeginUserInfoKey] as AnyObject).description
        var end = (userinfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).description
        if ((start?.hasPrefix("NSRect")) != nil) {
            start = start?.replacingOccurrences(of: "NSRect", with: "CGRect")
        }
        if ((end?.hasPrefix("NSRect")) != nil) {
            end = end?.replacingOccurrences(of: "NSRect", with: "CGRect")
        }
        let startRect = CGRectFromString(start!)
        let endRect = CGRectFromString(end!)
        let changeY = startRect.origin.y - endRect.origin.y
        
        var frame = self.inputBar.frame
        frame.origin.y = frame.origin.y - changeY
        UIView.animate(withDuration: 0.25, animations: {
            self.inputBar.frame = frame
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.doneBlank()
        return true
    }
    
    func doneBlank() {
        if selectedRange == nil {
            return
        }
        let text = self.inputBar.inputField.text
        if text == nil {
            return
        }
        if text?.length != 0 {
            let _ = self.textView.changeText(self.inputBar.inputField.text!, inRange: self.selectedRange)
        }
        else{
            self.textView.updateRange(self.selectedRange)
        }
        selectedRange = self.textView.selectedBlankRange()
        self.textView.highlightTextInRange(selectedRange)
        self.inputBar.inputField.text = self.textView.nextText()
    }
    
}
