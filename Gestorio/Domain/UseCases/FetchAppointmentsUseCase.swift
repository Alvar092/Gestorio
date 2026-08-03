import Foundation

@MainActor
protocol FetchAppointmentsUseCaseProtocol {
    func fetchAppointments() throws -> [Appointment]
}

@MainActor
final class FetchAppointmentsUseCase: FetchAppointmentsUseCaseProtocol {
    private let repository: AppointmentRepositoryProtocol

    init(repository: AppointmentRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: AppointmentRepository())
    }

    func fetchAppointments() throws -> [Appointment] {
        try repository.fetchAll()
    }
}
