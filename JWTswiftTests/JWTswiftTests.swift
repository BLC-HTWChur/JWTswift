//
//  JWTswiftTests.swift
//  JWTswiftTests
//
//  Created by Blended Learning Center on 19.12.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import XCTest
@testable import JWTswift

class JWTswiftTests: XCTestCase {
    let bundle = Bundle(identifier: "ch.htwchur.JWTswift")
    var pubPath : URL!
    var keyman : KeyStore!
    var dict : [String: String]!
    var jwsHeaderDict : [String: Any]!
    var jwsPayloadDict : [String : Any]!
    var dataToHash : String!
    var testJWK : [String:Any]!
    var testCEK : [UInt8]!
    
    override func setUp() {
        super.setUp()
        //        pubPath = Bundle.main.url(forResource: "eduid_pub", withExtension: "jwks") || NOT FOR FRAMEWORK
        
        //        pubPath = bundle?.url(forResource: "eduid_pub", withExtension: "jwks")
        keyman = KeyStore()
        //        print("public key path : \(pubPath.path)")
        dict = [
            "e"  : "AQAB",
            "kty" : "RSA",
            "n" : "0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCiFV4n3oknjhMstn64tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65YGjQR0_FDW2QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n91CbOpbISD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINHaQ-G_xBniIqbw0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw"]
        
        jwsHeaderDict = [
            "typ" : "JWT",
            "alg": "HS256"
        ]
        
        jwsPayloadDict = [
            "testdata" : "test1",
            "payloadTest" : "test2",
            "keyToSend" : ["e": "AQAB", "kid": "LolpQpI9lNNqFu-UmAZLQJ3zKOeECBN8YQ4TUf1X86Y", "kty": "RSA", "n": "xHQNRKCzDmkKlxrQHeAwtrpcao0z2s-gvaZAbTt9e18-1F-LMwyLQjDJ681YhSLHIZXaCAStE_KxRf5byBbDbgL5Yx1ngCxKibQ43gFFiWCH6JRsUL-PNEHZdhOPWnSTlzSbszFxYSucYX3PyKVoG-lI03UyZ_60xKabAgciQtEszoFJ53A3ZKh3ddblsSnPPeuj2oIGRY4CmphAuGXl_ff5Co1j2i5ztS3P2oM4XaRB925HIXv2A-SqnBxBK_MRuH93BqGfOs6AVh1mRf1zSNnNAe-Lmku_jkTEk-FKlzSjb4cNgXwEDsSIP3mBMuPZ6zSKFf3FpX1kVRd83ecNfw"]
        ]
        
        dataToHash = "NDk4YmIwN2EtMWZlNy00ZDk4LWEyMTctMDY4OTFkMzVlYmFmAySFHbjPcIT3RCdaMlAO"
        
        testJWK = [
                "kty":"RSA",
            "n":"sXchDaQebHnPiGvyDOAT4saGEUetSyo9MKLOoWFsueri23bOdgWp4Dy1WlUzewbgBHod5pcM9H95GQRV3JDXboIRROSBigeC5yjU1hGzHHyXss8UDprecbAYxknTcQkhslANGRUZmdTOQ5qTRsLAt6BTYuyvVRdhS8exSZEy_c4gs_7svlJJQ4H9_NxsiIoLwAEk7-Q3UXERGYw_75IDrGA84-lA_-Ct4eTlXHBIY2EaV7t7LjJaynVJCpkv4LKjTTAumiGUIuQhrNhZLuF_RJLqHpM2kgWFLU7-VTdL1VbC2tejvcI2BlMkEpk1BzBZI0KQB0GaDWFLN-aEAw3vRw",
                "e":"AQAB",
                "d":"VFCWOqXr8nvZNyaaJLXdnNPXZKRaWCjkU5Q2egQQpTBMwhprMzWzpR8Sxq1OPThh_J6MUD8Z35wky9b8eEO0pwNS8xlh1lOFRRBoNqDIKVOku0aZb-rynq8cxjDTLZQ6Fz7jSjR1Klop-YKaUHc9GsEofQqYruPhzSA-QgajZGPbE_0ZaVDJHfyd7UUBUKunFMScbflYAAOYJqVIVwaYR5zWEEceUjNnTNo_CVSj-VvXLO5VZfCUAVLgW4dpf1SrtZjSt34YLsRarSb127reG_DUwg9Ch-KyvjT1SkHgUWRVGcyly7uvVGRSDwsXypdrNinPA4jlhoNdizK2zF2CWQ",
                "p":"9gY2w6I6S6L0juEKsbeDAwpd9WMfgqFoeA9vEyEUuk4kLwBKcoe1x4HG68ik918hdDSE9vDQSccA3xXHOAFOPJ8R9EeIAbTi1VwBYnbTp87X-xcPWlEPkrdoUKW60tgs1aNd_Nnc9LEVVPMS390zbFxt8TN_biaBgelNgbC95sM",
                "q":"uKlCKvKv_ZJMVcdIs5vVSU_6cPtYI1ljWytExV_skstvRSNi9r66jdd9-yBhVfuG4shsp2j7rGnIio901RBeHo6TPKWVVykPu1iYhQXw1jIABfw-MVsN-3bQ76WLdt2SDxsHs7q7zPyUyHXmps7ycZ5c72wGkUwNOjYelmkiNS0",
                "dp":"w0kZbV63cVRvVX6yk3C8cMxo2qCM4Y8nsq1lmMSYhG4EcL6FWbX5h9yuvngs4iLEFk6eALoUS4vIWEwcL4txw9LsWH_zKI-hwoReoP77cOdSL4AVcraHawlkpyd2TWjE5evgbhWtOxnZee3cXJBkAi64Ik6jZxbvk-RR3pEhnCs",
                "dq":"o_8V14SezckO6CNLKs_btPdFiO9_kC1DsuUTd2LAfIIVeMZ7jn1Gus_Ff7B7IVx3p5KuBGOVF8L-qifLb6nQnLysgHDh132NDioZkhH7mI7hPG-PYE_odApKdnqECHWw0J-F0JWnUd6D2B_1TvF9mXA2Qx-iGYn8OVV1Bsmp6qU",
                "qi":"eNho5yRBEBxhGBtQRww9QirZsB66TrfFReG_CcteI1aCneT0ELGhYlRlCtUkTRclIfuEPmNsNDPbLoLqqCVznFbvdB7x-Tl-m0l_eFTj2KiqwGqE9PZB9nNTwMVvH3VRRSLWACvPnSiwP8N5Usy-WRXS-V7TbpxIhvepTfE0NNo"
        ]
        
        testCEK = [4, 211, 31, 197, 84, 157, 252, 254, 11, 100, 157, 250, 63, 170, 106,206, 107, 124, 212, 45, 111, 107, 9, 219, 200, 177, 0, 240, 143, 156,44, 207]
    }
    
    
    
