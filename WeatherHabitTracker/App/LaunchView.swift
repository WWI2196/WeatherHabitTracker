// LaunchView.swift
// WeatherHabitTracker

import SwiftUI

/// Entry point view with splash animation and onboarding
struct LaunchView: View {
    @State private var isAnimationComplete = false
    @State private var splashOpacity: Double = 1.0
    @State private var iconScale: CGFloat = 0.8
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        ZStack {
            if isAnimationComplete {
                if hasCompletedOnboarding {
                    MainTabView()
                        .transition(.opacity.combined(with: .scale(scale: 1.02)))
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .transition(.opacity)
                }
            }
            
            if !isAnimationComplete {
                splashContent
                    .opacity(splashOpacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isAnimationComplete)
        .task { await performLaunchAnimation() }
    }
    
    private var splashContent: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.3), .purple.opacity(0.2), .cyan.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                ZStack {
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 60))
                        .symbolRenderingMode(.multicolor)
                        .offset(x: -20, y: -10)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.green)
                        .offset(x: 30, y: 20)
                }
                .scaleEffect(iconScale)
                
                VStack(spacing: 8) {
                    Text("WeatherHabit")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    
                    Text("Track weather & build habits")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.primary)
                    .padding(.top, 20)
            }
        }
    }
    
    private func performLaunchAnimation() async {
        try? await Task.sleep(for: .milliseconds(500))
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            iconScale = 1.0
        }
        
        try? await Task.sleep(for: .milliseconds(1000))
        
        withAnimation(.easeOut(duration: 0.3)) {
            splashOpacity = 0.0
        }
        
        try? await Task.sleep(for: .milliseconds(300))
        isAnimationComplete = true
    }
}

#Preview {
    LaunchView()
        .environment(AppDependencies())
}
