import Foundation

/// Factura emitida (ingreso). `clientName`/`clientTaxID` son el destinatario.
struct Invoice: Identifiable, Equatable {
    let id: UUID
    var number: String
    var date: Date
    var issuerName: String
    var issuerTaxID: String
    var clientName: String
    var clientTaxID: String
    var concept: String
    var taxBase: Decimal
    var vatRate: Decimal
    var irpfRate: Decimal
    var totalPrice: Decimal
    var previousHash: String
    var hash: String

    /// Si `taxBase` es `nil` se asume sin impuestos (base = `totalPrice`).
    init(
        id: UUID = UUID(),
        number: String,
        date: Date,
        issuerName: String = "",
        issuerTaxID: String = "",
        clientName: String,
        clientTaxID: String,
        concept: String,
        taxBase: Decimal? = nil,
        vatRate: Decimal = 0,
        irpfRate: Decimal = 0,
        totalPrice: Decimal,
        previousHash: String = "",
        hash: String = ""
    ) {
        self.id = id
        self.number = number
        self.date = date
        self.issuerName = issuerName
        self.issuerTaxID = issuerTaxID
        self.clientName = clientName
        self.clientTaxID = clientTaxID
        self.concept = concept
        self.taxBase = taxBase ?? totalPrice
        self.vatRate = vatRate
        self.irpfRate = irpfRate
        self.totalPrice = totalPrice
        self.previousHash = previousHash
        self.hash = hash
    }
}
