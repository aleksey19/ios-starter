//
//  AlertViewController.swift
//  ios-starter
//
//  Created by Aleksey Bidnyk on 29.03.2024.
//

import UIKit
import RxSwift
import RxCocoa

class AlertViewController: UIViewController {
    
    @IBOutlet private weak var bgView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var buttonsStackHeightConstraint: NSLayoutConstraint!
    
    var viewModel: AlertViewModel!
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        bindViewModel()
        
        if viewModel.canDismissOnBackgroundTap == true {
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(onTapView(_:)))
            view.addGestureRecognizer(tapGR)
        }
        
        setBackgroundColor()
    }
    
    private func setupView() {
        titleLabel.isHidden = true
        messageLabel.isHidden = true
    }
    
    private func setBackgroundColor() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33,
                                      execute: { [weak self] in
            UIView.animate(withDuration: TimeInterval(0.3),
                           animations: { [weak self] in
                self?.view.backgroundColor = .black.withAlphaComponent(0.75)
            })
        })
    }
    
    private func setupButtons() {
        let buttonsTitles = [viewModel.buttonTitle, "Cancel"]
        let actions = [#selector(onTapButton(_:)), #selector(onTapView(_:))]

        buttonsStackHeightConstraint.constant = buttonsTitles.count == 0 ? 0 : 45
        
        buttonsTitles.enumerated().forEach { [weak self] (idx, title) in
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            button.setTitle(title, for: .normal)
//            button.layer.borderWidth = 0.8
//            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.setTitleColor(UIColor.systemBlue, for: .normal)
            button.tag = idx
            button.addTarget(self,
                             action: actions[idx],
                             for: .touchUpInside)

            buttonsStackView.addArrangedSubview(button)
        }
    }
    
    private func bindViewModel() {
        if let title = viewModel.title?.uppercased() {
            titleLabel.isHidden = false
            titleLabel.text = title
        }
        
        if let message = viewModel.message {
            messageLabel.isHidden = false
            messageLabel.text = message
        }
    }
    
    // MARK: - Actions
    
    @objc private func onTapView(_ tapGr: UITapGestureRecognizer) {
        let point = tapGr.location(in: view)
        if bgView.frame.contains(point) {
            return
        }
        
        dismiss()
    }
    
    @objc private func onTapButton(_ sender: UIButton) {
        dismiss(with: viewModel.action)
    }
    
    // MARK: - Private
    
    private func dismiss(with action: AlertViewModel.AlertAction? = nil) {
        let duration = 0.3
        let frame = self.view.frame
        
        // Clear background color
        UIView.animate(
            withDuration: TimeInterval(duration),
            animations: { [weak self] in
                self?.view.backgroundColor = .clear
            },
            completion: nil)
        
        // Play disappear animation
        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration / 2,
            execute: {
                UIView.animate(
                    withDuration: 0.4,
                    animations: { [unowned self] in
                        self.view.frame = CGRect(x: 0,
                                                  y: frame.height,
                                                  width: frame.width,
                                                  height: frame.height)
                    },
                    completion: { [weak self] completed in
                        
                        // Dismiss controller
                        if completed {
                            self?.dismiss(animated: false,
                                          completion: {
                                action?()
                            })
                        }
                    })
        })
    }
}
