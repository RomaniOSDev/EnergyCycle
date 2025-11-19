//
//  ContentView.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = EnergyCycleViewModel()
    @State private var selectedTab = 0
    @State private var hasCompletedOnboarding = OnboardingService.shared.hasCompletedOnboarding
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color.mainBack)
        UITabBar.appearance().barTintColor = UIColor(Color.mainBack)
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.colorText.opacity(0.6))
       
        
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.colorText)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.colorText)]
        UINavigationBar.appearance().barTintColor = UIColor(Color.mainBack)
        UINavigationBar.appearance().isTranslucent = false
    }
    
    var body: some View {
        
            if hasCompletedOnboarding {
                MainAppView(viewModel: viewModel, selectedTab: $selectedTab)
                    .preferredColorScheme(.dark)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .preferredColorScheme(.dark)
            }
        
    }
}

struct MainAppView: View {
    @ObservedObject var viewModel: EnergyCycleViewModel
    @Binding var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            EnergyTrackerView(viewModel: viewModel)
                .tabItem {
                    Label("Energy", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            
            ActivitiesView(viewModel: viewModel)
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
                .tag(2)
            
            AnalysisView(viewModel: viewModel)
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .background(Color.mainBack)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

