import Foundation

@MainActor
protocol CreateExpenseUseCaseProtocol {
    func createExpense(_ expense: Expense) throws -> Expense
}

@MainActor
final class CreateExpenseUseCase: CreateExpenseUseCaseProtocol {
    private let repository: ExpenseRepositoryProtocol

    init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: ExpenseRepository())
    }

    func createExpense(_ expense: Expense) throws -> Expense {
        try repository.create(expense)
    }
}
