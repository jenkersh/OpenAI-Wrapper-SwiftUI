//
//  AppEntryView.swift
//  SwiftUI-AI-Wrapper
//
//  Created by Jen Kersh on 7/6/25.
//

import SwiftUI

struct AppEntryView: View {
    @AppStorage("hasSeenIntro") private var hasSeenIntro = false
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if hasSeenIntro {
                    HomeView()
                } else {
                    WelcomeScreen {
                        path.append("stepTwo")
                    }
                }
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "stepTwo":
                    StepTwoView {
                        path.append("finalStep")
                    }
                case "finalStep":
                    FinalStepView {
                        hasSeenIntro = true
                        path.append("home")
                    }
                case "home":
                    HomeView()
                        .navigationBarBackButtonHidden(true)
                default:
                    EmptyView()
                }
            }
        }
    }
}

struct WelcomeScreen: View {
    var onNext: () -> Void

    var body: some View {
        VStack {
            Text("Welcome to the App!")
            Button("Next", action: onNext)
        }
    }
}

struct StepTwoView: View {
    var onNext: () -> Void

    var body: some View {
        VStack {
            Text("Step 2 Placeholder")
            Button("Next", action: onNext)
        }
    }
}

struct FinalStepView: View {
    var onFinish: () -> Void

    var body: some View {
        VStack {
            Text("Final Step Placeholder")
            Button("Get Started", action: onFinish)
        }
    }
}

