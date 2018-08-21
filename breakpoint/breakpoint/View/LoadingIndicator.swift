//
//  LoadingIndicator.swift
//  VechicleTracker
//
//  Created by vineeth on 6/14/18.
//  Copyright © 2018 vineeth. All rights reserved.
//

import UIKit

class LoadingIndicator: UIView {

    let activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureViews() {
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        activityIndicator.color = UIColor(red: 143/255, green: 207/255, blue: 78/255, alpha: 1)
        activityIndicator.center  = CGPoint(x: SCREEN_WIDTH/2, y: SCREEN_HEIGHT/2)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.addSubview(activityIndicator)
    }
    
    func startProgressLoading() {
        APP_DELEGATE.window!.addSubview(self)
        activityIndicator.startAnimating()
    }
    
    func stopProgressLoading() {
        self.removeFromSuperview()
        activityIndicator.stopAnimating()
    }

}
