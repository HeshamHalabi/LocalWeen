//
//  FUIAuthBaseViewController+extension.swift
//  LocalWeen
//
//  Created by Bruce Bookman on 3/22/18.
//  Copyright © 2018 Bruce Bookman. All rights reserved.
//

import FirebaseAuthUI

extension FUIAuthBaseViewController{
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
    }
}
