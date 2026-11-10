import Foundation

@MainActor
@Observable
final class ActivityViewModel {
    private let fetchInvoicesUseCase: FetchInvoicesUseCaseProtocol
    private let fetchExpensesUseCase: FetchExpensesUseCaseProtocol

    var selectedKind: ActivityKind = .income
    private(set) var invoices: [Invoice] = []
    private(set) var expenses: [Expense] = []
    var errorMessage: String?

    init(
        fetchInvoicesUseCase: FetchInvoicesUseCaseProtocol,
        fetchExpensesUseCase: FetchExpensesUseCaseProtocol
    ) {
        self.fetchInvoicesUseCase = fetchInvoicesUseCase
        self.fetchExpensesUseCase = fetchExpensesUseCase
    }

    convenience init() {
        self.init(
            fetchInvoicesUseCase: FetchInvoicesUseCase(),
            fetchExpensesUseCase: FetchExpensesUseCase()
        )
    }

    /// Más recientes primero.
    func load() {
        do {
            invoices = try fetchInvoicesUseCase.fetchInvoices().sorted { $0.date > $1.date }
            expenses = try fetchExpensesUseCase.fetchExpenses().sorted { $0.date > $1.date }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
