import Foundation

/// Factura recibida de un proveedor. No entra en la cadena de hash RRSIF (solo aplica a las emitidas).
struct Expense: Identifiable, Equatable {
    let id: UUID
    var date: Date
    var issuerName: String
    var issuerTaxID: String
    var recipientName: String
    var recipientTaxID: String
    var concept: String
    var taxBase: Decimal
    var vatRate: Decimal
    var irpfRate: Decimal
    var totalPrice: Decimal

    init(
        id: UUID = UUID(),
        date: Date,
        issuerName: String,
        issuerTaxID: String,
        recipientName: String,
        recipientTaxID: String,
        concept: String,
        taxBase: Decimal,
        vatRate: Decimal,
        irpfRate: Decimal,
        totalPrice: Decimal
    ) {
        self.id = id
        self.date = date
        self.issuerName = issuerName
        self.issuerTaxID = issuerTaxID
        self.recipientName = recipientName
        self.recipientTaxID = recipientTaxID
        self.concept = concept
        self.taxBase = taxBase
        self.vatRate = vatRate
        self.irpfRate = irpfRate
        self.totalPrice = totalPrice
    }
}
