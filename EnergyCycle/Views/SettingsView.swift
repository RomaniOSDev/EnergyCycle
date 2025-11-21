//
//  SettingsView.swift
//  EnergyCycle
//
//  Created by Роман Главацкий on 19.11.2025.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @StateObject private var viewModel = EnergyCycleViewModel()
    @State private var showingExportOptions = false
    @State private var showingShareSheet = false
    @State private var exportData: String = ""
    @State private var exportType: ExportType = .json
    @State private var notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    
    enum ExportType {
        case json, csv
    }
    
    var body: some View {
        ZStack {
            Color.mainBack
                .ignoresSafeArea()
            ScrollView {
                Text("Settings")
                    .font(.system(size: 35, weight: .heavy, design: .monospaced))
                
                VStack(spacing: 20) {
                    // Notifications Toggle
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notifications")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.colorText)
                                Text("Reminders to assess energy")
                                    .font(.caption)
                                    .foregroundColor(.colorText.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $notificationsEnabled)
                                .onChange(of: notificationsEnabled) { enabled in
                                    UserDefaults.standard.set(enabled, forKey: "notificationsEnabled")
                                    if enabled {
                                        NotificationService.shared.requestAuthorization()
                                    } else {
                                        NotificationService.shared.cancelAllNotifications()
                                    }
                                }
                        }
                        .padding(16)
                        .smallCardStyle()
                    }
                    .padding(.horizontal)
                    
                    // Export Data
                    SettingsButtonRow(
                        icon: "square.and.arrow.up",
                        title: "Export Data",
                        iconColor: .purple
                    ) {
                        showingExportOptions = true
                    }
                    
                    // Rate Us
                    SettingsButtonRow(
                        icon: "star.fill",
                        title: "Rate Us",
                        iconColor: .yellow
                    ) {
                        rateApp()
                    }
                    
                    // Privacy Policy
                    SettingsButtonRow(
                        icon: "lock.shield.fill",
                        title: "Privacy",
                        iconColor: .blue
                    ) {
                        openPrivacyPolicy()
                    }
                    
                    // Terms of Service
                    SettingsButtonRow(
                        icon: "doc.text.fill",
                        title: "Terms",
                        iconColor: .green
                    ) {
                        openTerms()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
            .foregroundColor(.colorText)
            .actionSheet(isPresented: $showingExportOptions) {
                ActionSheet(
                    title: Text("Export Data"),
                    buttons: [
                        .default(Text("Export as JSON")) {
                            exportType = .json
                            exportData = viewModel.exportToJSON() ?? ""
                            showingShareSheet = true
                        },
                        .default(Text("Export as CSV")) {
                            exportType = .csv
                            exportData = viewModel.exportToCSV()
                            showingShareSheet = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(activityItems: [exportData])
            }
        }
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func openPrivacyPolicy() {
        // Replace with your actual privacy policy URL
        if let url = URL(string: "https://www.termsfeed.com/live/aa869beb-3861-49d2-9905-f1a25d5c7986") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTerms() {
        // Replace with your actual terms URL
        if let url = URL(string: "https://www.termsfeed.com/live/8793f8b3-982b-425d-b7a8-3682d2c696ef") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsButtonRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.colorText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.colorText.opacity(0.5))
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(16)
            .smallCardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
}

