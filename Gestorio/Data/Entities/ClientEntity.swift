import Foundation
import SwiftData

@Model
final class ClientEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var taxID: String
    var street: String
    var postalCode: String
    var city: String
    var province: String
    var email: String?
    var phone: String?
    var notes: String?

    init(
        id: UUID,
        name: String,
        taxID: String,
        street: String,
        postalCode: String,
        city: String,
        province: String,
        email: String?,
        phone: String?,
        notes: String?
    ) {
        self.id = id
        self.name = name
        self.taxID = taxID
        self.street = street
        self.postalCode = postalCode
        self.city = city
        self.province = province
        self.email = email
        self.phone = phone
        self.notes = notes
    }
}
