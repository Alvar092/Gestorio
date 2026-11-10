import Foundation

final class MockDeleteAppointmentUseCase: DeleteAppointmentUseCaseProtocol {
    private(set) var deletedIDs: [UUID] = []
    var errorToThrow: Error?

    func deleteAppointment(id: UUID) throws {
        if let errorToThrow { throw errorToThrow }
        deletedIDs.append(id)
    }
}
