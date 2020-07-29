//
//  MemoryStorage.swift
//  SimpleMemoRx+MVVM
//
//  Created by 장태현 on 2020/07/29.
//  Copyright © 2020 장태현. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import RealmSwift

class MemoryStorage: MemoStorageType {
    
    var disposeBag = DisposeBag()
    // dummy data
    /*private var list = [Memo(content: "Let's go Swift", insertDate: Date().addingTimeInterval(-20)),
                        Memo(content: "Let's go Kotlin", insertDate: Date().addingTimeInterval(-10))]*/
   
    private lazy var store = BehaviorSubject<[Memo]>(value: [])
    
    @discardableResult
    func createMemo(content: String) -> Observable<Memo> {
        let newMemo = Memo(content: content)
        //list.insert(newMemo, at: 0)
        
        let realm = RealmCenter.INSTANCE.getRealm()
        
        realm.beginWrite()
        realm.add(DBMemo(memo: newMemo), update: .all)
        
        try? realm.commitWrite()
        
        fetch()
        
        return Observable.just(newMemo)
    }
    
    @discardableResult
    func memoList() -> Observable<[Memo]> {

        fetch()
        
        return store.asObservable() // 아래와 위의 차이는??????
//        return store
    }
    
    @discardableResult
    func update(memo: Memo, content: String) -> Observable<Memo> {
        let updated = Memo(original: memo, updateContent: content)
        
        let realm = RealmCenter.INSTANCE.getRealm()
        
        realm.beginWrite()
        realm.add(DBMemo(memo: updated), update: .all)
        
        try? realm.commitWrite()
        
        fetch()
        
        return Observable.just(updated)
    }
    
    @discardableResult
    func delete(memo: Memo) -> Observable<Memo> {

        let realm = RealmCenter.INSTANCE.getRealm()
        
        realm.beginWrite()
        realm.delete(realm.objects(DBMemo.self).filter("insertDate = %@", memo.insertDate))
        try? realm.commitWrite()
        
        fetch()
        
        return Observable.just(memo)
    }
    
    func fetch() {
        fetchRx()
            .debug("fetch!!!")
            .subscribe(onNext: store.onNext)
            .disposed(by: disposeBag)
    }
    
    func fetchRx() -> Observable<[Memo]> {
        
        return Observable.create { emitter -> Disposable in
            self.fetch { data in
                switch data {
                case let .success(data):
                    emitter.onNext(data)
                    emitter.onCompleted()
                case let .failure(error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    /// 주문 내역 조회
    /// - Parameter onComplete: (Result<(Int, [OrderQueueModel]), Error>)
    func fetch(onComplete: @escaping (Result<[Memo], Error>) -> Void) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let realm = RealmCenter.INSTANCE.getRealm()
            
            let dbMemo = realm.objects(DBMemo.self).sorted(byKeyPath: "insertDate", ascending: false)
            
            let result = dbMemo
                .enumerated()
                .map { _, item in
                    Memo(dbMemo: item)
                }
            
            onComplete(.success(result))
        }
    }
}
