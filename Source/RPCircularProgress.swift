//
//  RPCircularProgress.swift
//  RPCircularProgress
//
//  Created by Rob Phillips on 4/5/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//
//  See LICENSE for full license agreement.
//

import UIKit

public class RPCircularProgress: UIView {

    // MARK: - Completion

    public typealias CompletionBlock = () -> Void

    // MARK: - Public API

    /**
      The color of the empty progress track (gets drawn over)
    */
    @IBInspectable public var trackTintColor: UIColor {
        get {
            return progressLayer.trackTintColor
        }
        set {
            progressLayer.trackTintColor = newValue
            progressLayer.setNeedsDisplay()
        }
    }

    /**
      The color of the progress bar
     */
    @IBInspectable public var progressTintColor: UIColor {
        get {
            return progressLayer.progressTintColor
        }
        set {
            progressLayer.progressTintColor = newValue
            progressLayer.setNeedsDisplay()
        }
    }

    /**
      The color the notched out circle within the progress area (if there is one)
     */
    @IBInspectable public var innerTintColor: UIColor? {
        get {
            return progressLayer.innerTintColor
        }
        set {
            progressLayer.innerTintColor = newValue
            progressLayer.setNeedsDisplay()
        }
    }

    /**
      Sets whether or not the corners of the progress bar should be rounded
     */
    @IBInspectable public var roundedCorners: Bool {
        get {
            return progressLayer.roundedCorners
        }
        set {
            progressLayer.roundedCorners = newValue
            progressLayer.setNeedsDisplay()
        }
    }

    /**
      Sets how thick the progress bar should be (pinned between `0.01` and `1`)
     */
    @IBInspectable public var thicknessRatio: CGFloat {
        get {
            return progressLayer.thicknessRatio
        }
        set {
            progressLayer.thicknessRatio = pin(newValue, minValue: 0.01, maxValue: 1)
            progressLayer.setNeedsDisplay()
        }
    }

    /**
      Sets whether or not the animation should be clockwise
     */
    @IBInspectable public var clockwiseProgress: Bool {
        get {
            return progressLayer.clockwiseProgress
        }
        set {
            progressLayer.clockwiseProgress = newValue
            progressLayer.setNeedsDisplay()
        }
    }

    /**
      Getter for the current progress (not observed from any active animations)
     */
    @IBInspectable public var progress: CGFloat {
        get {
            return progressLayer.progress
        }
    }

    /**
      Sets how much of the progress bar should be filled during an indeterminate animation, pinned between `0.05` and `0.9`
     
      **Note:** This can be overriden / animated from by using updateProgress(...)
     */
    @IBInspectable public var indeterminateProgress: CGFloat {
        get {
            return progressLayer.indeterminateProgress
        }
        set {
            progressLayer.indeterminateProgress = pin(newValue, minValue: 0.05, maxValue: 0.9)
        }
    }

    /**
      Controls the speed at which the indeterminate progress bar animates
     */
    @IBInspectable public var indeterminateDuration: CFTimeInterval = Defaults.indeterminateDuration

    // MARK: - Custom Base Layer

    private var progressLayer: ProgressLayer! {
        get {
            return layer as! ProgressLayer
        }
    }

    public override class func layerClass() -> AnyClass {
        return ProgressLayer.self
    }

    // Lifecycle

    /**
     Default initializer for the class

     - returns: A configured instance of self
     */
    required public init() {
        super.init(frame: CGRectMake(0, 0, 40, 40))

        setupDefaults()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupDefaults()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()

        if let window = window {
            progressLayer.contentsScale = window.screen.scale
            progressLayer.setNeedsDisplay()
        }
    }

    // MARK: - Indeterminate

    /**
     Enables or disables the indeterminate (spinning) animation

     - parameter enabled:    Whether or not to enable the animation (defaults to `true`)
     - parameter completion: An optional closure to execute after the animation completes
     */
    public func enableIndeterminate(enabled: Bool = true, completion: CompletionBlock? = nil) {
        if let animation = progressLayer.animationForKey(AnimationKeys.indeterminate) {
            // Check if there are any closures to execute on the existing animation
            if let block = animation.valueForKey(AnimationKeys.completionBlock) as? CompletionBlockObject {
                block.action()
            }
            progressLayer.removeAnimationForKey(AnimationKeys.indeterminate)

            // And notify of disabling completion
            completion?()
        }

        guard enabled else { return }

        addIndeterminateAnimation(completion)
    }

    // MARK: - Progress

