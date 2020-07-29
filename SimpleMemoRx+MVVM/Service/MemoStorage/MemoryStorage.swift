//
//  MemoryStorage.swift
//  SimpleMemoRx+MVVM
//
//  Created by 장태현 on 2020/07/29.
//  Copyright © 2020 장태현. All rights reserved.
//

import Foundation

import RxSwift

class MemoryStorage: MemoStorageType {
    
    // dummy data
    private var list = [Memo(content: "Let's go Swift", insertDate: Date().addingTimeInterval(-20)),
                        Memo(content: "Let's go Kotlin", insertDate: Date().addingTimeInterval(-10))]
    
    private lazy var store = BehaviorSubject<[Memo]>(value: list)
    
    @discardableResult
    func createMemo(content: String) -> Observable<Memo> {
        let newMemo = Memo(content: content)
        list.insert(newMemo, at: 0)
        
        return Observable.just(newMemo)
    }
    
    @discardableResult
    func memoList() -> Observable<[Memo]> {
        
        ///TODO : 
        return store.asObservable() // 아래와 위의 차이는??????
//        return store
    }
    
    @discardableResult
    func update(memo: Memo, content: String) -> Observable<Memo> {
        let updated = Memo(original: memo, updateContent: content)
        
        if let index = list.firstIndex(where: { $0 == memo }) {
            list.remove(at: index)
            list.insert(updated, at: index)
        }
        
        store.onNext(list)
        
        return Observable.just(updated)
    }
    
    @discardableResult
    func delete(memo: Memo) -> Observable<Memo> {
        if let index = list.firstIndex(where: { $0 == memo }) {
            list.remove(at: index)
        }
        
        store.onNext(list)
        
        return Observable.just(memo)
    }
}
