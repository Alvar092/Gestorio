import Foundation

/// Tipo de movimiento de la pestaña Actividad.
enum ActivityKind: String, CaseIterable, Identifiable {
    case income
    case expense

    var id: String { rawValue }

    var title: String {
        switch self {
        case .income: "Ingresos"
        case .expense: "Gastos"
        }
    }

    var newTitle: String {
        switch self {
        case .income: "Nuevo ingreso"
        case .expense: "Nuevo gasto"
        }
    }
}