    /**
     Updates the progress bar to the given value with the optional properties

     - parameter progress:     The progress to update to, pinned between `0` and `1`
     - parameter animated:     Whether or not the update should be animated (defaults to `true`)
     - parameter initialDelay: Sets an initial delay before the animation begins
     - parameter duration:     Sets the overal duration that the animation should complete within
     - parameter completion:   An optional closure to execute after the animation completes
     */
    public func updateProgress(progress: CGFloat, animated: Bool = true, initialDelay: CFTimeInterval = 0, duration: CFTimeInterval? = nil, completion: CompletionBlock? = nil) {
        let pinnedProgress = pin(progress)
        if animated {

            // Get duration
            let animationDuration: CFTimeInterval
            if let duration = duration where duration != 0 {
                animationDuration = duration
            } else {
                // Same duration as UIProgressView animation
                animationDuration = CFTimeInterval(fabsf(Float(self.progress) - Float(pinnedProgress)))
            }

            // Get current progress (to avoid jumpy behavior)
            // Basic animations have their value reset to the original once the animation is finished
            // since only the presentation layer is animating
            var currentProgress: CGFloat = 0
            if let presentationLayer = progressLayer.presentationLayer() as? ProgressLayer {
                currentProgress = presentationLayer.progress
            }
            progressLayer.progress = currentProgress

            progressLayer.removeAnimationForKey(AnimationKeys.progress)
            animate(progress, currentProgress: currentProgress, initialDelay: initialDelay, duration: animationDuration, completion: completion)
        } else {
            progressLayer.removeAnimationForKey(AnimationKeys.progress)

            progressLayer.progress = pinnedProgress
            progressLayer.setNeedsDisplay()

            completion?()
        }
    }
}

// MARK: - Private API

private extension RPCircularProgress {

    // MARK: - Defaults

    func setupDefaults() {
        progressLayer.trackTintColor = Defaults.trackTintColor
        progressLayer.progressTintColor = Defaults.progressTintColor
        progressLayer.innerTintColor = nil
        backgroundColor = Defaults.backgroundColor
        progressLayer.thicknessRatio = Defaults.thicknessRatio
        progressLayer.roundedCorners = Defaults.roundedCorners
        progressLayer.clockwiseProgress = Defaults.clockwiseProgress
        indeterminateDuration = Defaults.indeterminateDuration
        progressLayer.indeterminateProgress = Defaults.indeterminateProgress
    }

    // MARK: - Progress

    // Pin certain values between 0.0 and 1.0
    func pin(value: CGFloat, minValue: CGFloat = 0, maxValue: CGFloat = 1) -> CGFloat {
        return min(max(value, minValue), maxValue)
    }

    func animate(pinnedProgress: CGFloat, currentProgress: CGFloat, initialDelay: CFTimeInterval, duration: CFTimeInterval, completion: CompletionBlock?) {
        let animation = CABasicAnimation(keyPath: AnimationKeys.progress)
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = currentProgress
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.toValue = pinnedProgress
        animation.beginTime = CACurrentMediaTime() + initialDelay
        animation.delegate = self
        if let completion = completion {
            let completionObject = CompletionBlockObject(action: completion)
            animation.setValue(completionObject, forKey: AnimationKeys.completionBlock)
        }
        progressLayer.addAnimation(animation, forKey: AnimationKeys.progress)
    }

    // MARK: - Indeterminate 

    func addIndeterminateAnimation(completion: CompletionBlock?) {
        guard progressLayer.animationForKey(AnimationKeys.indeterminate) == nil else { return }

        let animation = CABasicAnimation(keyPath: AnimationKeys.transformRotation)
        animation.byValue = clockwiseProgress ? 2 * M_PI : -2 * M_PI
        animation.duration = indeterminateDuration
        animation.repeatCount = Float.infinity
        animation.removedOnCompletion = false
        progressLayer.progress = indeterminateProgress
        if let completion = completion {
            let completionObject = CompletionBlockObject(action: completion)
            animation.setValue(completionObject, forKey: AnimationKeys.completionBlock)
        }
        progressLayer.addAnimation(animation, forKey: AnimationKeys.indeterminate)
    }

    // Completion

    class CompletionBlockObject: NSObject {
        var action: CompletionBlock

        required init(action: CompletionBlock) {
            self.action = action
        }
    }

    // MARK: - Private Classes / Structs

    class ProgressLayer: CALayer {
        @NSManaged var trackTintColor: UIColor
        @NSManaged var progressTintColor: UIColor
        @NSManaged var innerTintColor: UIColor?

        @NSManaged var roundedCorners: Bool
        @NSManaged var clockwiseProgress: Bool
        @NSManaged var thicknessRatio: CGFloat

        @NSManaged var indeterminateProgress: CGFloat
        // This needs to have a setter/getter for it to work with CoreAnimation
        @NSManaged var progress: CGFloat

        override class func needsDisplayForKey(key: String) -> Bool {
            return key == AnimationKeys.progress ? true : super.needsDisplayForKey(key)
        }

