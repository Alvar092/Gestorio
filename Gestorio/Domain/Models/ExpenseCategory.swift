import Foundation

/// Categoría fiscal de un gasto. Base para aplicar después reglas de deducibilidad (modelo 130).
/// El `rawValue` es lo que se persiste: no renombrar casos sin migrar los datos.
enum ExpenseCategory: String, CaseIterable, Identifiable, Equatable {
    case rent
    case utilities
    case vehicle
    case supplies
    case software
    case training
    case marketing
    case insurance
    case professionalServices
    case socialSecurity
    case travelAndMeals
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rent: "Alquiler"
        case .utilities: "Suministros"
        case .vehicle: "Vehículo"
        case .supplies: "Material y equipamiento"
        case .software: "Software y suscripciones"
        case .training: "Formación"
        case .marketing: "Marketing y publicidad"
        case .insurance: "Seguros"
        case .professionalServices: "Asesoría y servicios profesionales"
        case .socialSecurity: "Cuota de autónomos"
        case .travelAndMeals: "Dietas y viajes"
        case .other: "Otros"
        }
    }
}
