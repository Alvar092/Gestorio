import Foundation
import SwiftData

@Model
final class InvoiceEntity {
    @Attribute(.unique) var id: UUID
    var number: String
    var date: Date
    var clientName: String
    var clientTaxID: String
    var concept: String
    var totalPrice: Decimal

    init(
        id: UUID,
        number: String,
        date: Date,
        clientName: String,
        clientTaxID: String,
        concept: String,
        totalPrice: Decimal
    ) {
        self.id = id
        self.number = number
        self.date = date
        self.clientName = clientName
        self.clientTaxID = clientTaxID
        self.concept = concept
        self.totalPrice = totalPrice
    }
}