    override func tearDown() {
        pubPath = nil
        keyman = nil
        dict = nil
        jwsHeaderDict = nil
        jwsPayloadDict = nil
        dataToHash = nil
        testJWK = nil
        testCEK = nil
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    
    func testTransformingJWKintoPEMandSavingIntoKeychain(){
        pubPath = bundle?.url(forResource: "eduid_pub", withExtension: "jwks")
        //JWK TO PEM PKCS#1 save to keychain, retrieve the pem from keychain and convert it back to JWK
        let keyStr = keyman.jwksToKeyFromBundle(jwksPath: pubPath.path)
        XCTAssertNotNil(keyStr)
        let keyObject = keyStr?.first
        var error : Unmanaged<CFError>?
        let keyData = SecKeyCopyExternalRepresentation((keyObject?.getKeyObject())!, &error)
        XCTAssertNil(error)
        let options : [String : Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeRSA as String,
                                        kSecAttrKeyClass as String: kSecAttrKeyClassPublic as String,
                                        kSecAttrKeySizeInBits as String : 2048,
                                        ]
        let publickey = SecKeyCreateWithData(keyData! as CFData, options as CFDictionary, &error)
        XCTAssertNil(error , "ERROR while creating SecKey")
        let attributes = SecKeyCopyAttributes(publickey!) as NSDictionary?
        print(attributes!)
        
        XCTAssertTrue(SecKeyIsAlgorithmSupported(publickey!, SecKeyOperationType.encrypt, .rsaEncryptionPKCS1))
        print("KEYSTR : \(keyStr!)")
        let keyFromChain = SecKeyCopyExternalRepresentation(publickey!, &error) as Data?
        XCTAssertNotNil(keyFromChain)
        print("key : \(String(describing: keyFromChain?.base64EncodedString() ))")
        print("Key hex : \(String(describing: keyFromChain?.hexDescription)) ")
        
        let jwkDict = KeyStore.pemToJWK(pemData: keyFromChain!)
        print(jwkDict)
        XCTAssertTrue(jwkDict["n"] != nil && (jwkDict["e"] != nil) && jwkDict["kty"] != nil && jwkDict["kid"] != nil)
    }
    
    func testKeyGenerator(){
        //generate key pair create dictionary with public and private key in it
        let keydict = KeyStore.generateKeyPair(keyType: kSecAttrKeyTypeRSA as String)
        XCTAssertNotNil(keydict)
        XCTAssertEqual(keydict?.count, 2)
        
        
    }
    
    func testKIDGenerator () {
        let kid  = KeyStore.createKIDfromJWK(jwkDict: dict)
        print("KID : " , kid!)
        XCTAssertNotNil(kid)
    }
    
    
    //kid is not saved to the key
    func testSaveKIDandKey(){
        
        let pubPath = bundle?.url(forResource: "eduid_pub", withExtension: "jwks")
        print("Public key Path : \(pubPath?.path ?? " ")")
        
        let keysCollection = keyman.jwksToKeyFromBundle(jwksPath: (pubPath?.path)!)
        XCTAssertTrue(keysCollection?.count == 1)
        
        
        let statKid = KeyChain.saveKey(tagString: "testKey", keyToSave: (keysCollection?.first!)!)
        
        XCTAssertTrue(statKid)
        
        let keyFromChain = KeyChain.loadKey(tagString: "testKey")
        XCTAssertNotNil(keyFromChain)
        XCTAssertEqual(keysCollection?.first?.getKid(), keyFromChain?.getKid())
        
        //deleting the keys on the keychain
        XCTAssertTrue(KeyChain.deleteKey(tagString: "testKey", keyToDelete: (keysCollection?.first)!))
        
    }
    
    func testCreateAndSaveKeyPair() {
        
        
        let keypair = KeyStore.generateKeyPair(keyType: kSecAttrKeyTypeRSA as String)
//        KeyChain.deleteKeyPair(tagString: "test", keyPair: keypair!)
        XCTAssertNotNil(keypair)
        XCTAssertTrue(keypair?.count == 2)
        
        let saved = KeyChain.saveKeyPair(tagString: "test", keyPair: keypair!)
        XCTAssertTrue(saved)
        
        let keyLoaded = KeyChain.loadKeyPair(tagString: "test")
        XCTAssertNotNil(keyLoaded)
        XCTAssertTrue(keyLoaded?.count == 2)
        
        XCTAssertEqual(keypair!["public"]?.getKid(), keyLoaded!["public"]?.getKid())
        XCTAssertEqual(keypair!["private"]?.getKid(), keyLoaded!["private"]?.getKid())
        
        let deleted = KeyChain.deleteKeyPair(tagString: "test", keyPair: keypair!)
        XCTAssertTrue(deleted)
    }
    
    func testRetrievingWithoutSaved(){
        let stat = KeyChain.loadKeyPair(tagString: "test")
        print(stat ?? "")
        XCTAssertNil(stat)
    }
    
    func testGetPublicAndPrivatefromBundle (){
        //get public key from DER data in bundle
        let urlPath = bundle?.url(forResource: "rsaCert", withExtension: "der") //Bundle.main.url(forResource: "rsaCert", withExtension: ".der")
        print("url path : " , urlPath?.absoluteString as Any)
        let publickeyId = keyman.getPublicKeyFromCertificateInBundle(resourcePath: (urlPath?.path)!)
        XCTAssertNotNil(publickeyId)
        print(publickeyId.debugDescription)
        let publicKey = keyman.getKey(withKid: publickeyId!)
        
        //encrypt data with public key
        let algorithm = SecKeyAlgorithm.rsaEncryptionOAEPSHA512
        print("SECkeyBlockSize : " , SecKeyGetBlockSize(publicKey!.getKeyObject()))
        let plainText = "I AM LOCKED, PLEASE UNLOCK ME"
        
        let cipherText = CryptoManager.encryptData(key: publicKey!, algorithm: algorithm, plainData: plainText.data(using: String.Encoding.utf8)! as NSData)
        XCTAssertNotNil(cipherText)
        
        print("CIPHER TEXT : " , cipherText?.base64EncodedString() ?? "error by encryption")
        
        //Get private key from pem data in bundle
        //keyMan = KeyManager(resourcePath: (Bundle.main.url(forResource: "ios_priv", withExtension: ".pem")?.relativePath)!) || Not for framework
        let privateKeyPath = bundle?.path(forResource: "ios_priv", ofType: "pem")
        let privateKeyId = keyman.getPrivateKeyFromPemInBundle(resourcePath: privateKeyPath!, identifier: "testPrivate")
        let privateKey = keyman.getKey(withKid: privateKeyId!)
        XCTAssertNotNil(privateKey)
        
        //Decrypt with private key
        XCTAssertTrue(SecKeyIsAlgorithmSupported(privateKey!.getKeyObject(), .decrypt, algorithm) )
        XCTAssertEqual(cipherText?.length, SecKeyGetBlockSize(privateKey!.getKeyObject()) )
        
        let cleartext = CryptoManager.decryptData(key: privateKey!, algorithm: algorithm, cipherData: cipherText! as CFData)
        XCTAssertNotNil(cleartext)
        XCTAssertEqual(plainText, String.init(data: cleartext! as Data, encoding: String.Encoding.utf8))
    }
    
    func testSavingAndRetrievingKeyfromKeychain(){
        //get public key from DER data in bundle
        let urlPath = bundle?.url(forResource: "rsaCert", withExtension: "der") //Bundle.main.url(forResource: "rsaCert", withExtension: ".der") || NOT FOR FRAMEWORK
        
        do{
            let str = try String.init(contentsOf: urlPath!)
            print(str)
        } catch {
            print(error)
        }
        
        
        let publickeyId = keyman.getPublicKeyFromCertificateInBundle(resourcePath: (urlPath?.path)!)
        XCTAssertNotNil(publickeyId)
        
        let publicKey = keyman.getKey(withKid: publickeyId!)
        XCTAssertNotNil(publicKey)
        
        let status = KeyChain.saveKey(tagString: "eduid.publicKey", keyToSave: publicKey!)
        XCTAssertEqual(status, true)
        print("ITEMNOT FOUND :",errSecItemNotFound)
        let keyFromKC = KeyChain.loadKey(tagString: "eduid.publicKey")
        XCTAssertNotNil(keyFromKC)
        XCTAssertEqual(publicKey!.getKeyObject(), keyFromKC!.getKeyObject())
        XCTAssertEqual(publicKey!.getKid(), keyFromKC!.getKid())
        
        XCTAssertTrue(KeyChain.deleteKey(tagString: "eduid.publicKey", keyToDelete: publicKey!))
    }
    
    func testJWS(){
        let keydict = KeyStore.generateKeyPair(keyType: kSecAttrKeyTypeRSA as String)
        XCTAssertNotNil(keydict)
        let jws = JWS(payloadDict: jwsPayloadDict)
        XCTAssertNotNil(jws.sign(key: keydict!["private"]!, alg: .RS256))
        
        XCTAssertTrue(jws.verifyWithDict(header: jws.headerDict, payload: jwsPayloadDict, signature: jws.signatureStr!, key: keydict!["public"]! )  )
        
        XCTAssertTrue(JWS.verify(jwsToVerify: jws.jwsCompactResult!, key: keydict!["public"]!))
    }
    
    func testJWSparse(){
        let keydict = KeyStore.generateKeyPair(keyType: kSecAttrKeyTypeRSA as String)
        XCTAssertNotNil(keydict)
        let jws = JWS(payloadDict: jwsPayloadDict)
        XCTAssertNotNil(jws.sign(key: keydict!["private"]!, alg: .RS256))
        
        print("jws : " , jws.jwsCompactResult!)
        
        let parsed = JWS.parseJWSpayload(stringJWS: jws.jwsCompactResult!)
        print("PARSED")
        print(parsed!)
        XCTAssertTrue(parsed?.count != 0)
        XCTAssertTrue((parsed!["testdata"] != nil) && (parsed!["payloadTest"] != nil) && (parsed!["keyToSend"] != nil))
        
    }
    
    func testGetKeyIDFromJWKSinBundle() {
        var url = bundle?.url(forResource: "ios_priv", withExtension: "jwks")
        let keyID = keyman.getPrivateKeyIDFromJWKSinBundle(resourcePath: (url?.relativePath)!)
        XCTAssertNotNil(keyID)
        XCTAssertEqual(keyID, "tDVTKwRxlxhccA-yllPwjQdIBXpwbHq0GrYjt1FW8us" )
        
        url = bundle?.url(forResource: "ios_priv", withExtension: "pem")
        let _ = keyman.getPrivateKeyFromPemInBundle(resourcePath: (url?.relativePath)!, identifier: keyID!)
        let privkey = keyman.getKey(withKid: keyID!)
        XCTAssertNotNil(privkey)
        
    }
    
    func testHashfunction() {
        let data = dataToHash.data(using: .ascii)
        XCTAssertNotNil(data!)
        let result = data?.hashSHA256()
        print([UInt8](result!) )
        print(result?.base64EncodedString() as Any)
        XCTAssertEqual(result?.hexDescription, "d39d6be6abc67dee3dae59ba565038e0f2cf6e9b42d42db4f5c4939528cf9a96")
        
    }
    
    func testJWE(){
        let jwe = JWE()
        print(jwe.joseHeaderDict)
        jwe.plaintext = "Live long and prosper."
        guard let bytetext : [UInt8] = Array(jwe.plaintext!.utf8) else {
            print(errno)
        }
        print("byte format of the text : " , bytetext)
        do{
            let jsonheader = try JSONSerialization.data(withJSONObject: jwe.joseHeaderDict, options: .init(rawValue: 0))
            print(jsonheader.base64EncodedString().base64ToBase64Url().clearPaddding())
        }catch {
            XCTFail()
        }
    }
    
    func testJweGenerateCEK(){
        let jwe = JWE()
        let cekArray = jwe.generateCEK()
        print(cekArray)
        XCTAssertNotNil(cekArray)
        XCTAssertEqual(cekArray?.count, 32)
    }
    
    func testEncryptDecrpytCEK() {
        //encrypt CEK with public JWK from the recipient
        
        guard let key = keyman.jwkToKey(jwkDict: testJWK) else {
            XCTFail()
            return
        }
        let jwe = JWE()
        
        let cipherText = jwe.encryptCEK(encryptKey: key, alg: .RSA1_5, cek: testCEK)
        print("str =" , cipherText!)
        XCTAssertNotNil(cipherText)
    }
    
    func testJweGenerateInitVector(){
        let jwe = JWE()
        let str = jwe.generateInitVec()
        print("init vector = " , str!.count)
        XCTAssertNotNil(str)
    }
    
    func testSHA512(){
        let testString = "blcHTWchur"
        let dataTest = testString.data(using: .utf8)
        let hashdata  = dataTest?.hashSHA512()
        
        
        print("SHA512 result = ", hashdata!.hexDescription, "\n length = ", hashdata!.hexDescription.count)
        
        XCTAssertEqual(hashdata?.hexDescription.uppercased(), "CF37521606600314182DFE80E514393CE45950DC8010E83E639018DF7DD6DC1CD15A6254E334CAB30C1F15F4A7BB0FBE486D991C839818AA74A39DC88B153635")
    }
    
    func testEncryptAES() {
        let jwe = JWE()
        
        let message = "Don't try to read this text. Top Secret Stuff"
        let messageData = message.data(using: .utf8)!
        let keyData = "12345678901234567890123456789012".data(using: .utf8)!
        let ivData = "abcdefghijklmnop".data(using: .utf8)!
        
        let encryptedData = jwe.encryptAes(data: messageData, keyData: keyData, ivData: ivData)
        let decryptedData = jwe.decryptAes(data: encryptedData, keyData: keyData, ivData: ivData)
        let decrypted = String(data: decryptedData, encoding: .utf8)!
        print("decrypted Text = " , decrypted)
        XCTAssertEqual(decrypted, message)
    }
    
    func testAES128(){
        let jwe = JWE()
        let testCEK = [4, 211, 31, 197, 84, 157, 252, 254, 11, 100, 157, 250, 63, 170, 106, 206, 107, 124, 212, 45, 111, 107, 9, 219, 200, 177, 0, 240, 143, 156, 44, 207]
        
        //first extract CEK
        let middleIndex = (testCEK.count / 2)
        let macKey = testCEK[..<middleIndex]
        let encKey = testCEK[middleIndex...]
        print("MAC KEY = \(macKey)")
        print("ENC KEY = \(encKey)")
        
        
    }
}
