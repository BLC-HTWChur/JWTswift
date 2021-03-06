//
//  KeyChain.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 05.12.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import Foundation

public class KeyChain {
    
//    ------ SAVE-------
    
    public static func saveKeyPair(tagString : String, keyPair : [String : Key]) -> Bool {
        
        if loadKeyPair(tagString: tagString) != nil {
            return false
        }
        
        if(saveKid(tagString: tagString , kid: (keyPair["public"]?.getKid())!) &&
            saveKeyObject(tagString: (keyPair["public"]?.getKid())! + "public", keyObject: (keyPair["public"]?.getKeyObject())!) &&
            saveKeyObject(tagString: (keyPair["private"]?.getKid())! + "private", keyObject: (keyPair["private"]?.getKeyObject())!)) {
            return true
        } else {
            return false
        }
        
    }
    
    public static func saveKey(tagString: String , keyToSave : Key) -> Bool {
        
        //check if key is already on the keychain, return false if yes
        if loadKey(tagString: tagString) != nil {
            return false
        }
        
        
        if saveKid(tagString: tagString, kid: keyToSave.getKid()!) && saveKeyObject(tagString: keyToSave.getKid()! , keyObject: keyToSave.getKeyObject() ) {
            return true
        } else {
            return false
        }
        
    }
    
    /**
     Saving a specific key into the keychain.
     - parameter tagString: unique identifier for the Key to simplify the retrieving process.
     - parameter key: key data which want to be saved in to the keychain
     - returns:  Status from the saving process, true if successful, false if there any error
     */
    private static func saveKeyObject(tagString: String, keyObject: SecKey) -> Bool{
        let tag = tagString.data(using: .utf8)
        
        let saveQuery = [
            kSecClass as String : kSecClassKey as String,
            kSecAttrApplicationTag as String : tag!,
            kSecValueRef as String : keyObject
            
            ] as [String : AnyObject]
        
        let status = SecItemAdd(saveQuery as CFDictionary, nil)
        if status == noErr {
            return true
        } else {
            print("ATRRIBUTE :\(status == errSecParam)")
            print("error \(status.description)")
            return false
        }
    }
    
    private static func saveKid(tagString : String , kid : String) -> Bool{
//                let tag = tagString.data(using: .utf8)
        //Make sure kid is base64 not base64url
        let encodedKid = kid.data(using: .utf8)
        
        // Check if item is already on the keychain, return false if yes
        if loadKid(tagString: tagString) == kid {
            return false
        }
        
        let saveQuery : [String : AnyObject ] = [
            kSecClass as String : kSecClassGenericPassword ,
            kSecAttrService as String : tagString as AnyObject,
            kSecValueData as String : encodedKid as AnyObject
        ]
        
        
        let status = SecItemAdd(saveQuery as CFDictionary, nil)
        guard status == noErr else {
            print("FAILED STATUS : \(status)")
            return false
        }
        print("KID Saved : \(kid)")
        return true
    }
    
    //----LOAD----
    
    public static func loadKeyPair(tagString : String) -> [String : Key]? {
        
        let kidTmp = loadKid(tagString: tagString)
        if kidTmp == nil {
            print("No key ID found in the keychain")
            return nil
        }
        
        let pubKeyObject = loadKeyObject(tagString: kidTmp! + "public")
        let privKeyObject = loadKeyObject(tagString: kidTmp! + "private")
        
        if(pubKeyObject == nil || privKeyObject == nil ){
            print ("No KeyPair found in the keychain")
            return nil
        }
        
        var keyPair = [String : Key]()
        keyPair["public"] = Key(keyObject: pubKeyObject!, kid: kidTmp!)
        keyPair["private"] = Key(keyObject: privKeyObject!, kid: kidTmp!)
        
        return keyPair
    }
    
    public static func loadKey(tagString : String) -> Key?{
        var kidTmp : String?
        var keyObjectTmp : SecKey?
        
//        let dataTag = tagString.data(using: .utf8)
        
        kidTmp = loadKid(tagString: tagString)
        if(kidTmp == nil){
            print("Error found in loading Key ID")
            return nil
        }
        keyObjectTmp = loadKeyObject(tagString: kidTmp!)
        if(keyObjectTmp == nil){
            print("Error found in loading SecKey")
            return nil
        }
        
        let result = Key(keyObject: keyObjectTmp!, kid: kidTmp!)
        return result
        
    }
    
