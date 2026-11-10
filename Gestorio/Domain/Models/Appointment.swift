import Foundation

enum AppointmentStatus: String, Codable, CaseIterable {
    case pending
    case completed
    case invoiced
    case cancelled
}

/// Motivo de una cancelación; determina si la cita se cobra.
enum CancellationKind: String, Codable, CaseIterable {
    /// Cancelación justificada: no se cobra.
    case justified
    /// Cancelación sin justificar: se cobra.
    case unjustified
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
    /// Solo tiene valor cuando `status == .cancelled`.
    var cancellationKind: CancellationKind?

    init(
        id: UUID = UUID(),
        clientID: UUID,
        date: Date,
        durationMinutes: Int,
        service: String,
        price: Decimal,
        status: AppointmentStatus = .pending,
        invoiceID: UUID? = nil,
        notes: String? = nil,
        cancellationKind: CancellationKind? = nil
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
        self.cancellationKind = cancellationKind
    }

    /// Cita cancelada sin justificar: se cobra como si se hubiera realizado.
    var isChargeableCancellation: Bool {
        status == .cancelled && cancellationKind == .unjustified
    }
}
