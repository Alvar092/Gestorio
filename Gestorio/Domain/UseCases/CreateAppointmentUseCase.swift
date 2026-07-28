import Foundation

@MainActor
protocol CreateAppointmentUseCaseProtocol {
    func createAppointment(_ appointment: Appointment) throws -> Appointment
}

@MainActor
final class CreateAppointmentUseCase: CreateAppointmentUseCaseProtocol {
    private let repository: AppointmentRepositoryProtocol

    init(repository: AppointmentRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: AppointmentRepository())
    }

    func createAppointment(_ appointment: Appointment) throws -> Appointment {
        try repository.create(appointment)
    }
}
