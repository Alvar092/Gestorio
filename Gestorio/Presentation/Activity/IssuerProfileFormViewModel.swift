import Foundation

@MainActor
@Observable
final class IssuerProfileFormViewModel {
    private let fetchProfileUseCase: FetchIssuerProfileUseCaseProtocol
    private let saveProfileUseCase: SaveIssuerProfileUseCaseProtocol

    var name = ""
    var taxID = ""
    var errorMessage: String?

    init(
        fetchProfileUseCase: FetchIssuerProfileUseCaseProtocol,
        saveProfileUseCase: SaveIssuerProfileUseCaseProtocol
    ) {
        self.fetchProfileUseCase = fetchProfileUseCase
        self.saveProfileUseCase = saveProfileUseCase
    }

    convenience init() {
        self.init(
            fetchProfileUseCase: FetchIssuerProfileUseCase(),
            saveProfileUseCase: SaveIssuerProfileUseCase()
        )
    }

    var canSave: Bool {
        !trimmed(name).isEmpty && !trimmed(taxID).isEmpty
    }

    func load() {
        do {
            if let profile = try fetchProfileUseCase.fetchProfile() {
                name = profile.name
                taxID = profile.taxID
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Devuelve `true` si se guardó correctamente.
    func save() -> Bool {
        guard canSave else { return false }
        do {
            _ = try saveProfileUseCase.saveProfile(IssuerProfile(name: trimmed(name), taxID: trimmed(taxID)))
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
