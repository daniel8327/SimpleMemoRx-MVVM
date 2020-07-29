//
//  RealmCenter.swift
//  Who'sNext
//
//  Created by 장태현 on 2020/07/17.
//  Copyright © 2020 장태현. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCenter {
    
    /// RealmCenter.INSTANCE 로만 접근한다.
    public static let INSTANCE = RealmCenter()
    
    private init() {}
    
    private var _realmConfig : Realm.Configuration?
    
    internal func getRealm() -> Realm {
        
        if let conf = _realmConfig {

            return try! Realm(configuration: conf)
        } else {
            var conf = Realm.Configuration()
            
            conf.schemaVersion = 1
            
            conf.objectTypes = [DBMemo.self]
            
            print("\n================================= REALM 최초 호출 realm =================================")
            print("설정 위치 : \(conf.fileURL!.absoluteString)")
            print("======================================================================================\n")
            
            // Open the Realm with the configuration
            
            _realmConfig = conf
            
            return try! Realm(configuration: conf)
        }
    }
}
