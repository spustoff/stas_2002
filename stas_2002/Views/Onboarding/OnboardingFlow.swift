//
//  OnboardingFlow.swift
//  Culinary PathwaysFortune
//
//  Created by Вячеслав on 9/27/25.
//

import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color("PrimaryRed"), Color("WarmBeige")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress bar
                    ProgressView(value: viewModel.progressPercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color("VibrantGreen")))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Content
                    TabView(selection: $viewModel.currentStep) {
                        WelcomeView()
                            .tag(OnboardingViewModel.OnboardingStep.welcome)
                        
                        PreferencesView()
                            .tag(OnboardingViewModel.OnboardingStep.preferences)
                        
                        FinalizationView()
                            .tag(OnboardingViewModel.OnboardingStep.finalization)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut, value: viewModel.currentStep)
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.isCompleted) { completed in
            if completed {
                dismiss()
            }
        }
    }
}

#Preview {
    OnboardingFlow()
        .environmentObject(OnboardingViewModel())
}
