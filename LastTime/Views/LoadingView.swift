import SwiftUI

struct LoadingView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var ringRotation: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0.5
    @State private var subtitleOpacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.backgroundPrimary, AppColors.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    // Outer rotating ring
                    Circle()
                        .stroke(
                            AppColors.accent.opacity(0.25),
                            lineWidth: 2
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                        .rotationEffect(.degrees(ringRotation))

                    // Accent arc (animated segment)
                    Circle()
                        .trim(from: 0, to: 0.35)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    AppColors.accent,
                                    AppColors.accentMuted,
                                    AppColors.accent.opacity(0.3)
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(ringRotation))

                    // Center icon
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 44))
                        .foregroundStyle(AppColors.accent)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                VStack(spacing: 8) {
                    Text("Last Time")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    Text("loading.subtitle")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .opacity(subtitleOpacity)
                }

                Spacer()

                // Bottom loading indicator
                HStack(spacing: 6) {
                    ForEach(0..<3) { index in
                        LoadingDotView(delay: Double(index) * 0.15)
                    }
                }
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.6)) {
            logoScale = 1
            logoOpacity = 1
            ringScale = 1
            ringOpacity = 0.6
        }

        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            subtitleOpacity = 1
        }

        withAnimation(
            .linear(duration: 2)
            .repeatForever(autoreverses: false)
        ) {
            ringRotation = 360
        }
    }
}

private struct LoadingDotView: View {
    let delay: Double
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.4

    var body: some View {
        Circle()
            .fill(AppColors.accent)
            .frame(width: 8, height: 8)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    scale = 1.2
                    opacity = 1
                }
            }
    }
}

#Preview {
    LoadingView()
}
