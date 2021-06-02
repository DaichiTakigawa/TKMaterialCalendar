//
//  DrawerContainerController.swift
//  TKMaterialCalendar
//
//  Created by takigawa on 2021/06/02.
//

import UIKit

class DrawerContainerController: UIViewController {

    enum DrawerState {
        case opened, closed
    }

    var containerViewMaxAlpha: CGFloat = 0.2
    var drawerAnimationDuration: TimeInterval = 0.25
    private var _drawerConstraint: NSLayoutConstraint!
    private var _panStartLocation = CGPoint.zero
    private var _panDelta: CGFloat = 0

    private lazy var _containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(white: 0, alpha: 0)
        containerView.addGestureRecognizer(self.containerViewTapGesture)
        self.view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        setupFullScreenConstraints(superView: self.view, subView: containerView)
        containerView.isHidden = true
        return containerView
    }()

    private var _isDrawerAppearing: Bool?

    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(DrawerContainerController.handlePanGesture(_:))
        )
        gesture.delegate = self
        return gesture
    }()

    private lazy var containerViewTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(DrawerContainerController.handleTapGesture(_:))
        )
        gesture.delegate = self
        return gesture
    }()

    private var drawerState: DrawerState {
        get {
            _containerView.isHidden ? .closed : .opened
        }
        set {
            setDrawerState(newValue, animated: false)
        }
    }

    private var drawerWidth: CGFloat = 280 {
        didSet {
            _drawerConstraint.constant = drawerWidth
        }
    }

    var mainViewController: UIViewController! {
        didSet {
            let isVisible = (drawerState == .closed)

            if let oldContainer = oldValue {
                oldContainer.willMove(toParent: nil)
                if isVisible {
                    oldContainer.beginAppearanceTransition(false, animated: false)
                }
                oldContainer.view.removeFromSuperview()
                if isVisible {
                    oldContainer.endAppearanceTransition()
                }
                oldContainer.removeFromParent()
            }

            addChild(mainViewController)
            if isVisible {
                mainViewController.beginAppearanceTransition(true, animated: false)
            }
            mainViewController.view.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(mainViewController.view, at: 0)

            setupFullScreenConstraints(superView: view, subView: mainViewController.view)

            if isVisible {
                mainViewController.endAppearanceTransition()
            }

            mainViewController.didMove(toParent: self)
        }
    }

    var drawerViewController: UIViewController! {
        didSet {
            let isVisible = (drawerState == .opened)

            if let oldController = oldValue {
                oldController.willMove(toParent: nil)
                if isVisible {
                    oldController.beginAppearanceTransition(false, animated: false)
                }
                oldController.view.removeFromSuperview()
                if isVisible {
                    oldController.endAppearanceTransition()
                }
                oldController.removeFromParent()
            }

            addChild(drawerViewController)

            let shadowRect = CGRect(x: 0, y: 0, width: drawerWidth, height: UIScreen.main.bounds.height)
            drawerViewController.view.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
            drawerViewController.view.layer.shouldRasterize = true
            drawerViewController.view.layer.rasterizationScale = UIScreen.main.scale
            drawerViewController.view.layer.shadowColor = UIColor.black.cgColor
            drawerViewController.view.layer.shadowOpacity = 0.4
            drawerViewController.view.layer.shadowRadius = 5.0
            drawerViewController.view.translatesAutoresizingMaskIntoConstraints = false
            _containerView.addSubview(drawerViewController.view)

            _drawerConstraint = drawerViewController.view.trailingAnchor.constraint(equalTo: view.leadingAnchor)

            NSLayoutConstraint.activate([
                drawerViewController.view.widthAnchor.constraint(equalToConstant: drawerWidth),
                drawerViewController.view.topAnchor.constraint(equalTo: _containerView.topAnchor),
                drawerViewController.view.bottomAnchor.constraint(equalTo: _containerView.bottomAnchor),
                _drawerConstraint
            ])

            if isVisible {
                drawerViewController.endAppearanceTransition()
            }

            drawerViewController.didMove(toParent: self)
        }
    }

    init(drawerWidth: CGFloat) {
        super.init(nibName: nil, bundle: nil)
        self.drawerWidth = drawerWidth
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(panGesture)
    }

    func setDrawerState(_ newState: DrawerState, animated: Bool) {
        _containerView.isHidden = false
        let duration: TimeInterval = animated ? drawerAnimationDuration : 0

        let isDrawerAppearing = newState == .opened
        if _isDrawerAppearing != isDrawerAppearing {
            _isDrawerAppearing = isDrawerAppearing
            drawerViewController?.beginAppearanceTransition(isDrawerAppearing, animated: animated)
            mainViewController?.beginAppearanceTransition(!isDrawerAppearing, animated: animated)
        }

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                switch newState {
                case .closed:
                    self._drawerConstraint.constant = 0
                    self._containerView.backgroundColor = UIColor(white: 0, alpha: 0)
                case .opened:
                    self._drawerConstraint.constant = self.drawerWidth
                    self._containerView.backgroundColor = UIColor(
                        white: 0,
                        alpha: self.containerViewMaxAlpha
                    )
                }
                self._containerView.layoutIfNeeded()
            }, completion: { _ in
                if newState == .closed {
                    self._containerView.isHidden = true
                }

                self.drawerViewController?.endAppearanceTransition()
                self.mainViewController?.endAppearanceTransition()
                self._isDrawerAppearing = nil
            })
    }

    @objc private func handlePanGesture(_ sender: UIGestureRecognizer) {
        _containerView.isHidden = false
        if sender.state == .began {
            _panStartLocation = sender.location(in: view)
        }

        let delta = CGFloat(sender.location(in: view).x - _panStartLocation.x)
        let constant: CGFloat
        let backGroundAlpha: CGFloat
        let drawerState: DrawerState

        drawerState = _panDelta <= 0 ? .closed : .opened
        constant = min(_drawerConstraint.constant + delta, drawerWidth)
        backGroundAlpha = min(containerViewMaxAlpha, containerViewMaxAlpha * (abs(constant) / drawerWidth))

        _drawerConstraint.constant = constant
        _containerView.backgroundColor = UIColor(
            white: 0,
            alpha: backGroundAlpha
        )

        switch sender.state {
        case .changed:
            let isDrawerAppearing = drawerState != .opened
            if _isDrawerAppearing == nil {
                _isDrawerAppearing = isDrawerAppearing
                drawerViewController?.beginAppearanceTransition(isDrawerAppearing, animated: true)
                mainViewController?.beginAppearanceTransition(!isDrawerAppearing, animated: true)
            }

            _panStartLocation = sender.location(in: view)
            _panDelta = delta
        case .ended, .cancelled:
            setDrawerState(drawerState, animated: true)
        default:
            break
        }
    }

    @objc private func handleTapGesture(_ sender: UIGestureRecognizer) {
        setDrawerState(.closed, animated: true)
    }

}

extension DrawerContainerController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        switch gestureRecognizer {
        case panGesture:
            return drawerState == .opened
        default:
            return touch.view == gestureRecognizer.view
        }
    }

}

extension DrawerContainerController {
    func setupFullScreenConstraints(superView: UIView, subView: UIView) {
        NSLayoutConstraint.activate([
            subView.topAnchor.constraint(equalTo: superView.topAnchor),
            subView.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
            subView.bottomAnchor.constraint(equalTo: superView.bottomAnchor),
            subView.leadingAnchor.constraint(equalTo: superView.leadingAnchor)
        ])
    }
}
