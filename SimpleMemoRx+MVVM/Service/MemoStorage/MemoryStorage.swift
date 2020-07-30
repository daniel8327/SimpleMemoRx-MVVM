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
import TTGSnackbar

class MemoryStorage: MemoStorageType {
    
    var disposeBag = DisposeBag()
   
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
        if let dbMemo = realm.objects(DBMemo.self).filter("insertDate = %@", memo.insertDate).first {

            // 삭제 전 레지에 저장
            if let encoded = try? JSONEncoder().encode(dbMemo) {
                UserDefaults.standard.set(encoded, forKey: UNDO.DBMemo.rawValue)
                UserDefaults.standard.synchronize()

                // 아래에 스낵바 띄우기
                let snackbar = TTGSnackbar(
                    message: "",
                    duration: .middle,
                    actionText: "삭제 취소",
                    actionBlock: { [unowned self] _ in
                        self.undo()
                    }
                )
                snackbar.show()
            }
            
            realm.beginWrite()
            realm.delete(dbMemo)
            try? realm.commitWrite()
            
            fetch()
        }
        
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
    
    /// UserDefaults 에 담긴 값으로 삭제 취소 작업을 처리한다.
    func undo() {
        if let dbMemoData = UserDefaults.standard.data(forKey: UNDO.DBMemo.rawValue),
            let dbMemo = try? JSONDecoder().decode(DBMemo.self, from: dbMemoData) {

            let realm = RealmCenter.INSTANCE.getRealm()
            
            realm.beginWrite()
            realm.add(dbMemo, update: .all)
            
            try? realm.commitWrite()
            
            fetch()

            // 초기화
            UserDefaults.standard.set(nil, forKey: UNDO.DBMemo.rawValue)
            UserDefaults.standard.synchronize()
            
        } else {
            print("처리할 데이터가 없습니다.")
        }
    }
}

enum UNDO: String {
    case DBMemo
}
