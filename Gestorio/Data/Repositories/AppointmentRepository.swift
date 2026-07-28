import Foundation
import SwiftData

@MainActor
protocol AppointmentRepositoryProtocol {
    func fetchAll() throws -> [Appointment]
    func fetch(id: UUID) throws -> Appointment?
    func fetch(clientID: UUID) throws -> [Appointment]
    func create(_ appointment: Appointment) throws -> Appointment
    func update(_ appointment: Appointment) throws -> Appointment
    func delete(id: UUID) throws
}

@MainActor
final class AppointmentRepository: AppointmentRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    convenience init() {
        self.init(modelContext: PersistenceController.shared.container.mainContext)
    }

    func fetchAll() throws -> [Appointment] {
        let descriptor = FetchDescriptor<AppointmentEntity>(sortBy: [SortDescriptor(\.date)])
        return try modelContext.fetch(descriptor).map(\.domain)
    }

    func fetch(id: UUID) throws -> Appointment? {
        try entity(id: id)?.domain
    }

    func fetch(clientID: UUID) throws -> [Appointment] {
        let descriptor = FetchDescriptor<AppointmentEntity>(
            predicate: #Predicate { $0.clientID == clientID },
            sortBy: [SortDescriptor(\.date)]
        )
        return try modelContext.fetch(descriptor).map(\.domain)
    }

    func create(_ appointment: Appointment) throws -> Appointment {
        let entity = AppointmentEntity(appointment: appointment)
        modelContext.insert(entity)
        try modelContext.save()
        return entity.domain
    }

    func update(_ appointment: Appointment) throws -> Appointment {
        guard let entity = try entity(id: appointment.id) else {
            throw RepositoryError.notFound
        }
        entity.update(from: appointment)
        try modelContext.save()
        return entity.domain
    }

    func delete(id: UUID) throws {
        guard let entity = try entity(id: id) else {
            throw RepositoryError.notFound
        }
        modelContext.delete(entity)
        try modelContext.save()
    }

    private func entity(id: UUID) throws -> AppointmentEntity? {
        var descriptor = FetchDescriptor<AppointmentEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}

private extension AppointmentEntity {
    convenience init(appointment: Appointment) {
        self.init(
            id: appointment.id,
            clientID: appointment.clientID,
            date: appointment.date,
            durationMinutes: appointment.durationMinutes,
            service: appointment.service,
            price: appointment.price,
            status: appointment.status,
            invoiceID: appointment.invoiceID,
            notes: appointment.notes
        )
    }

    func update(from appointment: Appointment) {
        clientID = appointment.clientID
        date = appointment.date
        durationMinutes = appointment.durationMinutes
        service = appointment.service
        price = appointment.price
        status = appointment.status
        invoiceID = appointment.invoiceID
        notes = appointment.notes
    }

    var domain: Appointment {
        Appointment(
            id: id,
            clientID: clientID,
            date: date,
            durationMinutes: durationMinutes,
            service: service,
            price: price,
            status: status,
            invoiceID: invoiceID,
            notes: notes
        )
    }
}
