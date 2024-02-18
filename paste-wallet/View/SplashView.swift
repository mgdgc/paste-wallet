//
//  SplashView.swift
//  paste-wallet
//
//  Created by 최명근 on 2/16/24.
//

import SwiftUI

struct SplashView: View {
    var onAnimationFinish: () -> Void
    
    @State private var topSecondaryCardAngle = Angle(degrees: 0)
    @State private var bottomSecondaryCardAngle = Angle(degrees: 0)
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                ZStack {
                    secondaryCard
                        .rotationEffect(topSecondaryCardAngle, anchor: .bottomTrailing)

                    
                    secondaryCard
                        .rotationEffect(bottomSecondaryCardAngle, anchor: .topLeading)
                    
                    primaryCard
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.2).delay(0.3)) {
                topSecondaryCardAngle = .degrees(10)
            }
            
            withAnimation(.easeOut(duration: 0.2).delay(0.4)) {
                bottomSecondaryCardAngle = .degrees(10)
            } completion: {
                usleep(500_000)
                onAnimationFinish()
            }
        }
    }
    
    private var primaryCard: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.backgroundSymbolPrimary)
            .aspectRatio(1.58, contentMode: .fit)
            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            .frame(maxWidth: 128)
    }
    
    private var secondaryCard: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.backgroundSymbolSecondary)
            .aspectRatio(1.58, contentMode: .fit)
            .frame(maxWidth: 128)
    }
}

#Preview {
    SplashView() {
        print("animation finished")
    }
}
