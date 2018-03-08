//
//  ViewController.swift
//  EnumStateManagerExample
//
//  Created by JerryWang on 2018/3/3.
//  Copyright © 2018年 JerryWang. All rights reserved.
//

import UIKit

class ViewController: BaseViewController, DataLoading {
    
    var state: UIState<[ParameterModel]> = UIState.loading {
        didSet {
            switch state {
                //binding content to specific view
            case .loaded(let model):
                update()
                print("render loaded UI by model")
            default:
                update()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
    }
    
    private func loadContent() {
        //kind of like transition
        state = .loading
        HttpbinAPIManager.fetchGetMethodContents(key1: "value1", key2: "value2", header: "headerValue", model: ResponseParameterModel.self) { [weak self](result) in
            guard let weakSelf = self else {return}
            switch result {
            case .success(let model):
                let modelArray = model.formatData()
                weakSelf.state = ((modelArray.count > 0) ? .loaded(modelArray) : .empty("input empty category..."))
            case .failure(let error):
                weakSelf.state = .error(error)
            }
            }.resume()
    }
}
