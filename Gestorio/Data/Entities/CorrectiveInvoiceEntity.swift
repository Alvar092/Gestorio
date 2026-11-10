import Foundation
import SwiftData

@Model
final class CorrectiveInvoiceEntity {
    @Attribute(.unique) var id: UUID
    var number: String
    var date: Date
    var clientName: String
    var clientTaxID: String
    var concept: String
    var totalPrice: Decimal
    var originalInvoiceNumber: String
    var originalInvoiceHash: String
    var previousHash: String
    var recordHash: String

    init(
        id: UUID,
        number: String,
        date: Date,
        clientName: String,
        clientTaxID: String,
        concept: String,
        totalPrice: Decimal,
        originalInvoiceNumber: String,
        originalInvoiceHash: String,
        previousHash: String,
        recordHash: String
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
        self.recordHash = recordHash
    }
}
