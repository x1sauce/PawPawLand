import SwiftUI
import UIKit

struct NewParkUnlockedView: View {
    @Environment(AppState.self) private var appState
    let park: DogPark
    @State private var animateGlow = false
    @State private var animateScale = false

    var body: some View {
        ZStack {
            PawColors.background.ignoresSafeArea()

            RadialGradient(
                colors: [
                    PawColors.gold.opacity(0.15),
                    PawColors.background
                ],
                center: .center,
                startRadius: 20,
                endRadius: 300
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Text("New Park Unlocked!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(PawColors.textPrimary)

                ZStack {
                    Circle()
                        .fill(PawColors.goldGlow)
                        .frame(width: animateGlow ? 220 : 180, height: animateGlow ? 220 : 180)
                        .blur(radius: 20)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animateGlow)

                    ParkThumbnail(seed: park.imageSeed, size: 160)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(PawColors.gold, lineWidth: 3)
                        }
                        .scaleEffect(animateScale ? 1 : 0.6)
                        .opacity(animateScale ? 1 : 0)

                    ZStack {
                        Circle()
                            .fill(PawColors.gold)
                            .frame(width: 52, height: 52)
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color(red: 0.12, green: 0.08, blue: 0.02))
                    }
                    .offset(x: 60, y: 60)
                    .scaleEffect(animateScale ? 1 : 0)
                }

                VStack(spacing: 8) {
                    Text(park.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(PawColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(formattedDate)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(PawColors.textSecondary)
                }
                .padding(.horizontal, 32)

                VStack(spacing: 12) {
                    PawButton(title: "View Park") {
                        appState.dismissUnlockCelebration()
                    }

                    Button("Keep Exploring!") {
                        appState.dismissUnlockCelebration()
                    }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(PawColors.textSecondary)
                }
                .padding(.horizontal, 32)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            animateGlow = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateScale = true
            }

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
        .preferredColorScheme(.dark)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
}

#Preview {
    NewParkUnlockedView(park: MockData.parks[3])
        .environment(AppState())
}
