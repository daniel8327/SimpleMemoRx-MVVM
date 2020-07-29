//
//  ViewModelBindableType.swift
//  SimpleMemoRx+MVVM
//
//  Created by 장태현 on 2020/07/29.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit

protocol ViewModelBindableType {
    
    associatedtype T // generic 선언
    
    var viewModel: T! { get set }
    func bindViewModel()
}

extension ViewModelBindableType where Self: UIViewController {
    mutating func bind(viewModel: Self.T) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        
        bindViewModel()
    }
}
