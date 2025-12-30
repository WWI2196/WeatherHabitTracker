// OnboardingView.swift
// WeatherHabitTracker

import SwiftUI

/// First-launch onboarding with feature descriptions
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "cloud.sun.fill",
            title: "Weather at a Glance",
            description: "Get real-time weather updates with beautiful visuals. Know what's coming so you can plan your day.",
            accentColor: .blue
        ),
        OnboardingPage(
            icon: "checklist",
            title: "Build Better Habits",
            description: "Track daily habits with smart reminders. Build streaks and see your progress over time.",
            accentColor: .green
        ),
        OnboardingPage(
            icon: "sparkles",
            title: "Smart Insights",
            description: "Get personalized suggestions based on weather. Perfect for planning outdoor activities.",
            accentColor: .purple
        ),
        OnboardingPage(
            icon: "bell.badge.fill",
            title: "Stay on Track",
            description: "Customizable reminders help you never miss a habit. Build consistency effortlessly.",
            accentColor: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            backgroundGradient
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding()
                }
                
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                #if !os(macOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                
                // Page indicator and button
                VStack(spacing: 30) {
                    // Custom page indicator
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? pages[currentPage].accentColor : .secondary.opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    
                    // Action button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation(.spring(response: 0.4)) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.nativeGlassProminent)
                    .padding(.horizontal, 32)
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private var backgroundGradient: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                pages[currentPage].accentColor.opacity(0.3),
                .blue.opacity(0.2),
                pages[currentPage].accentColor.opacity(0.2),
                .purple.opacity(0.15),
                pages[currentPage].accentColor.opacity(0.15),
                .cyan.opacity(0.2),
                .blue.opacity(0.2),
                .purple.opacity(0.15),
                pages[currentPage].accentColor.opacity(0.25)
            ]
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: currentPage)
    }
    
    private func completeOnboarding() {
        withAnimation(.spring(response: 0.4)) {
            hasCompletedOnboarding = true
        }
        // Haptic feedback
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }
}

// MARK: - Data Model

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
}

// MARK: - Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.icon)
                    .font(.system(size: 60))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(page.accentColor)
            }
            .liquidGlass(cornerRadius: 70)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
