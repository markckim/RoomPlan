//
//  InfoView.swift
//  testing_view
//
//  Created by Mark Kim on 6/19/22.
//

import UIKit

class InfoView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    private(set) var labelView: LabelView?
    private(set) var pickerView: PickerView?
    private(set) var statsView: StatsView?
    private(set) var closeButton: UIButton?
    private(set) var pickerData: [String]

    private var labelSize: CGSize
    private var pickerSize: CGSize
    private var statsSize: CGSize

    init(labelSize: CGSize, pickerSize: CGSize, statsSize: CGSize) {
        self.pickerData = ["hello", "world", "my", "name", "is", "mark"]
        self.labelSize = labelSize
        self.pickerSize = pickerSize
        self.statsSize = statsSize
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setupView() {
        clipsToBounds = true

        setupLabelView()
        setupPickerView()
        setupStatsView()
        setupCloseButton()
        setupConstraints()
    }

    func setupCloseButton() {
        let button = UIButton(type: .custom)
        button.contentMode = .scaleAspectFit
        if let image = UIImage(named: "close_button") {
            button.setImage(image, for: .normal)
        }
        button.addTarget(self, action: #selector(didTapCloseButton(with:)), for: .touchUpInside)
        addSubview(button)

        self.closeButton = button
    }

    func setupConstraints() {
        guard let closeButton = closeButton,
              let labelView = labelView
        else {
            return
        }

        // this is very important
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),
            closeButton.trailingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: -12.0),
            closeButton.centerYAnchor.constraint(equalTo: labelView.centerYAnchor)
        ])
    }

    @objc func didTapCloseButton(with sender: UIButton) {
        print("didTapCloseButton")
    }

    func setupLabelView() {
        let frame = CGRectMake(0.0, 0.0, labelSize.width, labelSize.height)
        let labelView = LabelView(frame: frame)
        labelView.title = "Testing"
        addSubview(labelView)
        //labelView.layer.borderColor = UIColor.red.cgColor
        //labelView.layer.borderWidth = 2.0

        self.labelView = labelView
    }

    func setupPickerView() {
        guard let labelView = labelView else {
            return
        }
        let frame = CGRectMake(0.0, labelView.frame.maxY, pickerSize.width, pickerSize.height)
        let pickerView = PickerView(frame: frame)
        pickerView.pickerView?.delegate = self
        pickerView.pickerView?.dataSource = self
        pickerView.pickerView?.selectRow(1, inComponent: 0, animated: false)
        addSubview(pickerView)
        //pickerView.layer.borderColor = UIColor.red.cgColor
        //pickerView.layer.borderWidth = 2.0

        self.pickerView = pickerView
    }

    func setupStatsView() {
        guard let pickerView = pickerView else {
            return
        }
        let frame = CGRectMake(0.0, pickerView.frame.maxY, statsSize.width, statsSize.height)
        let statsView = StatsView(frame: frame)
        statsView.updateDimensions(width: 2.5, height: 3.8, length: 4.2)
        addSubview(statsView)
        //statsView.layer.borderColor = UIColor.red.cgColor
        //statsView.layer.borderWidth = 2.0

        self.statsView = statsView
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let statsView = statsView else {
            return .zero
        }
        let statsViewFrame = statsView.frame
        return CGSizeMake(statsViewFrame.width, statsViewFrame.maxY)
    }
}

// MARK: - UIPickerViewDelegate

extension InfoView {
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return bounds.width
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        guard let selectedObjectNode = selectedObjectNode
//        else {
//            return
//        }
//        let text = pickerData[row]
//        selectedObjectNode.updateEditingLabelText(with: text)
    }
}

// MARK: - UIPickerViewDatasource

extension InfoView {
    // returns the number of 'columns' to display.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // returns the # of rows in each component..
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
}
