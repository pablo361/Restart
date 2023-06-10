//
//  ContentView.swift
//  Restart
//
//  Created by Pablo Pizarro on 10/06/2023.
//

import SwiftUI

struct ContentView: View {
    //appstorage guarda en la memoria del celular un propiedad con un get y set, se lo coloca un key
    @AppStorage("onboarding") var isOnboardingViewActive: Bool = true
    var body: some View {
        ZStack{
            if isOnboardingViewActive {
                OnboardingView()
            } else {
                HomeView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
