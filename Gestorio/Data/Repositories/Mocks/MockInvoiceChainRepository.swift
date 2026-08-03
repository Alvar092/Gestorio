import Foundation

final class MockInvoiceChainRepository: InvoiceChainRepositoryProtocol {
    var lastHash: String = InvoiceChainRepository.genesisHash
    var errorToThrow: Error?

    func fetchLastHash() throws -> String {
        if let errorToThrow { throw errorToThrow }
        return lastHash
    }
}
