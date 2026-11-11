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

    func update(_ expense: Expense) throws -> Expense {
        if let errorToThrow { throw errorToThrow }
        guard let index = expenses.firstIndex(where: { $0.id == expense.id }) else {
            throw RepositoryError.notFound
        }
        expenses[index] = expense
        return expense
    }
}