        override func drawInContext(ctx: CGContext) {
            let rect = bounds
            let centerPoint = CGPointMake(rect.size.width / 2, rect.size.height / 2)
            let radius = min(rect.size.height, rect.size.width) / 2

            let progress: CGFloat = min(self.progress, CGFloat(1 - FLT_EPSILON))
            var radians: CGFloat = 0
            if clockwiseProgress {
                radians = CGFloat((Double(progress) * 2 * M_PI) - M_PI_2)
            } else {
                radians = CGFloat(3 * M_PI_2 - (Double(progress) * 2 * M_PI))
            }

            func fillTrack() {
                CGContextSetFillColorWithColor(ctx, trackTintColor.CGColor)
                let trackPath: CGMutablePathRef = CGPathCreateMutable()
                CGPathMoveToPoint(trackPath, nil, centerPoint.x, centerPoint.y)
                CGPathAddArc(trackPath, nil, centerPoint.x, centerPoint.y, radius, CGFloat(2 * M_PI), 0, true)
                CGPathCloseSubpath(trackPath)
                CGContextAddPath(ctx, trackPath)
                CGContextFillPath(ctx)
            }

            func fillProgressIfNecessary() {
                if progress == 0.0 {
                    return
                }

                func fillProgress() {
                    CGContextSetFillColorWithColor(ctx, progressTintColor.CGColor)
                    let progressPath: CGMutablePathRef = CGPathCreateMutable()
                    CGPathMoveToPoint(progressPath, nil, centerPoint.x, centerPoint.y)
                    CGPathAddArc(progressPath, nil, centerPoint.x, centerPoint.y, radius, CGFloat(3 * M_PI_2), radians, !clockwiseProgress)
                    CGPathCloseSubpath(progressPath)
                    CGContextAddPath(ctx, progressPath)
                    CGContextFillPath(ctx)
                }

                func roundCornersIfNecessary() {
                    if !roundedCorners {
                        return
                    }

                    let pathWidth = radius * thicknessRatio
                    let xOffset = radius * (1 + ((1 - (thicknessRatio / 2)) * CGFloat(cosf(Float(radians)))))
                    let yOffset = radius * (1 + ((1 - (thicknessRatio / 2)) * CGFloat(sinf(Float(radians)))))
                    let endpoint = CGPointMake(xOffset, yOffset)

                    let startEllipseRect = CGRectMake(centerPoint.x - pathWidth / 2, 0, pathWidth, pathWidth)
                    CGContextAddEllipseInRect(ctx, startEllipseRect)
                    CGContextFillPath(ctx)

                    let endEllipseRect = CGRectMake(endpoint.x - pathWidth / 2, endpoint.y - pathWidth / 2, pathWidth, pathWidth)
                    CGContextAddEllipseInRect(ctx, endEllipseRect)
                    CGContextFillPath(ctx)
                }

                fillProgress()
                roundCornersIfNecessary()
            }

            func notchCenterCircle() {
                CGContextSetBlendMode(ctx, .Clear)
                let innerRadius = radius * (1 - thicknessRatio)
                let clearRect = CGRectMake(centerPoint.x - innerRadius, centerPoint.y - innerRadius, innerRadius * 2, innerRadius * 2)
                CGContextAddEllipseInRect(ctx, clearRect)
                CGContextFillPath(ctx)

                func fillInnerTintIfNecessary() {
                    if let innerTintColor = innerTintColor {
                        CGContextSetBlendMode(ctx, .Normal)
                        CGContextSetFillColorWithColor(ctx, innerTintColor.CGColor)
                        CGContextAddEllipseInRect(ctx, clearRect)
                        CGContextFillPath(ctx)
                    }
                }

                fillInnerTintIfNecessary()
            }

            fillTrack()
            fillProgressIfNecessary()
            notchCenterCircle()
        }
    }

    struct Defaults {
        static let trackTintColor = UIColor(white: 1.0, alpha: 0.3)
        static let progressTintColor = UIColor.whiteColor()
        static let backgroundColor = UIColor.clearColor()

        static let progress: CGFloat = 0
        static let thicknessRatio: CGFloat = 0.3
        static let roundedCorners = true
        static let clockwiseProgress = true
        static let indeterminateDuration: CFTimeInterval = 1.0
        static let indeterminateProgress: CGFloat = 0.3
    }

    struct AnimationKeys {
        static let indeterminate = "indeterminateAnimation"
        static let progress = "progress"
        static let transformRotation = "transform.rotation"
        static let completionBlock = "completionBlock"
        static let toValue = "toValue"
    }

}

// MARK: - Animation Delegate

extension RPCircularProgress {

    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        let completedValue = anim.valueForKey(AnimationKeys.toValue)
        if let completedValue = completedValue as? CGFloat {
            progressLayer.progress = completedValue
        }

        if let block = anim.valueForKey(AnimationKeys.completionBlock) as? CompletionBlockObject {
            block.action()
        }
    }

}

