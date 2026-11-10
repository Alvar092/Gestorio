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
        var signedInvoice = invoice
        if signedInvoice.number.trimmingCharacters(in: .whitespaces).isEmpty {
            signedInvoice.number = try nextNumber(for: invoice.date)
        }
        let previousHash = try chainRepository.fetchLastHash()
        let hash = signer.sign(payload: canonicalPayload(for: signedInvoice), previousHash: previousHash)
        signedInvoice.previousHash = previousHash
        signedInvoice.hash = hash
        return try repository.create(signedInvoice)
    }

    /// Numeración correlativa por año: `AAAA-0001`, `AAAA-0002`...
    /// Las facturas son append-only, así que contar las del año no deja huecos.
    private func nextNumber(for date: Date) throws -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let count = try repository.fetchAll()
            .filter { calendar.component(.year, from: $0.date) == year }
            .count
        return "\(year)-" + String(format: "%04d", count + 1)
    }

    private func canonicalPayload(for invoice: Invoice) -> String {
        [
            invoice.number,
            ISO8601DateFormatter().string(from: invoice.date),
            invoice.issuerName,
            invoice.issuerTaxID,
            invoice.clientName,
            invoice.clientTaxID,
            invoice.concept,
            invoice.taxBase.description,
            invoice.vatRate.description,
            invoice.irpfRate.description,
            invoice.totalPrice.description,
        ].joined(separator: "|")
    }
}
