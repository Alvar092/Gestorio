import Foundation

final class MockAppointmentRepository: AppointmentRepositoryProtocol {
    var appointments: [Appointment] = []
    var errorToThrow: Error?

    func fetchAll() throws -> [Appointment] {
        if let errorToThrow { throw errorToThrow }
        return appointments
    }

    func fetch(id: UUID) throws -> Appointment? {
        if let errorToThrow { throw errorToThrow }
        return appointments.first { $0.id == id }
    }

    func fetch(clientID: UUID) throws -> [Appointment] {
        if let errorToThrow { throw errorToThrow }
        return appointments.filter { $0.clientID == clientID }
    }

    func create(_ appointment: Appointment) throws -> Appointment {
        if let errorToThrow { throw errorToThrow }
        appointments.append(appointment)
        return appointment
    }

    func update(_ appointment: Appointment) throws -> Appointment {
        if let errorToThrow { throw errorToThrow }
        guard let index = appointments.firstIndex(where: { $0.id == appointment.id }) else {
            throw RepositoryError.notFound
        }
        appointments[index] = appointment
        return appointment
    }

    func delete(id: UUID) throws {
        if let errorToThrow { throw errorToThrow }
        guard let index = appointments.firstIndex(where: { $0.id == id }) else {
            throw RepositoryError.notFound
        }
        appointments.remove(at: index)
    }
}
