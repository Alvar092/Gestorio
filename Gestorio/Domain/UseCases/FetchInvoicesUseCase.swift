import Foundation

@MainActor
protocol FetchInvoicesUseCaseProtocol {
    func fetchInvoices() throws -> [Invoice]
}

@MainActor
final class FetchInvoicesUseCase: FetchInvoicesUseCaseProtocol {
    private let repository: InvoiceRepositoryProtocol

    init(repository: InvoiceRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: InvoiceRepository())
    }

    func fetchInvoices() throws -> [Invoice] {
        try repository.fetchAll()
    }
}
