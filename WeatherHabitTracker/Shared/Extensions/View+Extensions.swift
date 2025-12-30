//
//  View+Extensions.swift
//  WeatherHabitTracker
//
//  SwiftUI View extensions for common modifiers and utilities.
//

import SwiftUI

extension View {
    
    // MARK: - Conditional Modifiers
    
    /// Applies a modifier conditionally
    /// - Parameters:
    ///   - condition: Whether to apply the modifier
    ///   - transform: The modifier to apply
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies a modifier if a value is non-nil
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
    
    // MARK: - Glass Effects
    
    /// Applies the app's standard glass card styling
    func glassCard() -> some View {
        self
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
    
    /// Applies a glass button style
    func glassButton() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
    }
    
    // MARK: - Animation
    
    /// Applies standard spring animation to changes
    func animateOnChange<V: Equatable>(of value: V) -> some View {
        self.animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)
    }
    
    // MARK: - Accessibility
    
    /// Adds accessibility label and hint
    func accessible(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .if(hint != nil) { view in
                view.accessibilityHint(hint!)
            }
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension View {
    /// Wraps view in a preview container with common modifiers
    func previewContainer() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
    }
}
#endif
