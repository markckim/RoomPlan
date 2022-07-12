//
//  StatsView.swift
//  testing_view
//
//  Created by Mark Kim on 6/19/22.
//

import UIKit

class StatsView: UIView {
    private(set) var width: CGFloat
    private(set) var height: CGFloat
    private(set) var length: CGFloat

    private var titleLabel: UILabel?

    override init(frame: CGRect) {
        self.width = 0
        self.height = 0
        self.length = 0
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func updateDimensions(width: CGFloat, height: CGFloat, length: CGFloat) {
        self.width = width
        self.height = height
        self.length = length

        self.titleLabel?.text = String(format: "Dimensions:\n%.2fm x %.2fm x %.2fm", width, height, length)
    }

    private func setupView() {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        addSubview(titleLabel)
        self.titleLabel = titleLabel
    }

    private func setupConstraints() {
        guard let titleLabel = titleLabel else {
            return
        }

        // this is very important
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 8.0),
            titleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
        ])
    }
}


class XXX: UIView {
    var title: String? {
        get {
            return titleLabel?.text
        }
        set {
            titleLabel?.text = newValue
        }
    }

    private var titleLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }

    private func setupView() {
        titleLabel = UILabel()
        guard let titleLabel = titleLabel else {
            return
        }
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        self.titleLabel = titleLabel
    }

    private func setupConstraints() {
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
