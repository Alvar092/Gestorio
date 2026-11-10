import Foundation

final class MockCreateExpenseUseCase: CreateExpenseUseCaseProtocol {
    private(set) var createdExpenses: [Expense] = []
    var errorToThrow: Error?

    func createExpense(_ expense: Expense) throws -> Expense {
        if let errorToThrow { throw errorToThrow }
        createdExpenses.append(expense)
        return expense
    }
}
