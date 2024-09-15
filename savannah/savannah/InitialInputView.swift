//
//  InitialInputView.swift
//  savannah
//
//  Created by Kemal Erol on 13/09/2024.
//

import SwiftUI

struct InitialInputView: View {
    @Binding var input: String
    @Binding var imageUrl: String?
    @Binding var thumbnailImage: UIImage?
    let agent: Agent
    let isInputFocused: FocusState<Bool>.Binding
    let handleSubmit: () -> Void
    let presentImagePicker: () -> Void
    let removeImage: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $input)
                    .frame(height: 120)
                    .padding(0)
                    .background(Color.clear)
                    .focused(isInputFocused)

                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.customTeal, lineWidth: 2)
                    .frame(height: 120)

                if input.isEmpty && !isInputFocused.wrappedValue {
                    Text("Ask \(agent.name) interior...")
                        .foregroundColor(.customGray.opacity(0.6))
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                }
                
                if let thumbnail = thumbnailImage {
                    ZStack(alignment: .topLeading) {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Button(action: removeImage) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.customTeal)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .offset(x: -6, y: -6)
                    }
                    .offset(x: 8, y: -30)
                }
                
                HStack {
                    Button(action: presentImagePicker) {
                        Image(systemName: thumbnailImage != nil ? "photo.fill" : "photo")
                            .foregroundColor(thumbnailImage != nil ? .customTeal : .customGray)
                            .font(.system(size: 20))
                    }
                    
                    Spacer()
                    
                    Button(action: handleSubmit) {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.customWhite)
                            .font(.system(size: 20))
                            .frame(width: 40, height: 40)
                            .background(Color.customTeal)
                            .clipShape(Circle())
                    }
                }
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(height: 120)
        }
        .padding(.top, 32)
    }
}
