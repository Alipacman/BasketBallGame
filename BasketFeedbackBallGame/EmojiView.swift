//
//  EmojiView.swift
//  BasketFeedbackBallGame
//
//  Created by Ali Ebrahimi Pourasad on 01.05.19.
//  Copyright © 2019 Ali Ebrahimi Pourasad. All rights reserved.
//

import UIKit

class EmojiView: UIView {
    
    //MARK:-Properties
    
    let emojis = [ UIImageView(image: "😭".emojiToImage()),
                   UIImageView(image: "😐".emojiToImage()),
                   UIImageView(image: "😍".emojiToImage())
                 ]
    
    let stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        return stackView
    }()
    
    //MARK:-Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        setupStackView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Layout
    private func layout() {
        
        let views: [String: UIView] = ["stackView": stackView]
        
        for (_, view) in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        layoutConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[stackView]-(0)-|",
                                                            options: [], metrics: nil, views: views)
        
        layoutConstraints +=  NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[stackView]-(0)-|",
                                                            options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    //MARK:- SetupStackView
    private func setupStackView() {
        emojis.forEach({
            $0.contentMode = .scaleAspectFit
            stackView.addArrangedSubview($0)
        })
    }
}

extension String {
    func emojiToImage() -> UIImage? {
        let size = CGSize(width: 30, height: 35)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: CGPoint(), size: size)
        UIRectFill(CGRect(origin: CGPoint(), size: size))
        (self as NSString).draw(in: rect, withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
