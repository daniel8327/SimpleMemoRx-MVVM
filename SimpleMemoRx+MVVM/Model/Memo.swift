//
//  Memo.swift
//  SimpleMemoRx+MVVM
//
//  Created by 장태현 on 2020/07/29.
//  Copyright © 2020 장태현. All rights reserved.
//

import Foundation

struct Memo: Equatable {
    var content: String
    var insertDate: Date
    var identity: String
    
    init(content: String, insertDate: Date = Date()) {
        self.content = content
        self.insertDate = insertDate
        self.identity = "\(insertDate.timeIntervalSinceReferenceDate)"
    }
    
    init(original: Memo, updateContent: String) {
        self = original
        self.content = updateContent
    }
    
    init(dbMemo: DBMemo) {
        self.content = dbMemo.content
        self.insertDate = dbMemo.insertDate
        self.identity = "\(dbMemo.insertDate.timeIntervalSinceReferenceDate)"
    }
}
