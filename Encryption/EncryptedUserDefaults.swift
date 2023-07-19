//
//  EncryptedUserDefaults.swift
//  EncryptedUserDefault
//
//  Created by Siddhant Kumar on 28/06/23.
//

import Foundation
import CryptoKit
import CommonCrypto

class EncryptedUserDefaults {
    enum EncryptionLevel {
        case normal,
        medium,
        hard
        
        var key: SymmetricKey {
            switch self {
            case .normal:
                return SymmetricKey(size: .bits128)
            case .medium:
                return SymmetricKey(size: .bits192)
            case .hard:
                return SymmetricKey(size: .bits256)
            }
        }
    }
    
    private var encryptionKey: SymmetricKey
    
    init(level: EncryptionLevel) {
        self.encryptionKey = level.key
        
        // Usage example:

        let password = "YourPassword"

        // Generate the symmetric key
        if let symmetricKey = AESKeyGenerator.generateSymmetricKey(password: password) {
            print("Generated SymmetricKey: \(symmetricKey)")
            self.encryptionKey = symmetricKey
        } else {
            print("Failed to generate SymmetricKey.")
        }

    }
    
    private func encrypt(value: String) throws -> Data {
        let data = value.data(using: .utf8)!
        let sealedBox = try AES.GCM.seal(data, using: encryptionKey)
        return sealedBox.combined!
    }
    
    private func decrypt(encryptedData: Data) throws -> String {
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: encryptionKey)
        let decryptedValue = String(data: decryptedData, encoding: .utf8)!
        return decryptedValue
    }
    
    func setValue(_ value: String, forKey key: String) {
        do {
            let encryptedData = try encrypt(value: value)
            UserDefaults.standard.set(encryptedData, forKey: key)
        } catch {
            print("Encryption failed: \(error)")
        }
    }
    
    func getValue(forKey key: String) -> String? {
        if let encryptedData = UserDefaults.standard.data(forKey: key) {
            do {
                let decryptedValue = try decrypt(encryptedData: encryptedData)
                return decryptedValue
            } catch {
                print("Decryption failed: \(error)")
            }
        }
        return nil
    }
    
}


class AESKeyGenerator {
    private static let salt = "YourSaltValue".data(using: .utf8)!
    
    static func generateSymmetricKey(password: String) -> SymmetricKey? {
        guard let derivedKeyData = deriveKey(from: password, salt: salt) else {
            return nil
        }
        
        return SymmetricKey(data: derivedKeyData)
    }
    
    private static func deriveKey(from password: String, salt: Data) -> Data? {
        let passwordData = password.data(using: .utf8)!
        let derivedKeyLength = kCCKeySizeAES256
        var derivedKey = Data(count: derivedKeyLength)
        
        let status = derivedKey.withUnsafeMutableBytes { derivedKeyBytes in
            salt.withUnsafeBytes { saltBytes in
                passwordData.withUnsafeBytes { passwordBytes in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordBytes.baseAddress, passwordData.count,
                        saltBytes.baseAddress, salt.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        100_000, // iterations
                        derivedKeyBytes.baseAddress, derivedKeyLength
                    )
                }
            }
        }
        
        return status == kCCSuccess ? derivedKey : nil
    }
}
