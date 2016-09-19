//
//  ViewController.swift
//  RPCircularProgressExample
//
//  Created by Rob Phillips on 4/5/16.
//  Copyright © 2016 Glazed Donut, LLC. All rights reserved.
//
//  See LICENSE for full license agreement.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    // MARK: - Lifecycle

    let container = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    // MARK: - Indeterminate Progress Examples

    lazy fileprivate var thinIndeterminate: RPCircularProgress = {
        let progress = RPCircularProgress()
        progress.thicknessRatio = 0.1
        return progress
    }()

    lazy fileprivate var thinFilledIndeterminate: RPCircularProgress = {
        let progress = RPCircularProgress()
        progress.innerTintColor = UIColor.red
        progress.thicknessRatio = 0.2
        progress.indeterminateDuration = 0.5
        return progress
    }()

    lazy fileprivate var unroundedIndeterminate: RPCircularProgress = {
        let progress = RPCircularProgress()
        progress.roundedCorners = false
        progress.thicknessRatio = 0.6
        progress.clockwiseProgress = false
        return progress
    }()

    lazy fileprivate var chartIndeterminate: RPCircularProgress = {
        let progress = RPCircularProgress()
        progress.roundedCorners = false
        progress.thicknessRatio = 1
        return progress
    }()

    // MARK: - Progress Examples

    lazy fileprivate var thinProgress: RPCircularProgress = {
        let progress = RPCircularProgress()
        progress.thicknessRatio = 0.2
        return progress
    }()

    lazy fileprivate var thinFilledProgress: RPCircularProgress = {
        let progress = RPCircularProgress()
        progress.trackTintColor = UIColor.init(red: 74 / 255, green: 144 / 255, blue: 226 / 255, alpha: 0.3)
        progress.progressTintColor = UIColor.init(red: 74 / 255, green: 144 / 255, blue: 226 / 255, alpha: 1)
        progress.thicknessRatio = 0.5
        return progress
    }()

    lazy fileprivate var unroundedProgress: RPCircularProgress = {
        let progress = RPCircularProgress()
        progress.roundedCorners = false
        progress.thicknessRatio = 0.3
        return progress
    }()

    lazy fileprivate var chartProgress: RPCircularProgress = {
        let progress = RPCircularProgress()
        progress.roundedCorners = false
        progress.thicknessRatio = 1
        return progress
    }()

}

private extension ViewController {

    // MARK: - Constrain Views

    func setupView() {
        setupContainer()

        setupThinIndeterminate()
        setupThinFilledIndeterminate()
        setupUnroundedIndeterminate()
        setupChartIndeterminate()

        setupThinProgress()
        setupThinFilledProgress()
        setupUnroundedProgress()
        setupChartProgress()
    }

    func setupContainer() {
        view.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(view).multipliedBy(0.8)
            make.height.equalTo(view).multipliedBy(0.4)
        }
    }

    func setupThinIndeterminate() {
        constrain(thinIndeterminate)

        thinIndeterminate.enableIndeterminate()
    }

    func setupThinFilledIndeterminate() {
        constrain(thinFilledIndeterminate, leftView: thinIndeterminate)

        thinFilledIndeterminate.enableIndeterminate()
    }

    func setupUnroundedIndeterminate() {
        constrain(unroundedIndeterminate, leftView: thinFilledIndeterminate)

        unroundedIndeterminate.enableIndeterminate()
    }

    func setupChartIndeterminate() {
        constrain(chartIndeterminate, leftView: unroundedIndeterminate)

        chartIndeterminate.enableIndeterminate()
    }

    func setupThinProgress() {
        constrain(thinProgress, topView: thinIndeterminate)

        // You can update progress while being indeterminate if you'd like
        thinProgress.updateProgress(0.4, duration: 5)
        thinProgress.enableIndeterminate()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.thinProgress.updateProgress(1, completion: {
                self.thinProgress.enableIndeterminate(false)
            })
        }
    }

    func setupThinFilledProgress() {
        constrain(thinFilledProgress, leftView: thinProgress)

        thinFilledProgress.updateProgress(0.4, initialDelay: 0.4, duration: 3)
    }

    func setupUnroundedProgress() {
        constrain(unroundedProgress, leftView: thinFilledProgress)

        unroundedProgress.updateProgress(0.4, initialDelay: 0.6, duration: 4)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            self.unroundedProgress.updateProgress(0.9)
        }
    }

    func setupChartProgress() {
        constrain(chartProgress, leftView: unroundedProgress)

        chartProgress.updateProgress(0.3, animated: false, initialDelay: 1)
    }

    // MARK: - Setup Helpers

    func constrain(_ newView: UIView, topView: UIView? = nil) {
        container.addSubview(newView)
        newView.snp.makeConstraints { (make) in
            make.size.equalTo(40)
            make.left.equalTo(container).offset(20)
            if let topView = topView {
                make.top.equalTo(topView.snp.bottom).offset(20)
            } else {
                make.top.equalTo(container).offset(20)
            }
        }
    }

    func constrain(_ newView: UIView, leftView: UIView) {
        container.addSubview(newView)
        newView.snp.makeConstraints { (make) in
            make.size.equalTo(40)
            make.left.equalTo(leftView.snp.right).offset(20)
            make.top.equalTo(leftView)
        }
    }

}


