import Foundation

final class MockFetchQuarterBalanceUseCase: FetchQuarterBalanceUseCaseProtocol {
    var balanceToReturn = QuarterBalance(
        year: 2026,
        quarter: 1,
        interval: DateInterval(start: .now, duration: 0),
        invoiced: 0,
        pendingToInvoice: 0
    )
    var errorToThrow: Error?

    func fetchBalance(for date: Date) throws -> QuarterBalance {
        if let errorToThrow { throw errorToThrow }
        return balanceToReturn
    }
}
