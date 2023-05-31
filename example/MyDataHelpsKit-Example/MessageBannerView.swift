//
//  MessageBannerView.swift
//  MyDataHelpsKit-Example
//
//  Created by CareEvolution on 4/4/23.
//

import SwiftUI

/// Use this as an `@EnvironmentObject` to display a message banner from anywhere in the view hierarchy.
@MainActor class MessageBannerModel: ObservableObject {
    @Published var message: String? = nil
    
    public func callAsFunction(_ text: String) {
        showMessage(text)
    }
    
    func showMessage(_ text: String) {
        withAnimation {
            self.message = text
        }
    }
}

extension View {
    func banner() -> some View {
        modifier(DisplaysMessageBanner())
    }
}

struct DisplaysMessageBanner: ViewModifier {
    func body(content: Content) -> some View {
        MessageBannerView {
            content
        }
    }
}

struct MessageBannerView<Content>: View where Content: View {
    @ViewBuilder var content: () -> Content
    
    @StateObject private var model = MessageBannerModel()
    @State private var bannerOpacity = 0.0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content()
                .environmentObject(model)
            
            if let message = model.message {
                GroupBox {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .font(.headline)
                        .onTapGesture(perform: hideBanner)
                        .padding(.horizontal)
                }
                .opacity(bannerOpacity)
                .backgroundStyle(.white)
                .cornerRadius(.infinity)
                .shadow(color: .secondary.opacity(0.5), radius: 4)
                .padding()
                .transition(.opacity)
                .onAppear(perform: brieflyShowBanner)
            }
        }
    }
    
    private func brieflyShowBanner() {
        withAnimation {
            bannerOpacity = 1
        }
        
        Task {
            try? await Task.sleep(for: .seconds(3))
            hideBanner()
        }
    }
    
    private func hideBanner() {
        withAnimation {
            bannerOpacity = 0
        }
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            model.message = nil
        }
    }
}

struct DisplaysMessageBanner_Previews: PreviewProvider {
    static var previews: some View {
        MessageBannerView {
            NavigationStack {
                Content()
                    .navigationTitle("MessageBannerView")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        
        NavigationStack {
            Content()
                .navigationTitle("Using .banner()")
                .navigationBarTitleDisplayMode(.inline)
        }
        .banner()
    }
    
    private struct Wrapper: View {
        @State private var dummy: String? = nil
        
        var body: some View {
            NavigationStack {
                Content()
            }
            .banner()
        }
    }
    
    private struct Content: View {
        @EnvironmentObject var messageBanner: MessageBannerModel
        
        let items = [
            "List item 1",
            "List item 2"
        ]
        
        var body: some View {
            List(items, id: \.self) { item in
                Button(item) {
                    messageBanner(item)
                }
            }
        }
    }
}
