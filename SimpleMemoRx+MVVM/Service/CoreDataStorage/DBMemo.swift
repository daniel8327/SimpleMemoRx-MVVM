//
//  DBMemo.swift
//  SimpleMemoRx+MVVM
//
//  Created by 장태현 on 2020/07/29.
//  Copyright © 2020 장태현. All rights reserved.
//

import Foundation

import RealmSwift

class DBMemo: Object, Codable {
    
    @objc dynamic var identity: String
    @objc dynamic var content: String
    @objc dynamic var insertDate: Date
    
    private let dateFormatter: DateFormatter = {
        let dft = DateFormatter()
        dft.locale = Locale(identifier: "Ko_kr")
        dft.dateStyle = .medium
        dft.timeStyle = .medium
        return dft
    }()
    
    // Primary Key 는 String, Int만 가능
    override static func primaryKey() -> String {
        return "identity"
    }
    
    required init(content: String, insertDate: Date = Date()) {
        self.content = content
        self.insertDate = insertDate
        self.identity = "\(insertDate.timeIntervalSinceReferenceDate)"
    }
    
    init(original: DBMemo, updateContent: String) {
        //self.init()
        //self = original
        self.identity = original.identity
        self.insertDate = original.insertDate
        self.content = updateContent
    }
    
    required init() {
        identity = ""
        content = ""
        insertDate = Date()
        super.init()
    }
     
    init(memo: Memo) {
       self.content = memo.content
       self.insertDate = memo.insertDate
       self.identity = "\(memo.insertDate.timeIntervalSinceReferenceDate)"
    }
    
    // MARK: Codable
    private enum CodingKeys : String, CodingKey {
        case identity
        case content
        case insertDate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identity,   forKey: .identity  )
        try container.encode(content,    forKey: .content   )
        try container.encode(insertDate, forKey: .insertDate)
    }
}
