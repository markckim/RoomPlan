//
//  PickerView.swift
//  testing_view
//
//  Created by Mark Kim on 6/19/22.
//

import UIKit

class PickerView: UIView {
    private(set) var pickerView: UIPickerView?

    private var titleLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupView() {
        // label
        let titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        titleLabel.textAlignment = .left
        titleLabel.text = "Edit Category:"
        addSubview(titleLabel)
        self.titleLabel = titleLabel

        // picker
        let pickerView = UIPickerView()
        addSubview(pickerView)
        self.pickerView = pickerView
    }

    private func setupConstraints() {
        guard let titleLabel = titleLabel,
              let pickerView = pickerView
        else {
            return
        }

        // this is very important
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 8.0),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 24),

            pickerView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1.0),
            pickerView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
    }
}

