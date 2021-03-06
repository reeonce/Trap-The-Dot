//
//  ResultViewController.swift
//  Trap-The-Dot
//
//  Created by Reeonce Zeng on 8/22/15.
//  Copyright © 2015 reeonce. All rights reserved.
//

import UIKit
import FBSDKShareKit

class ResultViewController: UIViewController {
    var result: TTDGameResult?
    
    var titleLabel: UILabel!
    lazy var resultTitleLabel = UILabel()
    lazy var resultDescriptionLabel = UILabel()
    lazy var backgroundImageView = UIImageView()
    lazy var ciContext = CIContext()
    
    @available(iOS 9.0, *)
    lazy var buttonsStackView = UIStackView()
    
    lazy var replayButton = UIButton()
    lazy var onceMoreButton = UIButton()
    lazy var nextButton = UIButton()
    lazy var shareButton = UIButton()
    lazy var commentButton = UIButton()
    lazy var homeButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel = addTTDTitle()
        
        replayButton.setTitle("Replay", forState: .Normal)
        onceMoreButton.setTitle("Once Again", forState: .Normal)
        nextButton.setTitle("Next Level", forState: .Normal)
        shareButton.setTitle("Share", forState: .Normal)
        commentButton.setTitle("Comment Me", forState: .Normal)
        homeButton.setTitle("Home", forState: .Normal)
        
        for button in [replayButton, onceMoreButton, nextButton, shareButton, commentButton, homeButton] {
            button.backgroundColor = Theme.currentTheme.secondaryColor
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 4
        }
        
        if #available(iOS 9, *) {
            buttonsStackView.axis = .Vertical
            buttonsStackView.alignment = .Center
            buttonsStackView.distribution = .Fill
            buttonsStackView.spacing = 20
            buttonsStackView.backgroundColor = UIColor.blueColor()
            
            view.addSubviews([backgroundImageView, resultTitleLabel, resultDescriptionLabel, buttonsStackView])
        } else {
            view.addSubviews([backgroundImageView, resultTitleLabel, resultDescriptionLabel])
        }
        
        backgroundImageView.snp_makeConstraints { (make) -> Void in
            make.leading.trailing.top.bottom.equalTo(view)
        }
        resultTitleLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(titleLabel.snp_bottom).offset(20)
        }
        resultDescriptionLabel.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.top.equalTo(resultTitleLabel.snp_bottom).offset(20)
        }
        if #available(iOS 9, *) {
            buttonsStackView.snp_makeConstraints { (make) -> Void in
                make.leading.trailing.equalTo(self.view)
                make.bottom.lessThanOrEqualTo(self.view).offset(-32)
                make.top.equalTo(resultDescriptionLabel.snp_bottom).offset(40)
            }
        }
        
        replayButton.addTarget(self, action: #selector(ResultViewController.replay(_:)), forControlEvents: .TouchUpInside)
        onceMoreButton.addTarget(self, action: #selector(ResultViewController.onceMore(_:)), forControlEvents: .TouchUpInside)
        nextButton.addTarget(self, action: #selector(ResultViewController.nextLevel(_:)), forControlEvents: .TouchUpInside)
        shareButton.addTarget(self, action: #selector(ResultViewController.share(_:)), forControlEvents: .TouchUpInside)
        commentButton.addTarget(self, action: #selector(ResultViewController.comment(_:)), forControlEvents: .TouchUpInside)
        homeButton.addTarget(self, action: #selector(ResultViewController.gotoHome(_:)), forControlEvents: .TouchUpInside)
        
        showResult()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        releaseResult()
    }
    
    func releaseResult() {
        result = nil
        backgroundImageView.image = nil
    }
    
    func showResult() {
        guard let result = result else {
            return
        }
        resultTitleLabel.text = result.winOrLose.title
        resultDescriptionLabel.text = String(format: result.details, arguments: [result.totalSteps])
        
        if let cgImage = result.screenshot?.CGImage {
            let ciImage = CIImage(CGImage: cgImage)
            if let filter = CIFilter(name: "CIGaussianBlur") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(30.0, forKey: "inputRadius")
                let result = filter.valueForKey(kCIOutputImageKey) as! CIImage
                let bluredCGImage = ciContext.createCGImage(result, fromRect: ciImage.extent)
                backgroundImageView.image = UIImage(CGImage: bluredCGImage)
            } else {
                view.backgroundColor = UIColor.clearColor()
            }
        } else {
            view.backgroundColor = UIColor.clearColor()
        }
        
        if #available(iOS 9, *) {
            buttonsStackView.removeAllArrangedSubviews()
            let level = GameLevel.currentLevel
            
            if level.mode == .Random {
                if result.winOrLose == .Win {
                    buttonsStackView.addArrangedSubviews([ onceMoreButton, shareButton, commentButton, homeButton ])
                } else {
                    buttonsStackView.addArrangedSubviews([ onceMoreButton, commentButton, homeButton ])
                }
            } else {
                if result.winOrLose == .Win {
                    buttonsStackView.addArrangedSubviews([ nextButton, shareButton, commentButton, homeButton ])
                } else {
                    buttonsStackView.addArrangedSubviews([ onceMoreButton, commentButton, homeButton ])
                }
            }
            
            for button in [replayButton, onceMoreButton, nextButton, shareButton, commentButton, homeButton] {
                let count = buttonsStackView.arrangedSubviews.count
                if button.superview == buttonsStackView {
                    button.snp_makeConstraints(closure: { (make) -> Void in
                        make.width.equalTo(buttonsStackView).offset(-120)
                        make.height.equalTo(50).priority(750)
                        make.height.lessThanOrEqualTo(buttonsStackView).multipliedBy( 1.0 / Double(count)).offset(Double(-20 * (count - 1)) / Double(count))
                    })
                }
            }
        }
    }
    
    func replay(sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName("replay", object: nil)
        releaseResult()
    }
    
    func onceMore(sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName("onceMore", object: nil)
        releaseResult()
    }
    
    func nextLevel(sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName("nextLevel", object: nil)
        releaseResult()
    }
    
    func share(sender: AnyObject?) {
        if let image = result?.screenshot {
            let photo = FBSDKSharePhoto(image: image, userGenerated: true)
            let photoContent = FBSDKSharePhotoContent()
            photoContent.photos = [photo]
            FBSDKShareDialog.showFromViewController(self, withContent: photoContent, delegate: nil)
        }
    }
    
    func comment(sender: AnyObject?) {
        let appid = "922876408"
        let rateURL = "itms-apps://itunes.apple.com/app/id\(appid)"
        UIApplication.sharedApplication().openURL(NSURL(string: rateURL)!)
    }
    
    func gotoHome(sender: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName("gotoHome", object: nil)
        releaseResult()
    }
}


extension ResultViewController: FBSDKSharingDelegate {
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        logger.debug("success?")
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        logger.debug("failed.")
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        logger.debug("canceled")
    }
}