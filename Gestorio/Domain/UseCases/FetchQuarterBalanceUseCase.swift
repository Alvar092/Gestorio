import Foundation

@MainActor
protocol FetchQuarterBalanceUseCaseProtocol {
    func fetchBalance(for date: Date) throws -> QuarterBalance
}

@MainActor
final class FetchQuarterBalanceUseCase: FetchQuarterBalanceUseCaseProtocol {
    private let invoiceRepository: InvoiceRepositoryProtocol
    private let correctiveInvoiceRepository: CorrectiveInvoiceRepositoryProtocol
    private let appointmentRepository: AppointmentRepositoryProtocol
    private let calendar = Calendar.current

    init(
        invoiceRepository: InvoiceRepositoryProtocol,
        correctiveInvoiceRepository: CorrectiveInvoiceRepositoryProtocol,
        appointmentRepository: AppointmentRepositoryProtocol
    ) {
        self.invoiceRepository = invoiceRepository
        self.correctiveInvoiceRepository = correctiveInvoiceRepository
        self.appointmentRepository = appointmentRepository
    }

    convenience init() {
        self.init(
            invoiceRepository: InvoiceRepository(),
            correctiveInvoiceRepository: CorrectiveInvoiceRepository(),
            appointmentRepository: AppointmentRepository()
        )
    }

    func fetchBalance(for date: Date) throws -> QuarterBalance {
        let interval = calendar.dateInterval(of: .quarter, for: date)
            ?? DateInterval(start: calendar.startOfDay(for: date), duration: 0)

        let invoiced = try invoiceRepository.fetchAll()
            .filter { interval.contains($0.date) }
            .reduce(Decimal.zero) { $0 + $1.totalPrice }
        // Las rectificativas ya llevan el importe en negativo.
        let corrected = try correctiveInvoiceRepository.fetchAll()
            .filter { interval.contains($0.date) }
            .reduce(Decimal.zero) { $0 + $1.totalPrice }
        let pending = try appointmentRepository.fetchAll()
            .filter { interval.contains($0.date) && $0.status == .completed && $0.invoiceID == nil }
            .reduce(Decimal.zero) { $0 + $1.price }

        return QuarterBalance(
            year: calendar.component(.year, from: date),
            quarter: (calendar.component(.month, from: date) - 1) / 3 + 1,
            interval: interval,
            invoiced: invoiced + corrected,
            pendingToInvoice: pending
        )
    }
}
