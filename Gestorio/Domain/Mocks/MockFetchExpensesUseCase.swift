import Foundation

final class MockFetchExpensesUseCase: FetchExpensesUseCaseProtocol {
    var expensesToReturn: [Expense] = []
    var errorToThrow: Error?

    func fetchExpenses() throws -> [Expense] {
        if let errorToThrow { throw errorToThrow }
        return expensesToReturn
    }
}
