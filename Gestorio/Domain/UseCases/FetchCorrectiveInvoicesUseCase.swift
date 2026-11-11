import Foundation

@MainActor
protocol FetchCorrectiveInvoicesUseCaseProtocol {
    func fetchCorrectiveInvoices() throws -> [CorrectiveInvoice]
}

@MainActor
final class FetchCorrectiveInvoicesUseCase: FetchCorrectiveInvoicesUseCaseProtocol {
    private let repository: CorrectiveInvoiceRepositoryProtocol

    init(repository: CorrectiveInvoiceRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: CorrectiveInvoiceRepository())
    }

    func fetchCorrectiveInvoices() throws -> [CorrectiveInvoice] {
        try repository.fetchAll()
    }
}
