//
//  MemoDetailViewController.swift
//  SimpleMemoRx+MVVM
//
//  Created by 장태현 on 2020/07/29.
//  Copyright © 2020 장태현. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MemoDetailViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: MemoDetailViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func bindViewModel() {
        
        viewModel.title
            .drive(navigationItem.rx.title)
            .disposed(by: rx.disposeBag)
        
        viewModel.contents
            .bind(to: tableView.rx.items) { tableView, row, value in
                switch row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell")!
                    cell.textLabel?.text = value
                    return cell
                    
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell")!
                    cell.textLabel?.text = value
                    return cell
                default:
                    fatalError()
                }
        }.disposed(by: rx.disposeBag)
        
        // 이벤트에는 action 처리 tap 처리가 있다
        // 두개를 잘 비교해서 보자
        
        // 수정버튼 action 처리
        editButton.rx.action = viewModel.makeEditAction()
        deleteButton.rx.action = viewModel.makeDeleteAction()
        
        // 공유버튼 tap 처리 
        shareButton.rx.tap
            .throttle(.milliseconds(50), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let memo = self?.viewModel.memo.content else { return }
                
                let vc = UIActivityViewController(activityItems: [memo], applicationActivities: nil)
                self?.present(vc, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
        
    }
}
