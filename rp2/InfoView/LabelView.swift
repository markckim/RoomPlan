//
//  LabelView.swift
//  testing_view
//
//  Created by Mark Kim on 6/19/22.
//

import UIKit

class LabelView: UIView {
    var title: String? {
        get {
            return titleLabel?.text
        }
        set {
            titleLabel?.text = newValue
        }
    }

    private var titleLabel: UILabel?
    private var textColor: UIColor

    init(frame: CGRect, backgroundColor: UIColor, textColor: UIColor) {
        self.textColor = textColor
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setupView() {
        titleLabel = UILabel()
        guard let titleLabel = titleLabel else {
            return
        }
        titleLabel.font = UIFont(name: themeFont, size: 36)
        titleLabel.textAlignment = .center
        titleLabel.textColor = textColor
        addSubview(titleLabel)

        self.titleLabel = titleLabel
    }

    func setupConstraints() {
        guard let titleLabel = titleLabel else {
            return
        }

        // this is very important
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
        ])
    }
}
