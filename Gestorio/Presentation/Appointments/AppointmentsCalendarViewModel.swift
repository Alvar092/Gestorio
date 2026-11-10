import Foundation

@MainActor
@Observable
final class AppointmentsCalendarViewModel {
    private let fetchAppointmentsUseCase: FetchAppointmentsUseCaseProtocol
    private let fetchClientsUseCase: FetchClientsUseCaseProtocol
    private let calendar = Calendar.current
    private let upcomingLimit = 5

    var displayedMonth: Date
    private(set) var appointments: [Appointment] = []
    private(set) var clientsByID: [UUID: Client] = [:]
    var errorMessage: String?

    init(
        fetchAppointmentsUseCase: FetchAppointmentsUseCaseProtocol,
        fetchClientsUseCase: FetchClientsUseCaseProtocol,
        referenceDate: Date = .now
    ) {
        self.fetchAppointmentsUseCase = fetchAppointmentsUseCase
        self.fetchClientsUseCase = fetchClientsUseCase
        self.displayedMonth = referenceDate
    }

    convenience init() {
        self.init(
            fetchAppointmentsUseCase: FetchAppointmentsUseCase(),
            fetchClientsUseCase: FetchClientsUseCase()
        )
    }

    func load() {
        do {
            appointments = try fetchAppointmentsUseCase.fetchAppointments()
            clientsByID = Dictionary(uniqueKeysWithValues: try fetchClientsUseCase.fetchClients().map { ($0.id, $0) })
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var datesWithAppointments: Set<Date> {
        Set(appointments.map { calendar.startOfDay(for: $0.date) })
    }

    func upcomingAppointments(from now: Date = .now) -> [Appointment] {
        appointments
            .filter { $0.date >= now && $0.status == .pending }
            .sorted { $0.date < $1.date }
            .prefix(upcomingLimit)
            .map { $0 }
    }

    func appointments(on date: Date) -> [Appointment] {
        appointments
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date < $1.date }
    }

    func clientName(for appointment: Appointment) -> String {
        clientsByID[appointment.clientID]?.name ?? "Cliente desconocido"
    }
}
