// Hai fatto? — OnboardingView
import SwiftUI

struct OnboardingView: View {
    @Bindable var profile: UserProfile
    @State private var currentPage = 0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                VStack(spacing: 30) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.blue)
                        .padding()
                    
                    Text(String(localized: "onboarding_welcome_title"))
                        .font(.largeTitle)
                        .bold()
                    
                    Text(String(localized: "onboarding_welcome_subtitle"))
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .tag(0)
                
                // Page 2: Widgets
                VStack(spacing: 30) {
                    Image(systemName: "widget.large")
                        .font(.system(size: 100))
                        .foregroundStyle(.green)
                        .padding()
                    
                    Text(String(localized: "onboarding_widgets_title"))
                        .font(.largeTitle)
                        .bold()
                    
                    Text(String(localized: "onboarding_widgets_subtitle"))
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .tag(1)
                
                // Page 3: Get Started
                VStack(spacing: 30) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.orange)
                        .padding()
                    
                    Text(String(localized: "onboarding_ready_title"))
                        .font(.largeTitle)
                        .bold()
                    
                    Text(String(localized: "onboarding_ready_subtitle"))
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button(action: {
                        Task {
                            await NotificationService.requestPermission()
                        }
                    }) {
                        Text(String(localized: "onboarding_notifications_button"))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)
                    
                    Button(action: {
                        withAnimation {
                            profile.hasSeenOnboarding = true
                        }
                    }) {
                        Text(String(localized: "onboarding_get_started_button"))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 32)
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)
            
            if currentPage < 2 {
                Button(String(localized: "general_skip")) {
                    withAnimation {
                        profile.hasSeenOnboarding = true
                    }
                }
                .padding()
                .foregroundStyle(.secondary)
            }
        }
    }
}
