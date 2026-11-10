import Foundation

/// Datos fiscales del autónomo: emisor de los ingresos y destinatario de los gastos.
struct IssuerProfile: Equatable {
    var name: String
    var taxID: String
}
