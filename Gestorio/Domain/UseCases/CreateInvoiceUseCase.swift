import Foundation

@MainActor
protocol CreateInvoiceUseCaseProtocol {
    func create(_ invoice: Invoice) throws -> Invoice
}

@MainActor
final class CreateInvoiceUseCase: CreateInvoiceUseCaseProtocol {
    private let repository: InvoiceRepositoryProtocol
    private let chainRepository: InvoiceChainRepositoryProtocol
    private let signer: HashChainSigningContract

    init(
        repository: InvoiceRepositoryProtocol,
        chainRepository: InvoiceChainRepositoryProtocol,
        signer: HashChainSigningContract
    ) {
        self.repository = repository
        self.chainRepository = chainRepository
        self.signer = signer
    }

    convenience init() {
        self.init(
            repository: InvoiceRepository(),
            chainRepository: InvoiceChainRepository(),
            signer: HashChainSigner.shared
        )
    }

    func create(_ invoice: Invoice) throws -> Invoice {
        let previousHash = try chainRepository.fetchLastHash()
        let hash = signer.sign(payload: canonicalPayload(for: invoice), previousHash: previousHash)
        var signedInvoice = invoice
        signedInvoice.previousHash = previousHash
        signedInvoice.hash = hash
        return try repository.create(signedInvoice)
    }

    private func canonicalPayload(for invoice: Invoice) -> String {
        [
            invoice.number,
            ISO8601DateFormatter().string(from: invoice.date),
            invoice.clientName,
            invoice.clientTaxID,
            invoice.concept,
            invoice.totalPrice.description,
        ].joined(separator: "|")
    }
}
