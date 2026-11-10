import Foundation

final class MockExpenseRepository: ExpenseRepositoryProtocol {
    var expenses: [Expense] = []
    var errorToThrow: Error?

    func fetchAll() throws -> [Expense] {
        if let errorToThrow { throw errorToThrow }
        return expenses
    }

    func create(_ expense: Expense) throws -> Expense {
        if let errorToThrow { throw errorToThrow }
        expenses.append(expense)
        return expense
    }
}
