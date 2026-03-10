//
//  AppTextField.swift
//  UniClub
//
//  Created by 제욱 on 2/3/26.
//

import SwiftUI

public struct AppTextField: View {
    @Environment(\.appMetrics) private var m

    public enum FieldStyle {
        case underline
        case rounded
    }

    private let title: String
    @Binding private var text: String
    private let isSecure: Bool
    private let placeholder: String
    private let style: FieldStyle
    private let errorText: String?

    public init(
        title: String,
        text: Binding<String>,
        placeholder: String = "",
        secure: Bool = false,
        style: FieldStyle = .underline,
        errorText: String? = nil
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.isSecure = secure
        self.style = style
        self.errorText = errorText
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: m.space8) {
            Text(title)
                .font(AppTypography.body())
                .foregroundStyle(AppColors.textPrimary)

            field
                .frame(height: m.controlHeight44)

            if let errorText {
                Text(errorText)
                    .font(AppTypography.caption())
                    .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    private var field: some View {
        switch style {
        case .underline:
            VStack(spacing: m.space8) {
                input
                Rectangle()
                    .fill(AppColors.border)
                    .frame(height: m.hairline)
            }

        case .rounded:
            input
                .padding(.horizontal, m.space12)
                .background(AppColors.fieldFill)
                .clipShape(RoundedRectangle(cornerRadius: m.radius16))
                .overlay(
                    RoundedRectangle(cornerRadius: m.radius16)
                        .stroke(AppColors.border, lineWidth: m.hairline)
                )
        }
    }

    @ViewBuilder
    private var input: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
                .font(AppTypography.body())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        } else {
            TextField(placeholder, text: $text)
                .font(AppTypography.body())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }
}
