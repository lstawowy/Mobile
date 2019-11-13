//
//  SplitViewController.swift
//  AppPogodowa
//
//  Created by Lukasz Stawowy on 11/13/19.
//  Copyright © 2019 Guest User. All rights reserved.
//

import UIKit

class PrimarySplitViewController: UISplitViewController,
UISplitViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
