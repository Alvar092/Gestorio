import Foundation

/// Formulario para crear un ingreso (factura emitida) o un gasto (factura recibida),
/// o para editar un gasto existente (las facturas emitidas no se editan: se rectifican).
@MainActor
@Observable
final class ActivityEntryFormViewModel {
    static let vatRates: [Decimal] = [21, 10, 4, 0]
    static let irpfRates: [Decimal] = [15, 7, 19, 1]

    /// Qué importe teclea el usuario: la base imponible o el total ya con impuestos.
    enum AmountInput: String, CaseIterable, Identifiable {
        case base
        case total

        var id: String { rawValue }

        var title: String {
            switch self {
            case .base: "Base imponible"
            case .total: "Total"
            }
        }
    }

    let kind: ActivityKind
    private let createInvoiceUseCase: CreateInvoiceUseCaseProtocol
    private let createExpenseUseCase: CreateExpenseUseCaseProtocol
    private let updateExpenseUseCase: UpdateExpenseUseCaseProtocol
    /// Gasto que se está editando; `nil` al crear.
    private let editingExpense: Expense?
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
    /// Importe tecleado; se interpreta como base o como total según `amountInput`.
    var baseText = ""
    var amountInput: AmountInput = .base
    var vatRate: Decimal = 21
    var hasIRPF = false
    var irpfRate: Decimal = 15
    var errorMessage: String?

    init(
        kind: ActivityKind,
        createInvoiceUseCase: CreateInvoiceUseCaseProtocol,
        createExpenseUseCase: CreateExpenseUseCaseProtocol,
        updateExpenseUseCase: UpdateExpenseUseCaseProtocol,
        fetchClientsUseCase: FetchClientsUseCaseProtocol,
        fetchIssuerProfileUseCase: FetchIssuerProfileUseCaseProtocol,
        initialDate: Date,
        editing expense: Expense? = nil
    ) {
        self.kind = kind
        self.createInvoiceUseCase = createInvoiceUseCase
        self.createExpenseUseCase = createExpenseUseCase
        self.updateExpenseUseCase = updateExpenseUseCase
        self.editingExpense = expense
        self.fetchClientsUseCase = fetchClientsUseCase
        self.fetchIssuerProfileUseCase = fetchIssuerProfileUseCase
        self.date = initialDate

        if let expense {
            counterpartyName = expense.issuerName
            counterpartyTaxID = expense.issuerTaxID
            date = expense.date
            concept = expense.concept
            baseText = expense.taxBase.formatted(.number.grouping(.never).precision(.fractionLength(0...2)))
            vatRate = expense.vatRate
            hasIRPF = expense.irpfRate > 0
            if expense.irpfRate > 0 { irpfRate = expense.irpfRate }
        }
    }

    convenience init(kind: ActivityKind, initialDate: Date = .now, editing expense: Expense? = nil) {
        self.init(
            kind: kind,
            createInvoiceUseCase: CreateInvoiceUseCase(),
            createExpenseUseCase: CreateExpenseUseCase(),
            updateExpenseUseCase: UpdateExpenseUseCase(),
            fetchClientsUseCase: FetchClientsUseCase(),
            fetchIssuerProfileUseCase: FetchIssuerProfileUseCase(),
            initialDate: initialDate,
            editing: expense
        )
    }

    var isEditing: Bool { editingExpense != nil }

    var title: String { isEditing ? "Editar gasto" : kind.newTitle }

    /// Solo los gastos permiten teclear el total (el ticket de compra); las facturas emitidas parten de la base.
    var allowsTotalInput: Bool { kind == .expense }

    private var effectiveAmountInput: AmountInput { allowsTotalInput ? amountInput : .base }

    var base: Decimal? {
        guard let entered = DecimalInput.parse(baseText) else { return nil }
        switch effectiveAmountInput {
        case .base: return entered
        case .total: return Self.base(fromTotal: entered, vatRate: vatRate, irpfRate: hasIRPF ? irpfRate : 0)
        }
    }

    /// Base que, con el IVA y el IRPF dados, da exactamente `total` (o lo más cercano si el redondeo lo impide).
    static func base(fromTotal total: Decimal, vatRate: Decimal, irpfRate: Decimal) -> Decimal {
        let factor = 1 + (vatRate - irpfRate) / 100
        var raw = total / factor
        var rounded = Decimal()
        NSDecimalRound(&rounded, &raw, 2, .plain)
        let cent = Decimal(string: "0.01")!
        let candidates = [rounded, rounded - cent, rounded + cent]
        if let exact = candidates.first(where: {
            TaxBreakdown(base: $0, vatRate: vatRate, irpfRate: irpfRate).total == total
        }) {
            return exact
        }
        return rounded
    }

    /// Desglose calculado a partir de la base; `nil` si la base está vacía o es inválida.
    var breakdown: TaxBreakdown? {
        guard let base else { return nil }
        return TaxBreakdown(base: base, vatRate: vatRate, irpfRate: hasIRPF ? irpfRate : 0)
    }

    var canSave: Bool {
        (profile != nil || isEditing)
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
        guard canSave, let breakdown else { return false }
        let name = trimmed(counterpartyName)
        let taxID = trimmed(counterpartyTaxID)
        do {
            if let editingExpense {
                var updated = editingExpense
                updated.date = date
                updated.issuerName = name
                updated.issuerTaxID = taxID
                updated.concept = trimmed(concept)
                updated.taxBase = breakdown.base
                updated.vatRate = breakdown.vatRate
                updated.irpfRate = breakdown.irpfRate
                updated.totalPrice = breakdown.total
                _ = try updateExpenseUseCase.updateExpense(updated)
                errorMessage = nil
                return true
            }
            guard let profile else { return false }
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
