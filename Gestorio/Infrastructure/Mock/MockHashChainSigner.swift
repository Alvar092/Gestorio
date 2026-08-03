import Foundation

final class MockHashChainSigner: HashChainSigningContract {
    var hashToReturn = "mocked-hash"
    private(set) var lastPayload: String?
    private(set) var lastPreviousHash: String?

    func sign(payload: String, previousHash: String) -> String {
        lastPayload = payload
        lastPreviousHash = previousHash
        return hashToReturn
    }
}
