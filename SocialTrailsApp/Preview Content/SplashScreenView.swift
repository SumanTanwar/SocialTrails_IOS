//
//  SplashScreenView.swift
//  SocialTrailsApp
//
//  Created by Admin on 9/29/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        VStack{
            Image("socialtrails_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200,height: 200)
                .padding(23)
            Text("Share Your Story, Join the Journey")
                .font(.custom("Snell Roundhand", size: 20))
                .foregroundColor(Color(.purple))
                .fontWeight(.bold)
                .padding(8)
                .multilineTextAlignment(.center)
                        
                
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SplashScreenView()
}

