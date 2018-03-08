//
//  BaseViewController.swift
//  EnumStateManagerExample
//
//  Created by JerryWang on 2018/3/6.
//  Copyright © 2018年 JerryWang. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    let errorView = ErrorView()
    let loadingView = LoadingView()
    let emptyView = EmptyView()
}

class ErrorView: UIView { }
class LoadingView: UIView { }
class EmptyView: UIView { }
