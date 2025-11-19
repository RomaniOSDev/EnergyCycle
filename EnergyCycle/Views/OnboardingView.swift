//
//  OnboardingView.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        ZStack {
            Color.mainBack
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Контент страниц
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        image: "chart.line.uptrend.xyaxis",
                        title: "Track Your Energy",
                        description: "Assess your physical and mental energy levels throughout the day for optimal planning",
                        pageIndex: 0
                    )
                    .tag(0)
                    
                    OnboardingPageView(
                        image: "brain.head.profile",
                        title: "Plan Your Tasks",
                        description: "Add tasks and get recommendations for optimal execution times based on your energy peaks",
                        pageIndex: 1
                    )
                    .tag(1)
                    
                    OnboardingPageView(
                        image: "chart.bar.fill",
                        title: "Analyze Effectiveness",
                        description: "Track planning effectiveness and get recommendations to improve productivity",
                        pageIndex: 2
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Индикаторы страниц
                HStack(spacing: 10) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.color1 : Color.colorText.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 24)
                
                // Кнопка навигации
                Button(action: {
                    if currentPage < 2 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            currentPage += 1
                        }
                    } else {
                        OnboardingService.shared.completeOnboarding()
                        hasCompletedOnboarding = true
                    }
                }) {
                    HStack(spacing: 12) {
                        if currentPage == 2 {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                        }
                        Text(currentPage == 2 ? "Get Started" : "Next")
                            .font(.headline)
                            .fontWeight(.semibold)
                        if currentPage < 2 {
                            Image(systemName: "arrow.right")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .primaryButtonStyle()
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct OnboardingPageView: View {
    let image: String
    let title: String
    let description: String
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            
            // Иконка с эффектом
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.color1.opacity(0.3), Color.color1.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                
                Circle()
                    .fill(Color.color1.opacity(0.2))
                    .frame(width: 140, height: 140)
                
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.color1)
                    .shadow(color: Color.color1.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            .padding(.bottom, 20)
            
            // Заголовок
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.colorText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            // Описание
            Text(description)
                .font(.body)
                .foregroundColor(.colorText.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}

