import Foundation
import SwiftData

@Model
final class InvoiceEntity {
    @Attribute(.unique) var id: UUID
    var number: String
    var date: Date
    // Valores por defecto: permiten la migración ligera de facturas anteriores a estos campos.
    var issuerName: String = ""
    var issuerTaxID: String = ""
    var clientName: String
    var clientTaxID: String
    var concept: String
    var taxBase: Decimal = 0
    var vatRate: Decimal = 0
    var irpfRate: Decimal = 0
    var totalPrice: Decimal
    var previousHash: String
    var recordHash: String

    init(
        id: UUID,
        number: String,
        date: Date,
        issuerName: String,
        issuerTaxID: String,
        clientName: String,
        clientTaxID: String,
        concept: String,
        taxBase: Decimal,
        vatRate: Decimal,
        irpfRate: Decimal,
        totalPrice: Decimal,
        previousHash: String,
        recordHash: String
    ) {
        self.id = id
        self.number = number
        self.date = date
        self.issuerName = issuerName
        self.issuerTaxID = issuerTaxID
        self.clientName = clientName
        self.clientTaxID = clientTaxID
        self.concept = concept
        self.taxBase = taxBase
        self.vatRate = vatRate
        self.irpfRate = irpfRate
        self.totalPrice = totalPrice
        self.previousHash = previousHash
        self.recordHash = recordHash
    }
}
