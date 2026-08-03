import Foundation

final class MockFetchAppointmentsUseCase: FetchAppointmentsUseCaseProtocol {
    var appointmentsToReturn: [Appointment] = []
    var errorToThrow: Error?

    func fetchAppointments() throws -> [Appointment] {
        if let errorToThrow { throw errorToThrow }
        return appointmentsToReturn
    }
}
