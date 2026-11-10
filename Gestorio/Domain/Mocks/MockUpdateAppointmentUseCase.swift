import Foundation

final class MockUpdateAppointmentUseCase: UpdateAppointmentUseCaseProtocol {
    private(set) var updatedAppointments: [Appointment] = []
    var errorToThrow: Error?

    func updateAppointment(_ appointment: Appointment) throws -> Appointment {
        if let errorToThrow { throw errorToThrow }
        updatedAppointments.append(appointment)
        return appointment
    }
}
