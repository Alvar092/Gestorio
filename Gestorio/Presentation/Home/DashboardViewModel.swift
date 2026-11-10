import Foundation

@MainActor
@Observable
final class DashboardViewModel {
    private let fetchAppointmentsUseCase: FetchAppointmentsUseCaseProtocol
    private let fetchClientsUseCase: FetchClientsUseCaseProtocol
    private let fetchQuarterBalanceUseCase: FetchQuarterBalanceUseCaseProtocol
    private let upcomingLimit = 5

    private(set) var upcomingAppointments: [Appointment] = []
    private(set) var clientsByID: [UUID: Client] = [:]
    private(set) var balance: QuarterBalance?
    var errorMessage: String?

    init(
        fetchAppointmentsUseCase: FetchAppointmentsUseCaseProtocol,
        fetchClientsUseCase: FetchClientsUseCaseProtocol,
        fetchQuarterBalanceUseCase: FetchQuarterBalanceUseCaseProtocol
    ) {
        self.fetchAppointmentsUseCase = fetchAppointmentsUseCase
        self.fetchClientsUseCase = fetchClientsUseCase
        self.fetchQuarterBalanceUseCase = fetchQuarterBalanceUseCase
    }

    convenience init() {
        self.init(
            fetchAppointmentsUseCase: FetchAppointmentsUseCase(),
            fetchClientsUseCase: FetchClientsUseCase(),
            fetchQuarterBalanceUseCase: FetchQuarterBalanceUseCase()
        )
    }

    func load(now: Date = .now) {
        do {
            upcomingAppointments = try fetchAppointmentsUseCase.fetchAppointments()
                .filter { $0.date >= now && $0.status == .pending }
                .sorted { $0.date < $1.date }
                .prefix(upcomingLimit)
                .map { $0 }
            clientsByID = Dictionary(uniqueKeysWithValues: try fetchClientsUseCase.fetchClients().map { ($0.id, $0) })
            balance = try fetchQuarterBalanceUseCase.fetchBalance(for: now)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clientName(for appointment: Appointment) -> String {
        clientsByID[appointment.clientID]?.name ?? "Cliente desconocido"
    }
}
