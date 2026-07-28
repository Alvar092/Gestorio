import Foundation
import SwiftData

@Model
final class AppointmentEntity {
    @Attribute(.unique) var id: UUID
    var clientID: UUID
    var date: Date
    var durationMinutes: Int
    var service: String
    var price: Decimal
    var status: AppointmentStatus
    var invoiceID: UUID?
    var notes: String?

    init(
        id: UUID,
        clientID: UUID,
        date: Date,
        durationMinutes: Int,
        service: String,
        price: Decimal,
        status: AppointmentStatus,
        invoiceID: UUID?,
        notes: String?
    ) {
        self.id = id
        self.clientID = clientID
        self.date = date
        self.durationMinutes = durationMinutes
        self.service = service
        self.price = price
        self.status = status
        self.invoiceID = invoiceID
        self.notes = notes
    }
}
