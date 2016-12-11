//
//  FeedingPageVC.swift
//  Baby Tracker
//
//  Created by Jason Zurita on 12/11/16.
//  Copyright © 2016 Jason Zurita. All rights reserved.
//

import UIKit

class FeedingPageVC: UIPageViewController {

    fileprivate var pages:[UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self
        
        let page1 = FeedingTimerVC(nibName: "FeedingTimerVC", bundle: nil)
        let page2 = FeedingTimerVC(nibName: "FeedingTimerVC", bundle: nil)
        page2.view.backgroundColor = UIColor.purple
        let page3 = BottleVC(nibName: "BottleVC", bundle: nil)

        pages.append(contentsOf: [page1, page2, page3])
        
        setViewControllers([page1], direction: .forward, animated: true)
        
    }
}

extension FeedingPageVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    }
}

extension FeedingPageVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index = pages.index(of: viewController) else { return nil }
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let index = pages.index(of: viewController) else { return nil }
        let nextIndex = index + 1
        guard nextIndex < pages.count else { return nil }
        
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
}
