//
//  RPCircularProgressTests.swift
//  RPCircularProgressTests
//
//  Created by Rob Phillips on 4/6/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//
//  See LICENSE for full license agreement.
//

import Quick
import Nimble

@testable import RPCircularProgressExample

class RPCircularProgressTests: QuickSpec {
    
    override func spec() {

        let progress = RPCircularProgress()

        describe("properties") { 

            context("colors") {

                // Non-default color
                let color = UIColor.purple

                it("should update track color") {
                    progress.trackTintColor = color
                    expect(progress.trackTintColor) == color
                }

                it("should update progress color") {
                    progress.progressTintColor = color
                    expect(progress.progressTintColor) == color
                }

                it("should have an optional inner area color") {
                    expect(progress.innerTintColor).to(beNil())
                }

                it("should update inner area color") {
                    progress.innerTintColor = color
                    expect(progress.innerTintColor) == color
                }

            }

            context("corners") {

                it("should update rounded") {
                    progress.roundedCorners = false
                    expect(progress.roundedCorners).to(beFalse())

                    progress.roundedCorners = true
                    expect(progress.roundedCorners).to(beTrue())
                }

            }

            context("progress bar") {

                it("should update thickness ratio") {
                    progress.thicknessRatio = 0.42
                    expect(progress.thicknessRatio) == 0.42
                }

                it("should pin thickness ratio") {
                    progress.thicknessRatio = -1
                    expect(progress.thicknessRatio) == 0.01

                    progress.thicknessRatio = 2
                    expect(progress.thicknessRatio) == 1
                }

                it("should update clockwise progress") {
                    progress.clockwiseProgress = false
                    expect(progress.clockwiseProgress).to(beFalse())

                    progress.clockwiseProgress = true
                    expect(progress.clockwiseProgress).to(beTrue())
                }

                it("should have the correct timing function") {
                    let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
                    progress.timingFunction = timingFunction
                    progress.updateProgress(1, duration: 2)

                    let animation = progress.layer.animation(forKey: "progress")
                    expect(animation).toEventuallyNot(beNil())

                    let currentTimingFunction = animation!.value(forKey: "timingFunction") as! CAMediaTimingFunction
                    expect(currentTimingFunction).to(equal(timingFunction))
                }

                it("should return current progress") {
                    progress.updateProgress(0.42, animated: false)
                    expect(progress.progress) == 0.42
                }
                
            }

            context("indeterminate progress bar") {

                it("should update indeterminate progress") {
                    progress.indeterminateProgress = 0.42
                    expect(progress.indeterminateProgress) == 0.42
                }

                it("should pin indeterminate progress") {
                    progress.indeterminateProgress = -1
                    expect(progress.indeterminateProgress) == 0.05

                    progress.indeterminateProgress = 2
                    expect(progress.indeterminateProgress) == 0.9
                }

                it("should update indeterminate duration") {
                    progress.indeterminateDuration = 42
                    expect(progress.indeterminateDuration) == 42
                }

            }

        }

        describe("indeterminate progress") {

            context("enabling or disabling") {

                let key = "indeterminateAnimation"

                it("should enable the animation") {
                    progress.enableIndeterminate()

                    let animation = progress.layer.animation(forKey: key)
                    expect(animation).toEventuallyNot(beNil())
                }

                it("should disable the animation") {
                    progress.enableIndeterminate()
                    var animation = progress.layer.animation(forKey: key)
                    expect(animation).toEventuallyNot(beNil())

                    progress.enableIndeterminate(false)
                    animation = progress.layer.animation(forKey: key)
                    expect(animation).to(beNil())
                }

            }

            context("completion") {

                it("should call the enabling closure upon completion") {
                    waitUntil { done in
                        progress.enableIndeterminate(completion: {
                            expect(true).to(beTrue())
                            done()
                        })
                        progress.enableIndeterminate(false)
                    }
                }

                it("should call the disabling closure upon completion") {
                    progress.enableIndeterminate()
                    waitUntil { done in
                        progress.enableIndeterminate(false, completion: {
                            expect(true).to(beTrue())
                            done()
                        })
                    }
                }
                
            }

        }

        describe("updating progress") {

            let key = "progress"

            context("progress") {

                it("should pin progress") {
                    progress.updateProgress(-1, animated: false)
                    expect(progress.progress) == 0

                    progress.updateProgress(2, animated: false)
                    expect(progress.progress) == 1
                }

                it("should update to the proper amount") {
                    progress.updateProgress(0.42, animated: false)
                    expect(progress.progress).to(beCloseTo(0.42))
                }

            }

            context("animated") {

                it("should add animation if passed as true") {
                    progress.updateProgress(0.42, animated: true)

                    let animation = progress.layer.animation(forKey: key)

                    expect(animation).toEventuallyNot(beNil())
                    expect(progress.progress).toEventually(equal(0.42))
                }

                it("should not add animation if passed as false") {
                    progress.updateProgress(0.42, animated: false)

                    let animation = progress.layer.animation(forKey: key)

                    expect(animation).to(beNil())
                    expect(progress.progress) == 0.42
                }

            }

            context("initialDelay") {

                it("should set the proper value") {
                    let beginTime = Int(CACurrentMediaTime() + 42)
                    progress.updateProgress(0.42, initialDelay: 42)

                    let animation = progress.layer.animation(forKey: key)
                    expect(animation).toEventuallyNot(beNil())

                    let initialDelay = animation?.value(forKey: "beginTime") as? Int
                    expect(initialDelay) == beginTime
                }

            }

            context("duration") {

                it("should set the proper value") {
                    progress.updateProgress(0.42, duration: 42)

                    let animation = progress.layer.animation(forKey: key)
                    expect(animation).toEventuallyNot(beNil())

                    let duration = animation?.value(forKey: "duration") as? Int
                    expect(duration) == 42
                }

            }

            context("completion") {

                it("should call the closure upon completion") {
                    waitUntil { done in
                        progress.updateProgress(0.42, duration: 42, completion: {
                            expect(true).to(beTrue())
                            done()
                        })
                    }
                }

            }

        }

    }

}
