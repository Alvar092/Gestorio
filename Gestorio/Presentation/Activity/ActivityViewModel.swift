import Foundation

@MainActor
@Observable
final class ActivityViewModel {
    private let fetchInvoicesUseCase: FetchInvoicesUseCaseProtocol
    private let fetchExpensesUseCase: FetchExpensesUseCaseProtocol
    private let fetchCorrectiveInvoicesUseCase: FetchCorrectiveInvoicesUseCaseProtocol

    var selectedKind: ActivityKind = .income
    private(set) var invoices: [Invoice] = []
    private(set) var expenses: [Expense] = []
    private(set) var correctiveInvoices: [CorrectiveInvoice] = []
    var errorMessage: String?

    init(
        fetchInvoicesUseCase: FetchInvoicesUseCaseProtocol,
        fetchExpensesUseCase: FetchExpensesUseCaseProtocol,
        fetchCorrectiveInvoicesUseCase: FetchCorrectiveInvoicesUseCaseProtocol
    ) {
        self.fetchInvoicesUseCase = fetchInvoicesUseCase
        self.fetchExpensesUseCase = fetchExpensesUseCase
        self.fetchCorrectiveInvoicesUseCase = fetchCorrectiveInvoicesUseCase
    }

    convenience init() {
        self.init(
            fetchInvoicesUseCase: FetchInvoicesUseCase(),
            fetchExpensesUseCase: FetchExpensesUseCase(),
            fetchCorrectiveInvoicesUseCase: FetchCorrectiveInvoicesUseCase()
        )
    }

    /// Más recientes primero.
    func load() {
        do {
            invoices = try fetchInvoicesUseCase.fetchInvoices().sorted { $0.date > $1.date }
            expenses = try fetchExpensesUseCase.fetchExpenses().sorted { $0.date > $1.date }
            correctiveInvoices = try fetchCorrectiveInvoicesUseCase.fetchCorrectiveInvoices().sorted { $0.date > $1.date }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func invoice(id: UUID) -> Invoice? {
        invoices.first { $0.id == id }
    }

    func expense(id: UUID) -> Expense? {
        expenses.first { $0.id == id }
    }

    /// Rectificativas que referencian a la factura por número y hash.
    func correctiveInvoices(for invoice: Invoice) -> [CorrectiveInvoice] {
        correctiveInvoices.filter {
            $0.originalInvoiceNumber == invoice.number && $0.originalInvoiceHash == invoice.hash
        }
    }
}
