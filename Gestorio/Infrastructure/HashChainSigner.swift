import Foundation
import CryptoKit

protocol HashChainSigningContract {
    func sign(payload: String, previousHash: String) -> String
}

final class HashChainSigner: HashChainSigningContract {
    static let shared = HashChainSigner()

    func sign(payload: String, previousHash: String) -> String {
        let digest = SHA256.hash(data: Data((payload + previousHash).utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
