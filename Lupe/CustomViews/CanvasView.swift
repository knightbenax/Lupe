//
//  CanvasView.swift
//  InfiniteCanvas
//
//  Created by Simon Støvring on 24/07/2020.
//

import UIKit
import PencilKit

final class CanvasView: UIView {
    let canvasView: PKCanvasView = {
        let this = PKCanvasView()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.backgroundColor = .systemBackground
        this.minimumZoomScale = 0.25
        this.maximumZoomScale = 10
        this.zoomScale = 1
        this.showsVerticalScrollIndicator = false
        this.showsHorizontalScrollIndicator = false
        return this
    }()

    let editButton: UIButton = {
        let this = UIButton(type: .system)
        this.translatesAutoresizingMaskIntoConstraints = false
        return this
    }()
    var canvasBottomOffset: CGFloat = 0 {
        didSet {
            if canvasBottomOffset != oldValue {
                setNeedsUpdateConstraints()
            }
        }
    }

    private var canvasBottomConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)
        setupView()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .systemBackground
        addSubview(canvasView)
        addSubview(editButton)
    }

    private func setupLayout() {
        canvasView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        canvasView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        canvasView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        canvasBottomConstraint = canvasView.bottomAnchor.constraint(equalTo: bottomAnchor)
        canvasBottomConstraint?.isActive = true

        editButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        editButton.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
    }

    override func updateConstraints() {
        super.updateConstraints()
        //canvasBottomConstraint?.constant = -canvasBottomOffset
    }
}
