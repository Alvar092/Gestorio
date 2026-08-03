import Foundation

struct CorrectiveInvoice: Identifiable, Equatable {
    let id: UUID
    var number: String
    var date: Date
    var clientName: String
    var clientTaxID: String
    var concept: String
    var totalPrice: Decimal
    var originalInvoiceNumber: String
    var originalInvoiceHash: String
    var previousHash: String
    var hash: String

    init(
        id: UUID = UUID(),
        number: String,
        date: Date,
        clientName: String,
        clientTaxID: String,
        concept: String,
        totalPrice: Decimal,
        originalInvoiceNumber: String,
        originalInvoiceHash: String,
        previousHash: String = "",
        hash: String = ""
    ) {
        self.id = id
        self.number = number
        self.date = date
        self.clientName = clientName
        self.clientTaxID = clientTaxID
        self.concept = concept
        self.totalPrice = totalPrice
        self.originalInvoiceNumber = originalInvoiceNumber
        self.originalInvoiceHash = originalInvoiceHash
        self.previousHash = previousHash
        self.hash = hash
    }
}
