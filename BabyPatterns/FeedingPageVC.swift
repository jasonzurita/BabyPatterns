//
//  FeedingPageVC.swift
//  BabyPatterns
//
//  Created by Jason Zurita on 12/11/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class FeedingPageVC: UIPageViewController {

    var pages: [UIViewController] = []
    var segmentedControl: SegmentedControlBar?
    private var segmentIndex: (active: Int, pending: Int) = (0, 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self

        setActivePageViewController(direction: .forward)
    }

    fileprivate func setActivePageViewController(direction: UIPageViewControllerNavigationDirection) {
        setViewControllers([pages[segmentIndex.active]], direction: direction, animated: true)
    }
}

extension FeedingPageVC: SegmentedControlBarDelegate {
    func segmentedControlBar(bar _: SegmentedControlBar, segmentWasTapped index: Int) {

        let direction: UIPageViewControllerNavigationDirection = segmentIndex.active < index ? .forward : .reverse
        segmentIndex.active = index

        setActivePageViewController(direction: direction)
    }
}

extension FeedingPageVC: UIPageViewControllerDelegate {

    func pageViewController(_: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {

        guard pendingViewControllers.count == 1,
            let pendingVC = pendingViewControllers.first,
            let pendingIndex = pages.index(of: pendingVC) else { return }

        segmentIndex.pending = pendingIndex
    }

    func pageViewController(_: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers _: [UIViewController],
                            transitionCompleted completed: Bool) {

        guard finished, completed, let control = segmentedControl else { return }

        segmentIndex.active = segmentIndex.pending
        control.goToIndex(index: segmentIndex.active)
    }
}

extension FeedingPageVC: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let index = pages.index(of: viewController) else { return nil }
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }

        return pages[previousIndex]
    }

    func pageViewController(_: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let index = pages.index(of: viewController) else { return nil }
        let nextIndex = index + 1
        guard nextIndex < pages.count else { return nil }

        return pages[nextIndex]
    }
}
