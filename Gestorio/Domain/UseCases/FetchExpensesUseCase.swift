import Foundation

@MainActor
protocol FetchExpensesUseCaseProtocol {
    func fetchExpenses() throws -> [Expense]
}

@MainActor
final class FetchExpensesUseCase: FetchExpensesUseCaseProtocol {
    private let repository: ExpenseRepositoryProtocol

    init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: ExpenseRepository())
    }

    func fetchExpenses() throws -> [Expense] {
        try repository.fetchAll()
    }
}
