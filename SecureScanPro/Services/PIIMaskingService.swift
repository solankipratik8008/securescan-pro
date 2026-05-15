//
//  PIIMaskingService.swift
//  SecureScanPro
//
//  Created by Pratik Solanki on 2026-05-15.
//

import Foundation

/// Handles privacy-focused masking of sensitive information found in OCR text.
/// The app will use this only when the user turns Privacy Masking ON.
final class PIIMaskingService {
    
    /// Masks common sensitive data patterns inside recognized OCR text.
    ///
    /// Examples:
    /// - Email: pratik@example.com -> p***@example.com
    /// - Phone: 548-384-8008 -> ***-***-8008
    /// - SIN-like number: 123 456 789 -> *** *** 789
    /// - Credit-card-like number: 4111 1111 1111 1111 -> **** **** **** 1111
    func maskSensitiveInformation(in text: String) -> String {
        var maskedText = text
        
        maskedText = maskEmails(in: maskedText)
        maskedText = maskPhoneNumbers(in: maskedText)
        maskedText = maskCreditCardLikeNumbers(in: maskedText)
        maskedText = maskSINLikeNumbers(in: maskedText)
        
        return maskedText
    }
    
    // MARK: - Private Helpers
    
    private func maskEmails(in text: String) -> String {
        let pattern = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#
        
        return replaceMatches(in: text, pattern: pattern) { match in
            let parts = match.split(separator: "@", maxSplits: 1)
            
            guard parts.count == 2,
                  let firstCharacter = parts[0].first else {
                return "[EMAIL HIDDEN]"
            }
            
            return "\(firstCharacter)***@\(parts[1])"
        }
    }
    
    private func maskPhoneNumbers(in text: String) -> String {
        let pattern = #"\b(?:\+?1[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b"#
        
        return replaceMatches(in: text, pattern: pattern) { match in
            let digits = match.filter { $0.isNumber }
            
            guard digits.count >= 10 else {
                return "[PHONE HIDDEN]"
            }
            
            let lastFour = String(digits.suffix(4))
            return "***-***-\(lastFour)"
        }
    }
    
    private func maskCreditCardLikeNumbers(in text: String) -> String {
        let pattern = #"\b(?:\d[ -]*?){13,16}\b"#
        
        return replaceMatches(in: text, pattern: pattern) { match in
            let digits = match.filter { $0.isNumber }
            
            guard digits.count >= 13 else {
                return match
            }
            
            let lastFour = String(digits.suffix(4))
            return "**** **** **** \(lastFour)"
        }
    }
    
    private func maskSINLikeNumbers(in text: String) -> String {
        let pattern = #"\b\d{3}[-\s]?\d{3}[-\s]?\d{3}\b"#
        
        return replaceMatches(in: text, pattern: pattern) { match in
            let digits = match.filter { $0.isNumber }
            
            guard digits.count == 9 else {
                return match
            }
            
            let lastThree = String(digits.suffix(3))
            return "*** *** \(lastThree)"
        }
    }
    
    private func replaceMatches(
        in text: String,
        pattern: String,
        transform: (String) -> String
    ) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return text
        }
        
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, range: nsRange).reversed()
        
        var result = text
        
        for match in matches {
            guard let range = Range(match.range, in: result) else {
                continue
            }
            
            let matchedText = String(result[range])
            let replacement = transform(matchedText)
            result.replaceSubrange(range, with: replacement)
        }
        
        return result
    }
}
