import Foundation

@MainActor
@Observable
final class AppointmentFormViewModel {
    private let createAppointmentUseCase: CreateAppointmentUseCaseProtocol
    private let fetchClientsUseCase: FetchClientsUseCaseProtocol

    private(set) var clients: [Client] = []
    var clientID: UUID?
    var date: Date
    var durationMinutes = 60
    var service = ""
    var priceText = ""
    var notes = ""
    var errorMessage: String?

    init(
        createAppointmentUseCase: CreateAppointmentUseCaseProtocol,
        fetchClientsUseCase: FetchClientsUseCaseProtocol,
        initialDate: Date
    ) {
        self.createAppointmentUseCase = createAppointmentUseCase
        self.fetchClientsUseCase = fetchClientsUseCase
        self.date = initialDate
    }

    convenience init(initialDate: Date = .now) {
        self.init(
            createAppointmentUseCase: CreateAppointmentUseCase(),
            fetchClientsUseCase: FetchClientsUseCase(),
            initialDate: initialDate
        )
    }

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
            clientID: clientID,
            date: date,
            durationMinutes: durationMinutes,
            service: service.trimmingCharacters(in: .whitespacesAndNewlines),
            price: price,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes
        )
        do {
            _ = try createAppointmentUseCase.createAppointment(appointment)
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
