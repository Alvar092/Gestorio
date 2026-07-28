import Foundation

@MainActor
protocol UpdateAppointmentUseCaseProtocol {
    func updateAppointment(_ appointment: Appointment) throws -> Appointment
}

@MainActor
final class UpdateAppointmentUseCase: UpdateAppointmentUseCaseProtocol {
    private let repository: AppointmentRepositoryProtocol

    init(repository: AppointmentRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: AppointmentRepository())
    }

    func updateAppointment(_ appointment: Appointment) throws -> Appointment {
        try repository.update(appointment)
    }
}
