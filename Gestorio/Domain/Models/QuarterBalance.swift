import Foundation

struct QuarterBalance: Equatable {
    let year: Int
    let quarter: Int
    let interval: DateInterval
    /// Facturas emitidas menos rectificativas dentro del trimestre.
    let invoiced: Decimal
    /// Citas completadas del trimestre que aún no tienen factura.
    let pendingToInvoice: Decimal
}
