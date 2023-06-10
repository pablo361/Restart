//
//  OnboardingView.swift
//  Restart
//
//  Created by Pablo Pizarro on 10/06/2023.
//

import SwiftUI

struct OnboardingView: View {
    //el valor setado solo se usará si no se encuentra la key en la memoria del celular
    @AppStorage("onboarding") var isOnboardingViewActive: Bool = true
    //el largo del boton es el largo de la pantalla menos 80 puntos
    @State private var buttonWidth: Double = UIScreen.main.bounds.width - 80
    //representa el offset horizontal del boton, cuando se arrastre y suelte
    @State private var buttonOffset: CGFloat = 0
    //si es verdad se mostrarà la animacion
    @State private var isAnimating: Bool = false
    //esto es para el gesto drag y manejar el ancho y alto
    @State private var imageOffset: CGSize = CGSize(width: 0, height: 0 ) //es lo mismo que decir .zero
    @State private var indicatorOpacity: Double = 1.0// este valor servirá para ocultar el simbolo de drag cuando empezemos el gesto
    @State private var textTitle : String = "Share."
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            Color("ColorBlue")
                .ignoresSafeArea(.all,edges:.all)
            VStack(spacing:20) {
                // MARK: -HEADER
                Spacer()
                VStack(spacing:0){
                    Text(textTitle)
                        .font(.system(size: 60))
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .transition(.opacity)
                        .id(textTitle) //usamos esto para decirle a swiftUI que este viste ya NO ES LA MISMA
                    if #available(iOS 16.0, *) {
                        Text("It's not how much we give but how much we put into giving.")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .frame(width:280)
                            .fontWeight(.light)
                            .foregroundColor(.white)
                            .padding(.horizontal,10)
                    } else {
                        // Fallback on earlier versions
                        Text("It's not how much we give but how much we put into giving.")
                            .font(.title3.weight(.light))
                            .multilineTextAlignment(.center)
                            .frame(width:280)
                            .foregroundColor(.white)
                            .padding(.horizontal,10)
                    }
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0: -40)
                //esto animará los cambios que se encuentren arriba, el value determina que valor causa el cambio en la animacion
                .animation(.easeOut(duration: 1), value: isAnimating)
                // MARK: - CENTER
                ZStack{
                    CircleGroupView(ShapeColor: .white, ShapeOpacity: 0.2)
                        .offset(x: imageOffset.width * -1) //el anillo se mueve en el opuesto del gesto
                        .blur(radius: abs(imageOffset.width / 5))
                        .animation(.easeOut(duration: 1), value: imageOffset)
                    Image("character-1")
                        .resizable()
                        .scaledToFit()
                        .opacity(isAnimating ? 1: 0)
                        .animation(.easeOut(duration: 0.5), value: isAnimating)
                        .offset(x: imageOffset.width * 1.2, y:0)//el 1.2 hace que la imagen se mueva mas rapido que el dedo en el gesto
                        .rotationEffect(.degrees(Double(imageOffset.width / 20)))
                        .gesture(
                            DragGesture()
                                .onChanged{ gesto in
                                    if abs(imageOffset.width) <= 150{
                                        //esto proveee la informacion del movimiento desd el inicio hasta el fin del gesto
                                        imageOffset = gesto.translation
                                        withAnimation(.linear(duration: 0.25)){
                                            indicatorOpacity = 0
                                            textTitle = "Give."
                                        }
                                    }
                                    
                                }
                            //esto harà que al levantar el dedo la imagen se resetee
                                .onEnded{_ in
                                    imageOffset = .zero
                                    withAnimation(.linear(duration: 0.25)){
                                        indicatorOpacity = 1
                                        textTitle = "Share."
                                    }
                                }
                        )//: Gesture
                        .animation(.easeOut(duration: 1), value: imageOffset)
                    
                }//: CENTER
                .overlay(
                    Image(systemName: "arrow.left.and.right.circle")
                        .font(.system(size: 44,weight: .ultraLight))
                        .foregroundColor(.white)
                        .offset(y: 20)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.easeOut(duration: 1).delay(2), value: isAnimating)
                        .opacity(indicatorOpacity) //se pueden duplicar el indicardor de opacidad o cualquiera
                    ,alignment: .bottom
                )
                Spacer()
                // MARK: - FOOTER
                ZStack{
                    //1. fondo
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .padding(8)
                    //2. call to action
                    Text("Empezar")
                        .font(.system(.title3,design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .offset(x:20)
                    //3. capsula dinamica
                    HStack{
                        Capsule()
                            .fill(Color("ColorRed"))
                            .frame(width: buttonOffset + 80)
                        Spacer()
                    }
                    //4. circulo(draggable)
                    HStack {
                        ZStack{
                            Circle()
                                .fill(Color("ColorRed"))
                            Circle()
                                .fill(.black.opacity(0.15))
                                .padding(8)
                            Image(systemName: "chevron.right.2")
                                .font(.system(size: 24,weight: .bold))
                        }
                        .foregroundColor(.white)
                    .frame(width: 80,height: 80,alignment: .center)
                    .offset(x:buttonOffset)
                    .gesture(
                        DragGesture()
                            .onChanged{ gesto in
                                if gesto.translation.width > 0 && buttonOffset <= buttonWidth - 80{
                                    //se resta 80 porque el ancho del boton es 80
                                    buttonOffset = gesto.translation.width
                                }
                            }
                            .onEnded{ gesto in
                                //esto anima lo que esté dentro del codigo
                                withAnimation(Animation.easeOut(duration: 0.5)){
                                    if buttonOffset > buttonWidth / 2{
                                        hapticFeedback.notificationOccurred(.success)
                                        playSound(sound: "chimeup", type: "mp3")
                                        buttonOffset = buttonWidth - 80
                                        isOnboardingViewActive = false
                                    } else {
                                        hapticFeedback.notificationOccurred(.warning)
                                        buttonOffset = 0
                                    }
                                }
                                
                            }
                    )//: draggesture
                        
                        Spacer()
                    }
                    
                }//Footer
                .frame(width:buttonWidth,height: 80,alignment: .center)
                .padding()
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 1 : 40)
                .animation(.easeOut(duration: 1), value: isAnimating)
                
            }// VSTACK
            
        }//ZSTACK
        .onAppear(perform: {
          isAnimating = true
        })
        .preferredColorScheme(.dark)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
