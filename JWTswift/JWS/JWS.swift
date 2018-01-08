//
//  JWS.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 08.12.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import Security
import Foundation

public class JWS{
    
    var headerDict : [String : Any]? = nil
    var payloadDict : [String : Any]? = nil
    var signatureStr : String? = nil
    var jwsCompactResult : String? = nil
    
    public init() {
        
    }
    
    public init(headerDict : [String : Any] , payloadDict :  [String : Any] , signatureStr : String? = nil) {
        self.headerDict = headerDict
        self.payloadDict = payloadDict
        self.signatureStr = signatureStr
    }
    
    
    /**
     Sign a header and payload data together with a specific key to create a signature
     - parameter header : a dictionary contains all the header data, if nil then object variable would be used for this function
     - parameter payload : a dictionary contains all payload data, if nil then object variable would be used for this function
     - returns : A complete String of JWS with the following format (header.payload.signature)
                if object variable(header and payload dictionary) not nil then the signature(String) would be save as object variable as well.
     */
    public func sign(header: [String : Any]? = nil, payload : [String: Any]? = nil , key : Key) -> String? {
        var headerVar : [String: Any]
        var payloadVar : [String: Any]
        if header == nil {
            if self.headerDict == nil {
                print("No header data found for this signing")
                return nil
            } else {
                headerVar = self.headerDict!
            }
        } else{
            headerVar = header!
        }
        
        if payload == nil{
            if self.payloadDict == nil {
                print("No payload data found for this signing")
                return nil
            } else {
                payloadVar = self.payloadDict!
            }
        } else {
            payloadVar = payload!
        }
        
        var result : String?
        do{
            let jsonHeader = try JSONSerialization.data(withJSONObject: headerVar, options: .init(rawValue: 0))
            var headerEncoded = jsonHeader.base64EncodedString()
            headerEncoded = headerEncoded.clearPaddding().base64ToBase64Url()
            let jsonPayload = try JSONSerialization.data(withJSONObject: payloadVar, options: .init(rawValue: 0))
            var payloadEncoded = jsonPayload.base64EncodedString()
            payloadEncoded = payloadEncoded.clearPaddding().base64ToBase64Url()
            let dataToSign = headerEncoded + "." + payloadEncoded
            print("DATA TO SIGN : \(dataToSign)")
            
            var error : Unmanaged<CFError>?
            let signature = SecKeyCreateSignature(key.getKeyObject(), SecKeyAlgorithm.rsaSignatureMessagePKCS1v15SHA256, dataToSign.data(using: String.Encoding.utf8)! as CFData, &error) as Data?
            result = (signature?.base64EncodedString())!.clearPaddding().base64ToBase64Url()
            self.signatureStr = result! //+ "=="
            print("SIGNATURE : \(String(describing: result))" , " Length : \(String(describing: result?.count))")
            result = dataToSign + "." + result!
        }catch {
            print(error)
            return nil
        }
        if self.headerDict != nil && self.payloadDict != nil{
            self.jwsCompactResult = result
        }
        return result
    }
    
//    kSecKeyAlgorithmRSASignatureDigestPKCS1v15SHA256
//    - RSA signature with PKCS#1 padding, input data must be SHA-256 generated digest.
//    kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256
//    - RSA signature with PKCS#1 padding, SHA-256 digest is generated from input data of any size.
    
    //TODO : CHANGE inout on signature
    
    /**
     Verify function to check if the data has been sent by the desired Sender
     - parameter header : a dictionary contains all the header information
     - parameter payload : a dictionary contains all payload data
     - parameter signature : signature string which used for verifying
     -returns:  Status from verifying the data, true if successful, false if not verified or if there any error on process
     */
    public func verify(header :  [String : Any]? , payload :[String: Any]? , signature: String , key : Key ) -> Bool {
        
        var headerVar : [String: Any]
        var payloadVar : [String: Any]
        var signatureTmp = signature
        if header == nil {
            if self.headerDict == nil {
                print("No header data found for this signing")
                return false
            } else {
                headerVar = self.headerDict!
            }
        } else{
            headerVar = header!
        }
        
        if payload == nil{
            if self.payloadDict == nil {
                print("No payload data found for this signing")
                return false
            } else {
                payloadVar = self.payloadDict!
            }
        } else {
            payloadVar = payload!
        }
        
        var result : Bool = false
        while(signatureTmp.count%4 != 0){
            signatureTmp += "="
        }
        let datasignature = Data.init(base64Encoded: signatureTmp.base64UrlToBase64(), options: .ignoreUnknownCharacters)
        print("DATA SIG: " , datasignature!.base64EncodedString())
        do{
            let jsonHeader = try JSONSerialization.data(withJSONObject: headerVar, options: .init(rawValue: 0))
            var headerEncoded = jsonHeader.base64EncodedString()
            headerEncoded = headerEncoded.clearPaddding().base64ToBase64Url()
            let jsonPayload = try JSONSerialization.data(withJSONObject: payloadVar, options: .init(rawValue: 0))
            var payloadEncoded = jsonPayload.base64EncodedString()
            payloadEncoded = payloadEncoded.clearPaddding().base64ToBase64Url()
            let signedData = headerEncoded + "." + payloadEncoded
            print("SIGNEDDATA : \(signedData)")
            var error: Unmanaged<CFError>?
            result = SecKeyVerifySignature(key.getKeyObject(), .rsaSignatureMessagePKCS1v15SHA256, signedData.data(using: String.Encoding.utf8)! as CFData, datasignature! as CFData, &error)
        }catch{
            print(error)
            return false
        }
        return result
    }
    
    
    /*
    public class func createHeader () -> String{
        var keys : [String] = []
        var header : [String : Any] = [:]
        keys.append("typ")
        keys.append("alg")
        header["typ"] = "JWT"
        header["alg"] = "HS256"
        print(header.description)
        var headerStr = "{"
        for i in 0..<keys.count {
            headerStr += "\"\(keys[i])\":" + "\"\(header[keys[i]] as! String)\""
            if(i < keys.count - 1) { headerStr += ",\r\n "}
        }
        headerStr += "}"
        return headerStr
    }
    */
    
}
