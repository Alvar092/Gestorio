import Foundation

enum AppointmentStatus: String, Codable, CaseIterable {
    case pending
    case completed
    case invoiced
    case cancelled
}

struct Appointment: Identifiable, Hashable {
    let id: UUID
    var clientID: UUID
    var date: Date
    var durationMinutes: Int
    var service: String
    var price: Decimal
    var status: AppointmentStatus
    var invoiceID: UUID?
    var notes: String?

    init(
        id: UUID = UUID(),
        clientID: UUID,
        date: Date,
        durationMinutes: Int,
        service: String,
        price: Decimal,
        status: AppointmentStatus = .pending,
        invoiceID: UUID? = nil,
        notes: String? = nil
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
