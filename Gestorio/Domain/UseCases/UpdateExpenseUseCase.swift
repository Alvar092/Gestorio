import Foundation

@MainActor
protocol UpdateExpenseUseCaseProtocol {
    func updateExpense(_ expense: Expense) throws -> Expense
}

@MainActor
final class UpdateExpenseUseCase: UpdateExpenseUseCaseProtocol {
    private let repository: ExpenseRepositoryProtocol

    init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: ExpenseRepository())
    }

    func updateExpense(_ expense: Expense) throws -> Expense {
        try repository.update(expense)
    }
}
