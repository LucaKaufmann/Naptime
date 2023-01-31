//
//  ToggleView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 30.1.2023.
//

import SwiftUI

struct ToggleView<Content: View, ButtonContent: View>: View {
   @Binding var isOn: Bool
   var backGround: Content
   var toggleButton: ButtonContent?
   init(isOn: Binding<Bool>, @ViewBuilder backGround: @escaping () -> Content, @ViewBuilder button: @escaping () -> ButtonContent? = {nil}) {
       self._isOn = isOn
       self.backGround = backGround()
       self.toggleButton = button()
   }
   var body: some View {
       GeometryReader { reader in
           HStack {
               HStack {
                   if isOn {
                       Spacer()
                   }
                   VStack {
                       if let toggleButton = toggleButton {
                           toggleButton
                               .clipShape(Rectangle())
                       }else {
                           Circle()
                               .fill(Color.white)
                       }
                   }
                   .frame(width: reader.frame(in: .global).width/2 - 10)
                   .onTapGesture {
                       withAnimation {
                           isOn.toggle()
                       }
                       let impactMed = UIImpactFeedbackGenerator(style: .medium)
                       impactMed.impactOccurred()
                   }.modifier(Swipe { direction in
                       if direction == .swipeLeft {
                           withAnimation() {
                               isOn = true
                           }
                       }else if direction == .swipeRight {
                           withAnimation() {
                               isOn = false
                           }
                       }
                   })
                   if !isOn {
                       Spacer()
                   }
               }
               .clipShape(RoundedRectangle(cornerRadius: 10))
           }
           .padding(5)
           .background(backGround)
           .clipShape(RoundedRectangle(cornerRadius: 12))
       }
   }
}

struct Swipe: ViewModifier {
   @GestureState private var dragDirection: Direction = .none
   @State private var lastDragPosition: DragGesture.Value?
   @State var position = Direction.none
   var action: (Direction) -> Void
   func body(content: Content) -> some View {
       content
           .gesture(DragGesture().onChanged { value in
               lastDragPosition = value
           }.onEnded { value in
               if lastDragPosition != nil {
                   if (lastDragPosition?.location.x)! < value.location.x {
                       withAnimation() {
                           action(.swipeRight)
                       }
                   }else if (lastDragPosition?.location.x)! > value.location.x {
                       withAnimation() {
                           action(.swipeLeft)
                       }
                   }
               }
           })
   }
}

enum Direction {
   case none
   case swipeLeft
   case swipeRight
   case swipeUp
   case swipeDown
}
