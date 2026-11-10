import Foundation

/// Utilidades para campos de texto con importes decimales.
enum DecimalInput {
    /// Deja solo dígitos y un separador decimal (el del dispositivo; acepta `.`/`,` y lo normaliza),
    /// con un máximo de 2 decimales.
    static func sanitize(_ text: String) -> String {
        let separator = Locale.current.decimalSeparator ?? ","
        var result = ""
        var hasSeparator = false
        var decimals = 0
        for character in text {
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
        return result
    }

    /// Importe parseado con el separador del dispositivo; `nil` si está vacío o es inválido.
    static func parse(_ text: String) -> Decimal? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        return Decimal(string: trimmed, locale: .current)
    }
}
