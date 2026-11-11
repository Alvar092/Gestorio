import Foundation

final class MockUpdateExpenseUseCase: UpdateExpenseUseCaseProtocol {
    private(set) var updatedExpenses: [Expense] = []
    var errorToThrow: Error?

    func updateExpense(_ expense: Expense) throws -> Expense {
        if let errorToThrow { throw errorToThrow }
        updatedExpenses.append(expense)
        return expense
    }
}
