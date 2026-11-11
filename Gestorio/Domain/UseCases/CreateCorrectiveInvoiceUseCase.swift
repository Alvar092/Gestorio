import Foundation

enum CorrectiveInvoiceError: LocalizedError, Equatable {
    case alreadyCorrected

    var errorDescription: String? {
        switch self {
        case .alreadyCorrected: "Esta factura ya tiene una rectificativa."
        }
    }
}

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

        let alreadyCorrected = try correctiveInvoiceRepository.fetchAll().contains {
            $0.originalInvoiceNumber == correctiveInvoice.originalInvoiceNumber
                && $0.originalInvoiceHash == correctiveInvoice.originalInvoiceHash
        }
        guard !alreadyCorrected else {
            throw CorrectiveInvoiceError.alreadyCorrected
        }

        var signedCorrectiveInvoice = correctiveInvoice
        if signedCorrectiveInvoice.number.trimmingCharacters(in: .whitespaces).isEmpty {
            signedCorrectiveInvoice.number = try nextNumber(for: correctiveInvoice.date)
        }
        let previousHash = try chainRepository.fetchLastHash()
        let hash = signer.sign(payload: canonicalPayload(for: signedCorrectiveInvoice), previousHash: previousHash)
        signedCorrectiveInvoice.previousHash = previousHash
        signedCorrectiveInvoice.hash = hash
        return try correctiveInvoiceRepository.create(signedCorrectiveInvoice)
    }

    /// Numeración correlativa por año: `R-AAAA-0001`, `R-AAAA-0002`...
    private func nextNumber(for date: Date) throws -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let count = try correctiveInvoiceRepository.fetchAll()
            .filter { calendar.component(.year, from: $0.date) == year }
            .count
        return "R-\(year)-" + String(format: "%04d", count + 1)
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
