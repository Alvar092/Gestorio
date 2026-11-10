import Foundation

/// Formulario para crear un ingreso (factura emitida) o un gasto (factura recibida).
@MainActor
@Observable
final class ActivityEntryFormViewModel {
    static let vatRates: [Decimal] = [21, 10, 4, 0]
    static let irpfRates: [Decimal] = [15, 7, 19, 1]

    let kind: ActivityKind
    private let createInvoiceUseCase: CreateInvoiceUseCaseProtocol
    private let createExpenseUseCase: CreateExpenseUseCaseProtocol
    private let fetchClientsUseCase: FetchClientsUseCaseProtocol
    private let fetchIssuerProfileUseCase: FetchIssuerProfileUseCaseProtocol

    private(set) var profile: IssuerProfile?
    private(set) var clients: [Client] = []
    /// Ingreso: cliente elegido (opcional, rellena nombre y NIF). Gasto: no se usa.
    var clientID: UUID?
    /// Destinatario en un ingreso; emisor (proveedor) en un gasto.
    var counterpartyName = ""
    var counterpartyTaxID = ""
    var date: Date
    var concept = ""
    var baseText = ""
    var vatRate: Decimal = 21
    var hasIRPF = false
    var irpfRate: Decimal = 15
    var errorMessage: String?

    init(
        kind: ActivityKind,
        createInvoiceUseCase: CreateInvoiceUseCaseProtocol,
        createExpenseUseCase: CreateExpenseUseCaseProtocol,
        fetchClientsUseCase: FetchClientsUseCaseProtocol,
        fetchIssuerProfileUseCase: FetchIssuerProfileUseCaseProtocol,
        initialDate: Date
    ) {
        self.kind = kind
        self.createInvoiceUseCase = createInvoiceUseCase
        self.createExpenseUseCase = createExpenseUseCase
        self.fetchClientsUseCase = fetchClientsUseCase
        self.fetchIssuerProfileUseCase = fetchIssuerProfileUseCase
        self.date = initialDate
    }

    convenience init(kind: ActivityKind, initialDate: Date = .now) {
        self.init(
            kind: kind,
            createInvoiceUseCase: CreateInvoiceUseCase(),
            createExpenseUseCase: CreateExpenseUseCase(),
            fetchClientsUseCase: FetchClientsUseCase(),
            fetchIssuerProfileUseCase: FetchIssuerProfileUseCase(),
            initialDate: initialDate
        )
    }

    var title: String { kind.newTitle }

    var base: Decimal? { DecimalInput.parse(baseText) }

    /// Desglose calculado a partir de la base; `nil` si la base está vacía o es inválida.
    var breakdown: TaxBreakdown? {
        guard let base else { return nil }
        return TaxBreakdown(base: base, vatRate: vatRate, irpfRate: hasIRPF ? irpfRate : 0)
    }

    var canSave: Bool {
        profile != nil
            && !trimmed(counterpartyName).isEmpty
            && !trimmed(counterpartyTaxID).isEmpty
            && !trimmed(concept).isEmpty
            && (base ?? 0) > 0
    }

    func sanitizeBaseText() {
        let sanitized = DecimalInput.sanitize(baseText)
        if sanitized != baseText { baseText = sanitized }
    }

    func load() {
        do {
            profile = try fetchIssuerProfileUseCase.fetchProfile()
            if kind == .income {
                clients = try fetchClientsUseCase.fetchClients()
                    .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Copia nombre y NIF del cliente elegido (siguen siendo editables).
    func applySelectedClient() {
        guard let client = clients.first(where: { $0.id == clientID }) else { return }
        counterpartyName = client.name
        counterpartyTaxID = client.taxID
    }

    /// Devuelve `true` si se guardó correctamente.
    func save() -> Bool {
        guard canSave, let profile, let breakdown else { return false }
        let name = trimmed(counterpartyName)
        let taxID = trimmed(counterpartyTaxID)
        do {
            switch kind {
            case .income:
                _ = try createInvoiceUseCase.create(Invoice(
                    number: "",
                    date: date,
                    issuerName: profile.name,
                    issuerTaxID: profile.taxID,
                    clientName: name,
                    clientTaxID: taxID,
                    concept: trimmed(concept),
                    taxBase: breakdown.base,
                    vatRate: breakdown.vatRate,
                    irpfRate: breakdown.irpfRate,
                    totalPrice: breakdown.total
                ))
            case .expense:
                _ = try createExpenseUseCase.createExpense(Expense(
                    date: date,
                    issuerName: name,
                    issuerTaxID: taxID,
                    recipientName: profile.name,
                    recipientTaxID: profile.taxID,
                    concept: trimmed(concept),
                    taxBase: breakdown.base,
                    vatRate: breakdown.vatRate,
                    irpfRate: breakdown.irpfRate,
                    totalPrice: breakdown.total
                ))
            }
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
