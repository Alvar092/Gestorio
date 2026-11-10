import Foundation

@MainActor
@Observable
final class AppointmentFormViewModel {
    private let createAppointmentUseCase: CreateAppointmentUseCaseProtocol
    private let updateAppointmentUseCase: UpdateAppointmentUseCaseProtocol
    private let fetchClientsUseCase: FetchClientsUseCaseProtocol
    private let editingAppointment: Appointment?

    private(set) var clients: [Client] = []
    private(set) var didLoadClients = false
    var clientID: UUID?
    var date: Date
    var durationMinutes: Int
    var service: String
    var priceText: String
    var notes: String
    var errorMessage: String?

    init(
        appointment: Appointment?,
        createAppointmentUseCase: CreateAppointmentUseCaseProtocol,
        updateAppointmentUseCase: UpdateAppointmentUseCaseProtocol,
        fetchClientsUseCase: FetchClientsUseCaseProtocol,
        initialDate: Date
    ) {
        self.editingAppointment = appointment
        self.createAppointmentUseCase = createAppointmentUseCase
        self.updateAppointmentUseCase = updateAppointmentUseCase
        self.fetchClientsUseCase = fetchClientsUseCase
        self.clientID = appointment?.clientID
        self.date = appointment?.date ?? initialDate
        self.durationMinutes = appointment?.durationMinutes ?? 60
        self.service = appointment?.service ?? ""
        self.priceText = appointment.map {
            $0.price.formatted(.number.precision(.fractionLength(0...2)).grouping(.never))
        } ?? ""
        self.notes = appointment?.notes ?? ""
    }

    convenience init(appointment: Appointment? = nil, initialDate: Date = .now) {
        self.init(
            appointment: appointment,
            createAppointmentUseCase: CreateAppointmentUseCase(),
            updateAppointmentUseCase: UpdateAppointmentUseCase(),
            fetchClientsUseCase: FetchClientsUseCase(),
            initialDate: initialDate
        )
    }

    var isEditing: Bool { editingAppointment != nil }

    var title: String { isEditing ? "Editar evento" : "Nuevo evento" }

    var canSave: Bool {
        clientID != nil
            && !service.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && price != nil
    }

    /// Importe parseado con el separador decimal del dispositivo; `nil` si está vacío o es inválido.
    var price: Decimal? {
        let text = priceText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return nil }
        return Decimal(string: text, locale: .current)
    }

    /// Deja en `priceText` solo dígitos y un separador decimal, con un máximo de 2 decimales.
    func sanitizePriceText() {
        let separator = Locale.current.decimalSeparator ?? ","
        var result = ""
        var hasSeparator = false
        var decimals = 0
        for character in priceText {
            if character.isASCII, character.isNumber {
                if hasSeparator {
                    guard decimals < 2 else { continue }
                    decimals += 1
                }
                result.append(character)
            } else if String(character) == separator || character == "," || character == ".", !hasSeparator {
                hasSeparator = true
                result.append(contentsOf: separator)
            }
        }
        if result != priceText { priceText = result }
    }

    func loadClients() {
        do {
            clients = try fetchClientsUseCase.fetchClients()
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            didLoadClients = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Devuelve `true` si se guardó correctamente.
    func save() -> Bool {
        guard canSave, let clientID, let price else { return false }
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let appointment = Appointment(
            id: editingAppointment?.id ?? UUID(),
            clientID: clientID,
            date: date,
            durationMinutes: durationMinutes,
            service: service.trimmingCharacters(in: .whitespacesAndNewlines),
            price: price,
            status: editingAppointment?.status ?? .pending,
            invoiceID: editingAppointment?.invoiceID,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes
        )
        do {
            if isEditing {
                _ = try updateAppointmentUseCase.updateAppointment(appointment)
            } else {
                _ = try createAppointmentUseCase.createAppointment(appointment)
            }
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
