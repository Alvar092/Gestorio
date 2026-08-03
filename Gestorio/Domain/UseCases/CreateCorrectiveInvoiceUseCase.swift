import Foundation

@MainActor
protocol CreateCorrectiveInvoiceUseCaseProtocol {
    func create(_ correctiveInvoice: CorrectiveInvoice) throws -> CorrectiveInvoice
}

@MainActor
final class CreateCorrectiveInvoiceUseCase: CreateCorrectiveInvoiceUseCaseProtocol {
    private let correctiveInvoiceRepository: CorrectiveInvoiceRepositoryProtocol
    private let invoiceRepository: InvoiceRepositoryProtocol
    private let chainRepository: InvoiceChainRepositoryProtocol
    private let signer: HashChainSigningContract

    init(
        correctiveInvoiceRepository: CorrectiveInvoiceRepositoryProtocol,
        invoiceRepository: InvoiceRepositoryProtocol,
        chainRepository: InvoiceChainRepositoryProtocol,
        signer: HashChainSigningContract
    ) {
        self.correctiveInvoiceRepository = correctiveInvoiceRepository
        self.invoiceRepository = invoiceRepository
        self.chainRepository = chainRepository
        self.signer = signer
    }

    convenience init() {
        self.init(
            correctiveInvoiceRepository: CorrectiveInvoiceRepository(),
            invoiceRepository: InvoiceRepository(),
            chainRepository: InvoiceChainRepository(),
            signer: HashChainSigner.shared
        )
    }

    func create(_ correctiveInvoice: CorrectiveInvoice) throws -> CorrectiveInvoice {
        let originalExists = try invoiceRepository.fetchAll().contains {
            $0.number == correctiveInvoice.originalInvoiceNumber && $0.hash == correctiveInvoice.originalInvoiceHash
        }
        guard originalExists else {
            throw RepositoryError.notFound
        }

        let previousHash = try chainRepository.fetchLastHash()
        let hash = signer.sign(payload: canonicalPayload(for: correctiveInvoice), previousHash: previousHash)
        var signedCorrectiveInvoice = correctiveInvoice
        signedCorrectiveInvoice.previousHash = previousHash
        signedCorrectiveInvoice.hash = hash
        return try correctiveInvoiceRepository.create(signedCorrectiveInvoice)
    }

    private func canonicalPayload(for correctiveInvoice: CorrectiveInvoice) -> String {
        [
            correctiveInvoice.number,
            ISO8601DateFormatter().string(from: correctiveInvoice.date),
            correctiveInvoice.clientName,
            correctiveInvoice.clientTaxID,
            correctiveInvoice.concept,
            correctiveInvoice.totalPrice.description,
            correctiveInvoice.originalInvoiceNumber,
            correctiveInvoice.originalInvoiceHash,
        ].joined(separator: "|")
    }
}
