//
//  KWFillBlankTextView.swift
//  KWFillBlankTextView
//
//  Created by 一折 on 16/7/30.
//  Copyright © 2016年 yizhe. All rights reserved.
//


import UIKit

public class KWFillBlankTextView: UITextView {
    /**
     The blank character in the text, the default value is "_".
     
     It's no use to change this property after the initialize.
     */
    @IBInspectable var blankTag:String = "_"
    /**
     The text to display on the view.
     */
    fileprivate var contentText:NSMutableAttributedString!
    
    fileprivate var blankDic = NSMutableDictionary()
    fileprivate var blankArr = NSMutableArray()
    fileprivate var uniqueId:String!
    var selectedBlank:Int = 0
    
    /**
     Creates a KWFillBlankTextView with the specified blank tag and content string.
     
     An initialized KWFillBlankTextView.
     
     - parameter frame: The frame rectangle of the KWFillBlankTextView.
     - parameter contentText: The text to display on the view, the defualt value is "".
     - parameter blankTag: The blank character in the text, the defualt value is '_'.

     - returns: An initialized text view.
     */
    public init(contentText:String,frame:CGRect,blankTag:String="_"){
        super.init(frame:frame,textContainer:nil)
        initialize(contentText: contentText, blankTag: blankTag, uniqueId: "blank")
    }

    public func initialize(contentText:String,blankTag:String="_",uniqueId:String="blank"){
        self.text = contentText
        self.blankTag = blankTag
        self.uniqueId = uniqueId
        self.isSelectable = true
        self.isEditable = false
        self.delaysContentTouches = false
        self.isScrollEnabled = false
        self.contentText = NSMutableAttributedString(string: self.text)
        setDefaultProperty()
        setBlank()
    }
    
    convenience public init(contentText:String,frame:CGRect){
        self.init(contentText:contentText,frame:frame,blankTag: "_")
    }
    
    override public func awakeFromNib() {
        self.contentText = NSMutableAttributedString(string: self.text)
        setDefaultProperty()
        setBlank()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    fileprivate func setDefaultProperty(){
        self.isEditable = false
        self.isSelectable = true
    }
    fileprivate func setBlank(){
        let textRange = NSMakeRange(0, self.contentText.length)
        let pattern = "\(blankTag)+"
        let expression = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
        let arr = expression.matches(in: self.text, options: .reportProgress, range: textRange)
        for res in arr {
            let range = res.range
            self.blankArr.add(range)
            self.blankDic.setObject(self.blankArr.count-1, forKey: "\(range.location)" as NSCopying)
            contentText.addAttribute(NSAttributedStringKey.link, value: uniqueId, range: range)
            contentText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.KWBlue, range: range)
        }
        contentText.addAttribute(NSAttributedStringKey.font, value: UIFont.preferredFont(forTextStyle: .body), range: textRange)
        if #available(iOS 13.0, *) {
            contentText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.label, range: textRange)
        }
        self.attributedText = contentText
    }
    
    func updateRange(_ range:NSRange){
        self.selectedBlank = self.blankDic["\(range.location)"] as! Int
    }
    
    public func nextBlank(after range:NSRange) -> NSRange? {
        for i in 0...self.blankArr.count-1 {
            if let r = self.blankArr[i] as? NSRange, NSEqualRanges(r, range), i < self.blankArr.count-1 {
                return self.blankArr[i+1] as? NSRange
            }
        }
        return nil
    }
    
    public func changeText(_ text:String ,inRange range:NSRange) -> NSRange {
        self.contentText.removeAttribute(NSAttributedStringKey.underlineStyle, range: range)
        updateRange(range)
        self.contentText.replaceCharacters(in: range, with: text)
        let newRange = NSMakeRange(range.location, text.length)
        if text != blankTag {
            self.contentText.addAttribute(NSAttributedStringKey.underlineStyle, value: 1, range: newRange)
        }
        self.attributedText = self.contentText
        updateBlanks()
        return newRange
    }
    
    func updateBlanks(){
        self.blankDic.removeAllObjects()
        self.blankArr.removeAllObjects()
        self.contentText.enumerateAttribute(NSAttributedStringKey.link, in: NSMakeRange(0, self.contentText.length), options: .longestEffectiveRangeNotRequired, using: {
            value, range, stop in
            if value != nil && value as? String == uniqueId {
                self.blankArr.add(range)
                self.blankDic.setObject(self.blankArr.count-1, forKey: "\(range.location)" as NSCopying)
            }
        })
    }
    
    func highlightTextInRange(_ range:NSRange){
        self.contentText.removeAttribute(NSAttributedStringKey.backgroundColor, range: NSMakeRange(0, self.contentText.length))
        self.contentText.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.groupTableViewBackground, range: range)
        self.attributedText = self.contentText
    }
    
    func contentTexts() -> [String]{
        var arr:[String] = []
        self.contentText.enumerateAttribute(NSAttributedStringKey.link, in: NSMakeRange(0, self.contentText.length), options: .longestEffectiveRangeNotRequired, using: {
            value, range, stop in
            if value != nil && value as? String == uniqueId {
                var str = self.contentText.attributedSubstring(from: range).string
                if str.hasPrefix(self.blankTag){
                    str = ""
                }
                arr.append(str)
            }
        })
        return arr
    }
    
    func selectedBlankRange() -> NSRange {
        if self.blankArr.count > 0 {
            return self.blankArr[(selectedBlank+1)%self.blankArr.count] as! NSRange
        }
        return NSMakeRange(0, 0)
    }
    
    func selectedText() -> String{
        let range = self.blankArr[selectedBlank] as! NSRange
        var str = self.contentText.attributedSubstring(from: range).string
        if str.hasPrefix(self.blankTag) {
            str = ""
        }
        return str
    }
    
    func nextText() -> String{
        let range = self.blankArr[(selectedBlank+1)%self.blankArr.count] as! NSRange
        var str = self.contentText.attributedSubstring(from: range).string
        if str.hasPrefix(self.blankTag) {
            str = ""
        }
        return str
    }
    
}


