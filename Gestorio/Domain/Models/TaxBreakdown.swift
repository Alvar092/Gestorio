import Foundation

/// Desglose de una factura: base imponible, IVA repercutido y retención de IRPF.
/// Los porcentajes se expresan como número entero o decimal (21 = 21 %).
struct TaxBreakdown: Equatable {
    let base: Decimal
    let vatRate: Decimal
    let irpfRate: Decimal

    var vatAmount: Decimal { Self.percentage(of: base, rate: vatRate) }
    var irpfAmount: Decimal { Self.percentage(of: base, rate: irpfRate) }
    /// Base + IVA − retención de IRPF.
    var total: Decimal { base + vatAmount - irpfAmount }

    private static func percentage(of base: Decimal, rate: Decimal) -> Decimal {
        var value = base * rate / 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 2, .plain)
        return rounded
    }
}
