import Foundation

final class MockCreateAppointmentUseCase: CreateAppointmentUseCaseProtocol {
    private(set) var createdAppointments: [Appointment] = []
    var errorToThrow: Error?

    func createAppointment(_ appointment: Appointment) throws -> Appointment {
        if let errorToThrow { throw errorToThrow }
        createdAppointments.append(appointment)
        return appointment
    }
}
