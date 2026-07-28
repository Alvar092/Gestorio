import Foundation

struct BillingAddress: Codable, Equatable {
    var street: String
    var postalCode: String
    var city: String
    var province: String
}

struct Client: Identifiable, Equatable {
    let id: UUID
    var name: String
    var taxID: String
    var billingAddress: BillingAddress
    var email: String?
    var phone: String?
    var notes: String?

    init(
        id: UUID = UUID(),
        name: String,
        taxID: String,
        billingAddress: BillingAddress,
        email: String? = nil,
        phone: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.taxID = taxID
        self.billingAddress = billingAddress
        self.email = email
        self.phone = phone
        self.notes = notes
    }
}
