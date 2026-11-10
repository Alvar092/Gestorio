import Foundation
import SwiftData

/// Perfil fiscal del autónomo. Siempre una sola fila.
@Model
final class IssuerProfileEntity {
    @Attribute(.unique) var id: String
    var name: String
    var taxID: String

    init(id: String = IssuerProfileEntity.singletonID, name: String, taxID: String) {
        self.id = id
        self.name = name
        self.taxID = taxID
    }

    static let singletonID = "issuerProfile"
}