    /**
     Load a specific SecKey from the keychain.
     - parameter tagString: unique identifier for the Key to simplify the retrieving process
     - returns : A SecKey object from the keychain , if there isn't any key found then return nil
     */
    private static func loadKeyObject(tagString : String) -> SecKey? {
        let tag = tagString.data(using: .utf8)
        let getQuery = [
            kSecClass as String : kSecClassKey,
            kSecAttrApplicationTag as String : tag!,
            kSecReturnRef as String : true,
            kSecAttrKeyType as String : kSecAttrKeyTypeRSA
            ] as [String : Any]
        
        var loadedKey : CFTypeRef?
        let status : OSStatus = SecItemCopyMatching(getQuery as CFDictionary, &loadedKey)
        
        if status == noErr {
            return (loadedKey as! SecKey)
        } else {
            print(status.description)
            return nil
        }
    }
    
    private static func loadKid(tagString : String) -> String? {
        //        let tag = tagString.data(using: .utf8)
        let getQuery : [String : AnyObject] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String : tagString as AnyObject,
            
            kSecMatchLimit as String : kSecMatchLimitOne,
            kSecReturnAttributes as String : kCFBooleanFalse,
            kSecReturnData as String : kCFBooleanTrue
        ]
        var loadedKid : AnyObject?
        
        let status : OSStatus = withUnsafeMutablePointer(to: &loadedKid) {
            SecItemCopyMatching(getQuery as CFDictionary, UnsafeMutablePointer($0))
        }
        //            SecItemCopyMatching(getQuery as CFDictionary, &loadedKid)
        
        if status == noErr {
            let kid  = loadedKid as! Data
            let kidstr = String(data: kid, encoding: .utf8)
            print("loaded kid : \(kidstr!)")
            return kidstr
            /*
            let dataKid = loadedKid as! Data
            print(dataKid.base64EncodedString())
            return String(data: dataKid, encoding: .utf8)
//            return dataKid.base64EncodedString().clearPaddding()
 */
        } else{
            print(status.description)
            return nil
        }
        
    }
    
    //-----DELETE------
    
    public static func deleteKeyPair(tagString : String , keyPair : [String : Key]) -> Bool {
        
        let kidIsDeleted = deleteKID(tagString: tagString)
        let pubKeyIsDeleted = deleteKeyObject(tagString: keyPair["public"]!.getKid()! + "public")
        let privKeyIsDeleted = deleteKeyObject(tagString: keyPair["private"]!.getKid()! + "private")
        
        if kidIsDeleted && pubKeyIsDeleted && privKeyIsDeleted {
            return true
        } else {
            if !kidIsDeleted {
                print("error on deleting keyID")
            }
            if !pubKeyIsDeleted {
                print("error on deleting public Key")
            }
            if !privKeyIsDeleted {
                print("error on deleting private Key")
            }
            return false
        }
        
    }
    
    public static func deleteKey(tagString: String, keyToDelete : Key) -> Bool {
        
        let KIDIsDeleted = deleteKID(tagString: tagString)
        let keyObjectIsDeleted = deleteKeyObject(tagString: keyToDelete.getKid()!)
        
        if KIDIsDeleted && keyObjectIsDeleted {
            return true
        } else {
            if !KIDIsDeleted{
                print("error on deleting Key ID")
            }
            if !keyObjectIsDeleted{
                print("error on deleting KeyObject")
            }
            return false
        }
        
    }
    
    /**
     Delete a specific key from the keychain.
     - parameter tagString: unique identifier for the Key to simplify the retrieving process.
     - returns:  Status from the deleting process, true if successful, false if there any error
     */
    private static func deleteKeyObject(tagString : String) -> Bool {
        
        let tag = tagString.data(using: .utf8)
        let getQuery : [String : Any] = [
            kSecClass as String : kSecClassKey,
            kSecAttrApplicationTag as String : tag!,
            kSecAttrKeyType as String : kSecAttrKeyTypeRSA
        ]
        
        let status = SecItemDelete(getQuery as CFDictionary)
        
        if status == noErr {
            return true
        } else {
            return false
        }
    }
    
    private static func deleteKID(tagString: String) -> Bool {
        let deleteQuery : [String : Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String : tagString as Any
        ]
        
        let status = SecItemDelete(deleteQuery as CFDictionary)
        if status == noErr{
            print("delete kid successful")
            return true
        } else {
            print(status)
            return false
        }
        
    }
    
    private class func createUniqueID() -> String {
        let uuid : CFUUID = CFUUIDCreate(nil)
        let cfStr : CFString = CFUUIDCreateString(nil, uuid)
        
        let swiftString : String = cfStr as String
        return swiftString
    }
    
}
