//
//  DCAnimationKit.swift
//  DCAnimationKit
//
//  Created by Raman Yankouski on 21.2.19.
//

import UIKit

extension UIView {
    typealias DCAnimationFinished = () -> Void
    static let DEFAULT_DURATION: TimeInterval = 0.25

    enum DCAnimationDirection {
        case top
        case bottom
        case left
        case right
    }
    
    private static var _dc_animatorHolder = [String:UIDynamicAnimator]()
    
    var dc_animator:UIDynamicAnimator? {
    return self.superview?.dc_supAnimator
    }
    
    var dc_supAnimator:UIDynamicAnimator {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            if let animator = UIView._dc_animatorHolder[tmpAddress] {
                return animator
            } else {
                let animator = UIDynamicAnimator.init(referenceView: self)
                UIView._dc_animatorHolder[tmpAddress] = animator
                return animator
            }
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
            UIView._dc_animatorHolder[tmpAddress] = newValue
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////
    private func dc_degreesToRadians(_ degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat.pi / 180
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func setDirection(_ direction:DCAnimationDirection) {
        //these need to be more accurate
        var frame = self.frame
        if let window = self.window {
            switch direction {
            case .bottom:
                frame.origin.y = window.frame.size.height
            case .top:
                frame.origin.y = -window.frame.size.height
            case .left:
                frame.origin.x = -window.frame.size.width
            case .right:
                var offset = window.frame.size.width
                if let scrollView = self.superview as? UIScrollView {
                    offset = scrollView.contentSize.width;
                }
                frame.origin.x = offset;
            }
            self.frame = frame
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func vector(_ direction:DCAnimationDirection) -> CGVector {
        switch direction {
        case .bottom:
            return CGVector(dx: 0, dy: -1)
        case .top:
            return CGVector(dx: 0, dy: 1)
        case .left:
            return CGVector(dx: 1, dy: 0)
        case .right:
            return CGVector(dx: -1, dy: 0)
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    // MARK: general movements
    //////////////////////////////////////////////////////////////////////////////////////
    func setX(_ x: CGFloat, duration:TimeInterval = DEFAULT_DURATION, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            var frame = self.frame
            frame.origin.x = x
            self.frame = frame
        }) { (done) in
            if done {
                finished?()
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func moveX(_ x: CGFloat, duration:TimeInterval = DEFAULT_DURATION, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        self.setX(self.frame.origin.x+x, duration: duration, options: options, finished:finished)
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func setY(_ y: CGFloat, duration:TimeInterval = DEFAULT_DURATION, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            var frame = self.frame
            frame.origin.y = y
            self.frame = frame
        }) { (done) in
            if done {
                finished?()
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func moveY(_ y: CGFloat, duration:TimeInterval = DEFAULT_DURATION, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        self.setY(self.frame.origin.y+y, duration: duration, options: options, finished:finished)
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func setPoint(_ point: CGPoint, duration:TimeInterval = DEFAULT_DURATION, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            var frame = self.frame
            frame.origin = point
            self.frame = frame
        }) { (done) in
            if done {
                finished?()
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func movePoint(_ point: CGPoint, duration:TimeInterval = DEFAULT_DURATION, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        self.setPoint(CGPoint(x: self.frame.origin.x+point.x, y: self.frame.origin.y+point.y), duration: duration, options: options, finished:finished)
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func setRotation(_ r: CGFloat, duration:TimeInterval = DEFAULT_DURATION, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.transform = CGAffineTransform(rotationAngle: self.dc_degreesToRadians(r))
        }) { (done) in
            if done {
                finished?()
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func moveRotation(_ r: CGFloat, duration:TimeInterval = DEFAULT_DURATION, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.transform = self.transform.rotated(by: self.dc_degreesToRadians(r))
        }) { (done) in
            if done {
                finished?()
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    // MARK: attention grabbers
    //////////////////////////////////////////////////////////////////////////////////////
    func bounce(height:CGFloat = 10, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        if let animator = self.dc_animator {
            animator.removeAllBehaviors()
        }
        self.moveY(-height, duration:0.25, options:options, finished:{
            self.moveY(height, duration:0.15, options:options, finished:{
                self.moveY(-(height/2), duration:0.15, options:options, finished:{
                    self.moveY(height/2, duration:0.05, options:options, finished:{
                        finished?()
                    })
                })
            })
        })
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func pulse(options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, options: options, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (done) in
            UIView.animate(withDuration: 0.5, delay: 0.1, options: options, animations: {
                self.transform = CGAffineTransform.identity
            }) { (done) in
                if done {
                    finished?()
                }
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func shake(dist:CGFloat = 10, duration: TimeInterval = 0.15, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        self.moveX(-dist, duration:duration, options:options, finished:{
            self.moveX(dist*2, duration:duration, options:options, finished:{
                self.moveX(-(dist*2), duration:duration, options:options, finished:{
                    self.moveX(dist, duration:duration, options:options, finished:{
                        finished?()
                    })
                })
            })
        })
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func swing(dist:CGFloat = 15, duration: TimeInterval = 0.2, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        self.setRotation(dist, duration:duration, options:options, finished:{
            self.setRotation(-dist, duration:duration, options:options, finished:{
                self.setRotation(dist/2, duration:duration, options:options, finished:{
                    self.setRotation(-dist/2, duration:duration, options:options, finished:{
                        self.setRotation(0, duration:duration, options:options, finished:{
                            finished?()
                        })
                    })
                })
            })
        })
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func tada(dist:CGFloat = 3, duration: TimeInterval = 0.12, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            let transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.transform = transform.rotated(by: self.dc_degreesToRadians(dist))
        }) { (done) in
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                let transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.transform = transform.rotated(by: self.dc_degreesToRadians(-dist))
            }) { (done) in
                self.moveRotation(dist*2, duration:duration, options:options, finished:{
                    self.moveRotation(-dist*2, duration:duration, options:options, finished:{
                        self.moveRotation(dist*2, duration:duration, options:options, finished:{
                            self.moveRotation(-dist*2, duration:duration, options:options, finished:{
                                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                                    self.transform = CGAffineTransform.identity
                                }, completion: { (done) in
                                    if done {
                                        finished?()
                                    }
                                })
                            })
                        })
                    })
                })
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    // MARK: intros
    //////////////////////////////////////////////////////////////////////////////////////
    func removeCurrentAnimations() {
        self.dc_animator?.removeAllBehaviors()
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func snapIntoView(_ view: UIView, direction: DCAnimationDirection) {
        if self.superview != view {
            removeFromSuperview()
        }
        view.addSubview(self)
        
        let animator = self.dc_animator
        if animator?.isRunning == false {
            animator?.removeAllBehaviors()
        }
        
        let behaviour = UISnapBehavior(item: self, snapTo: self.center)
        self.setDirection(direction)
        behaviour.damping = 0.75
        animator?.addBehavior(behaviour)
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func bounceIntoView(_ view: UIView, direction: DCAnimationDirection) {
        if self.superview != view {
            removeFromSuperview()
        }
        view.addSubview(self)
        
        let animator = self.dc_animator
        if animator?.isRunning == false {
            animator?.removeAllBehaviors()
        }
        let behaviour = UIAttachmentBehavior(item: self, attachedToAnchor: self.center)
        self.setDirection(direction)
        behaviour.length = 0;
        behaviour.damping = 0.55;
        behaviour.frequency = 1.0;
        animator?.addBehavior(behaviour)
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func expandIntoView(_ view: UIView, duration: TimeInterval = 0.3, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        if self.superview != view {
            removeFromSuperview()
        }
        view.addSubview(self)
        self.transform = CGAffineTransform(scaleX: 0, y: 0)
        self.isHidden = false
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.transform = CGAffineTransform.identity
        }) { (done) in
            finished?()
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    // MARK: outros
    //////////////////////////////////////////////////////////////////////////////////////
    func compressIntoView(_ view: UIView, duration: TimeInterval = 0.3, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.transform = CGAffineTransform(scaleX: 0, y: 0)
        }) { (done) in
            self.isHidden = true
            finished?()
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func hinge(duration: TimeInterval = 0.5, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        self.dc_animator?.removeAllBehaviors()
        let point = self.frame.origin
        self.layer.anchorPoint = CGPoint.zero
        self.center = point
        
        self.setRotation(80, duration: duration, options: options) { [weak self] in
            self?.setRotation(70, duration: duration, options: options) {
                self?.setRotation(80, duration: duration, options: options) {
                    self?.setRotation(70, duration: duration, options: options) {
                        self?.moveY(self?.window?.frame.size.height ?? 0, duration: duration, finished: {
                            self?.removeFromSuperview()
                            finished?()
                            self?.setRotation(0, duration: 0, options: options, finished: nil)
                        })
                    }
                }
            }
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    func drop(duration: TimeInterval = 0.5, options:AnimationOptions = [], finished: DCAnimationFinished? = nil) {
        self.dc_animator?.removeAllBehaviors()
        
        let gravityBehaviour = UIGravityBehavior(items: [self])
        gravityBehaviour.gravityDirection = CGVector.init(dx: 0, dy: 10)
        self.dc_animator?.addBehavior(gravityBehaviour)
        
        let itemBehaviour = UIDynamicItemBehavior.init(items: [self])
        itemBehaviour.addAngularVelocity(-CGFloat.pi/2, for: self)
        self.dc_animator?.addBehavior(itemBehaviour)

        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.alpha = 0
        }) { (done) in
            self.removeFromSuperview()
            finished?()
        }
    }
    //////////////////////////////////////////////////////////////////////////////////////

}
