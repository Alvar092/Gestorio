import Foundation

@MainActor
protocol DeleteAppointmentUseCaseProtocol {
    func deleteAppointment(id: UUID) throws
}

@MainActor
final class DeleteAppointmentUseCase: DeleteAppointmentUseCaseProtocol {
    private let repository: AppointmentRepositoryProtocol

    init(repository: AppointmentRepositoryProtocol) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: AppointmentRepository())
    }

    func deleteAppointment(id: UUID) throws {
        try repository.delete(id: id)
    }
}
