import Foundation
import SwiftData

@Model
final class HashChainPointerEntity {
    @Attribute(.unique) var id: String
    var lastHash: String

    init(id: String = HashChainPointerEntity.singletonID, lastHash: String) {
        self.id = id
        self.lastHash = lastHash
    }

    static let singletonID = "hashChainPointer"
}
