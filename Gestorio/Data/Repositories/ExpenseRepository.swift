import Foundation
import SwiftData

@MainActor
protocol ExpenseRepositoryProtocol {
    func fetchAll() throws -> [Expense]
    func create(_ expense: Expense) throws -> Expense
    func update(_ expense: Expense) throws -> Expense
}

@MainActor
final class ExpenseRepository: ExpenseRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    convenience init() {
        self.init(modelContext: PersistenceController.shared.container.mainContext)
    }

    func fetchAll() throws -> [Expense] {
        let descriptor = FetchDescriptor<ExpenseEntity>(sortBy: [SortDescriptor(\.date)])
        return try modelContext.fetch(descriptor).map(\.domain)
    }

    func create(_ expense: Expense) throws -> Expense {
        let entity = ExpenseEntity(expense: expense)
        modelContext.insert(entity)
        try modelContext.save()
        return entity.domain
    }

    func update(_ expense: Expense) throws -> Expense {
        let id = expense.id
        var descriptor = FetchDescriptor<ExpenseEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let entity = try modelContext.fetch(descriptor).first else {
            throw RepositoryError.notFound
        }
        entity.update(from: expense)
        try modelContext.save()
        return entity.domain
    }
}

private extension ExpenseEntity {
    func update(from expense: Expense) {
        date = expense.date
        issuerName = expense.issuerName
        issuerTaxID = expense.issuerTaxID
        recipientName = expense.recipientName
        recipientTaxID = expense.recipientTaxID
        concept = expense.concept
        taxBase = expense.taxBase
        vatRate = expense.vatRate
        irpfRate = expense.irpfRate
        totalPrice = expense.totalPrice
    }

    convenience init(expense: Expense) {
        self.init(
            id: expense.id,
            date: expense.date,
            issuerName: expense.issuerName,
            issuerTaxID: expense.issuerTaxID,
            recipientName: expense.recipientName,
            recipientTaxID: expense.recipientTaxID,
            concept: expense.concept,
            taxBase: expense.taxBase,
            vatRate: expense.vatRate,
            irpfRate: expense.irpfRate,
            totalPrice: expense.totalPrice
        )
    }

    var domain: Expense {
        Expense(
            id: id,
            date: date,
            issuerName: issuerName,
            issuerTaxID: issuerTaxID,
            recipientName: recipientName,
            recipientTaxID: recipientTaxID,
            concept: concept,
            taxBase: taxBase,
            vatRate: vatRate,
            irpfRate: irpfRate,
            totalPrice: totalPrice
        )
    }
}
