//
//  FunPopMenu.swift
//  FunBox
//
//  Created by choarkinphe on 2020/12/2.
//

import UIKit
#if os(macOS)
public typealias Color = NSColor
#else
public typealias Color = UIColor
#endif

public typealias FunPopMenuAppearance = FunBox.PopMenu.Appearance
public typealias FunPopMenuManager = FunBox.PopMenu.Manager
public typealias FunPopMenu = FunBox.PopMenu
typealias PopMenu = FunBox.PopMenu

public protocol PopMenuElement {
    func asPopMenu() -> PopMenuAction
}
// MARK: CoreProtocol
/// Customize your own action and conform to `PopMenuAction` protocol.
public protocol PopMenuAction: PopMenuElement {
    /// Type alias for selection handler.
    typealias PopMenuActionHandler = (PopMenuAction) -> Void
    /// Title of the action.
    var title: String { get }
    
    /// Image of the action.
    var image: UIImage? { get }

    /// The handler of action.
//    var didSelect: PopMenuActionHandler? { get }
    
    /// The color to set for both label and icon.
    var tintColor: Color? { get }
    
    /// The font for label.
    var font: UIFont { get }
    
    /// Is the view highlighted by gesture.
    var highlighted: Bool { get set }
    
//    var showCutLine: Bool { get set }
}

extension PopMenuAction {
    public func asPopMenu() -> PopMenuAction {
        return self
    }
}

/// The object responsible for managing a pop menu `PopMenuViewController`
extension PopMenu {
    final public class Manager: NSObject {
        
        // MARK: - Properties
        
        /// Default manager singleton.
        public static let `default` = Manager()

        /// Determines whether to dismiss menu after an action is selected.
        public var dismissOnSelection: Bool = true
        
        /// The dismissal handler for pop menu.
        public var didDismiss: ((Bool) -> Void)?
        
        /// Determines whether to use haptics for menu selection.
        public var enableHaptics: Bool = true
        
        /// Appearance for passing on to pop menu.
        public var appearance: Appearance
        
        /// Every action item about to be displayed.
        public var actions: [PopMenuAction] = []
        
        /// Initializer with appearance.
        public init(appearance: Appearance = Appearance.default) {
            self.appearance = appearance
        }
        
        // MARK: - Important Methods
        /// Configure and load pop menu view controller.
        private func prepareViewController(sourceView: AnyObject?)-> PMViewController {
            let popMenu = PMViewController()
            popMenu.dismissOnSelection = dismissOnSelection
            popMenu.didDismiss = didDismiss
            popMenu.appearance = appearance
            popMenu.sourceView = sourceView
            popMenu.actions = actions
            popMenu.didSelect = didSelect
            popMenu.setAbsoluteSourceFrame()
//            self.popMenu = popMenu
            return popMenu
        }

        var popMenu: PMViewController?
        
        /// Pass a new action to pop menu.
        public func addAction(_ action: PopMenuElement) {
            actions.append(action.asPopMenu())
        }
        
        public func addActions(_ actions: [PopMenuElement]) {
            actions.forEach { (action) in
                self.actions.append(action.asPopMenu())
            }
        }
        
        private var didSelect: PopMenuActionHandler?
        public func select(_ handle: @escaping PopMenuActionHandler) {
            didSelect = handle
        }
        
        func clear() {
            actions.removeAll()
        }
        
    }
}

// MARK: - Presentations

extension FunPopMenuManager {
    
    /// Present the pop menu.
    ///
    /// - Parameters:
    ///   - sourceView: From which view and where exactly on the screen to be shown
    ///     (default: show in the center)
    ///
    ///   - above: Present above which controller
    ///     (default: use the top view controller)
    ///
    ///   - animated: Animate the presentation
    ///   - completion: Completion handler
    public func present(sourceView: AnyObject? = nil, on viewController: UIViewController? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
        let popMenu = prepareViewController(sourceView: sourceView)

        if let presentOn = viewController {
            presentOn.present(popMenu, animated: animated, completion: completion)
        } else {
            UIApplication.shared.fb.frontController?.present(popMenu, animated: animated, completion: completion)
        }
        
        clear()
    }
    
}



extension PopMenu {
    final public class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
        
        /// Source view's frame.
        private let sourceFrame: CGRect?
        
        /// Initializer with source view's frame.
        init(sourceFrame: CGRect?) {
            self.sourceFrame = sourceFrame
        }
        
        /// Duration of the transition.
        public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.138
        }
        
        /// Animate PopMenuViewController custom transition.
        public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let menuViewController = transitionContext.viewController(forKey: .to) as? PMViewController else { return }
            
            let containerView = transitionContext.containerView
            let view = menuViewController.view!
            view.frame = containerView.frame
            containerView.addSubview(view)
            
            prepareAnimation(menuViewController)
            
            let animationDuration = transitionDuration(using: transitionContext)
            let animations = {
                self.animate(menuViewController)
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: animations) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
        
        /// States before animation.
        fileprivate func prepareAnimation(_ viewController: PMViewController) {
            viewController.containerView.alpha = 0
            viewController.backgroundView.alpha = 0
            
            if let sourceFrame = sourceFrame {
                viewController.contentLeftConstraint.constant = sourceFrame.origin.x
                viewController.contentTopConstraint.constant = sourceFrame.origin.y
                viewController.contentWidthConstraint.constant = sourceFrame.size.width
                viewController.contentHeightConstraint.constant = sourceFrame.size.height
            }
        }
        
        /// Run the animation.
        fileprivate func animate(_ viewController: PMViewController) {
            viewController.containerView.alpha = 1
            viewController.backgroundView.alpha = 1
            
            let contentFrame = viewController.contentFrame
            viewController.contentLeftConstraint.constant = contentFrame.origin.x
            viewController.contentTopConstraint.constant = contentFrame.origin.y
            viewController.contentWidthConstraint.constant = contentFrame.size.width
            viewController.contentHeightConstraint.constant = contentFrame.size.height
            
            viewController.containerView.layoutIfNeeded()
        }
        
    }
}

extension PopMenu {
    final public class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
        
        /// The source view's frame.
        private let sourceFrame: CGRect?
        
        /// Initializer with source view's frame.
        init(sourceFrame: CGRect?) {
            self.sourceFrame = sourceFrame
        }
        
        /// Duration of the transition.
        public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.0982
        }
        
        /// Animate PopMenuViewController custom transition.
        public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let menuViewController = transitionContext.viewController(forKey: .from) as? PMViewController else { return }
            
            let containerView = transitionContext.containerView
            let view = menuViewController.view!
            view.frame = containerView.frame
            containerView.addSubview(view)
            
            let animationDuration = transitionDuration(using: transitionContext)
            let animations = {
                self.animate(menuViewController)
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: animations) { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
        
        /// Run the animation.
        fileprivate func animate(_ viewController: PMViewController) {
            viewController.containerView.alpha = 0
            viewController.backgroundView.alpha = 0
            
            viewController.containerView.transform = .init(scaleX: 0.55, y: 0.55)
        }
        
    }
}
// MARK: - ContentViewController
extension PopMenu {
    final public class PMViewController: UIViewController {
        struct Ariangle {
            var origin: CGPoint = .zero
            var direction: UIView.Effect.Direction = .top
        }
        // MARK: - Properties
        /// Appearance configuration.
        public var appearance = PopMenu.Manager.default.appearance
        
        var didSelect: PopMenuActionHandler?
        
        /// Background overlay that covers the whole screen.
        public let backgroundView = UIView()
        
        /// The blur overlay view for translucent illusion.
        private lazy var blurOverlayView: UIVisualEffectView = {
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = appearance.cornerRadius
            blurView.layer.masksToBounds = true
            blurView.isUserInteractionEnabled = false
            
            return blurView
        }()
        
        /// Main root view that has shadows.
        public let containerView = UIView()
        
        /// Main content view.
        public let contentView = GradientView()
        
        /// The view contains all the actions.
        public let actionsView = UIStackView()
        
        /// The source View to be displayed from.
        weak var sourceView: AnyObject?
        
        /// The absolute source frame relative to screen.
        private(set) var absoluteSourceFrame: CGRect?
        
        /// The calculated content frame.
        public lazy var contentFrame: CGRect = {
            return calculateContentFittingFrame()
        }()
        
        // MARK: - Configurations
        
        /// Determines whether to dismiss menu after an action is selected.
        public var dismissOnSelection: Bool = true
        
        /// Determines whether the pan gesture is enabled on the actions.
        public var enablePanGesture: Bool = true
        
        /// Determines whether enable haptics for iPhone 7 and up.
        public var haptics: Bool = true
        
        /// Handler for when the menu is dismissed.
        public var didDismiss: ((Bool) -> Void)?
        
        fileprivate var ariangle = Ariangle()
        
        // MARK: - Constraints
        
        private(set) var contentLeftConstraint: NSLayoutConstraint!
        private(set) var contentTopConstraint: NSLayoutConstraint!
        private(set) var contentWidthConstraint: NSLayoutConstraint!
        private(set) var contentHeightConstraint: NSLayoutConstraint!
        
        /// The UIView instance of source view.
        fileprivate lazy var sourceViewAsUIView: UIView? = {
            guard let sourceView = sourceView else { return nil }
            
            // Check if UIBarButtonItem
            if let sourceBarButtonItem = sourceView as? UIBarButtonItem {
                if let buttonView = sourceBarButtonItem.value(forKey: "view") as? UIView {
                    return buttonView
                }
            }
            
            if let sourceView = sourceView as? UIView {
                return sourceView
            }
            
            return nil
        }()
        
        /// Tap gesture to dismiss for background view.
        fileprivate lazy var tapGestureForDismissal: UITapGestureRecognizer = {
            let tapper = UITapGestureRecognizer(target: self, action: #selector(backgroundViewDidTap(_:)))
            tapper.cancelsTouchesInView = false
            tapper.delaysTouchesEnded = false
            
            return tapper
        }()
        
        /// Pan gesture to highligh actions.
        fileprivate lazy var panGestureForMenu: UIPanGestureRecognizer = {
            let panner = UIPanGestureRecognizer(target: self, action: #selector(menuDidPan(_:)))
            panner.maximumNumberOfTouches = 1
            
            return panner
        }()
        
        /// Actions of menu.
        public fileprivate(set) var actions: [PopMenuAction] = []
        
        /// Max content width allowed for the content to stretch to.
        fileprivate let maxContentWidth: CGFloat = UIScreen.main.bounds.size.width * 0.9
        
        // MARK: - View Life Cycle
        public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

            transitioningDelegate = self
            modalPresentationStyle = .overFullScreen
            modalPresentationCapturesStatusBarAppearance = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        /// Load view entry point.
        public override func loadView() {
            super.loadView()
            
            view.backgroundColor = .clear
            
            configureBackgroundView()
            configureContentView()
            configureActionsView()
        }
        
        /// Set absolute source frame relative to screen frame.
        fileprivate func setAbsoluteSourceFrame() {
            if let sourceView = sourceViewAsUIView {
                absoluteSourceFrame = sourceView.convert(sourceView.bounds, to: nil)
            }
        }

        // MARK: - Status Bar Appearance
        
        public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
            return .fade
        }
        
        /// Set status bar style.
        public override var preferredStatusBarStyle: UIStatusBarStyle {
            // If style defined, return
            if let statusBarStyle = appearance.statusBarStyle {
                return statusBarStyle
            }
            
            // Contrast of blur style
            let backgroundStyle = appearance.backgroundStyle
            if let blurStyle = backgroundStyle.blurStyle {
                switch blurStyle {
                case .dark:
                    return .lightContent
                default:
                    return .default
                }
            }
            
            // Contrast of dimmed color
            if let dimColor = backgroundStyle.dimColor {
                return dimColor.fb.contrasting == .white ? .lightContent : .default
            }
            
            return .lightContent
        }
        
        /// Handle when device orientation changed or container size changed.
        ///
        /// - Parameters:
        ///   - size: Changed size
        ///   - coordinator: Coordinator that manages the container
        public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            coordinator.animate(alongsideTransition: { context in
                self.configureBackgroundView()
                self.contentFrame = self.calculateContentFittingFrame()
                self.setupContentConstraints()
            })
            
            super.viewWillTransition(to: size, with: coordinator)
        }
        
    }
}

// MARK: - View Configurations
extension PopMenu.PMViewController {
    

    
    /// Setup the background view at the bottom.
    fileprivate func configureBackgroundView() {
        backgroundView.frame = view.frame
        backgroundView.backgroundColor = .clear
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addGestureRecognizer(tapGestureForDismissal)
        backgroundView.isUserInteractionEnabled = true
        
        let backgroundStyle = appearance.backgroundStyle
        
        // Blurred background
        if let isBlurred = backgroundStyle.isBlurred,
           isBlurred,
           let blurStyle = backgroundStyle.blurStyle {
            
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
            blurView.frame = backgroundView.frame
            
            backgroundView.addSubview(blurView)
        }
        
        // Dimmed background
        if let isDimmed = backgroundStyle.isDimmed,
           isDimmed,
           let color = backgroundStyle.dimColor,
           let opacity = backgroundStyle.dimOpacity {
            
            backgroundView.backgroundColor = color.withAlphaComponent(opacity)
        }
        
        view.insertSubview(backgroundView, at: 0)
    }
    
    /// Setup the content view.
    fileprivate func configureContentView() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addShadow(offset: .init(width: 0, height: 1), opacity: 0.5, radius: 20)
        containerView.layer.cornerRadius = appearance.cornerRadius
        containerView.backgroundColor = .clear
        
        view.addSubview(containerView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = appearance.cornerRadius
        contentView.layer.masksToBounds = true
        contentView.clipsToBounds = true
        
        let colors = appearance.colorStyle.backgroundColor.colors
        if colors.count > 0 {
            if colors.count == 1 {
                // Configure solid fill background.
                contentView.backgroundColor = colors.first?.withAlphaComponent(0.9)
                contentView.startColor = .clear
                contentView.endColor = .clear
            } else {
                // Configure gradient color.
                contentView.diagonalMode = true
                contentView.startColor = colors.first!
                contentView.endColor = colors.last!
                contentView.gradientLayer.opacity = 0.8
            }
        }
        
        containerView.addSubview(blurOverlayView)
        containerView.addSubview(contentView)
        
        setupContentConstraints()
    }
    
    /// Activate necessary constraints.
    fileprivate func setupContentConstraints() {
        contentLeftConstraint = containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: contentFrame.origin.x)
        contentTopConstraint = containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: contentFrame.origin.y + ((appearance.showAriangle && ariangle.direction == .top) ? appearance.ariangleSize.height : 0))
        contentWidthConstraint = containerView.widthAnchor.constraint(equalToConstant: contentFrame.size.width)
        contentHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: contentFrame.size.height - (appearance.showAriangle ? appearance.ariangleSize.height : 0))
        
        // Activate container view constraints
        NSLayoutConstraint.activate([
            contentLeftConstraint,
            contentTopConstraint,
            contentWidthConstraint,
            contentHeightConstraint
        ])
        // Activate content view constraints
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            contentView.topAnchor.constraint(equalTo: containerView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        // Activate blur overlay constraints
        NSLayoutConstraint.activate([
            blurOverlayView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            blurOverlayView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            blurOverlayView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurOverlayView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    /// Determine the fitting frame for content.
    ///
    /// - Returns: The fitting frame
    fileprivate func calculateContentFittingFrame() -> CGRect {
        var height: CGFloat
        
        if actions.count >= appearance.actionCountForScrollable {
            // Make scroll view
            height = CGFloat(appearance.actionCountForScrollable) * appearance.actionHeight
            height -= 20
        } else {
            height = CGFloat(actions.count) * appearance.actionHeight
        }
        
        let size = CGSize(width: calculateContentWidth(), height: height)
        let origin = calculateContentOrigin(with: size)
        
        return CGRect(origin: origin, size: size)
    }
    
    
    
    /// Determine where the menu should display.
    ///
    /// - Returns: The source origin point
    fileprivate func calculateContentOrigin(with size: CGSize) -> CGPoint {
        guard let sourceFrame = absoluteSourceFrame else { return CGPoint(x: view.center.x - size.width / 2, y: view.center.y - size.height / 2) }
        let minContentPos: CGFloat = UIScreen.main.bounds.size.width * 0.05
        let maxContentPos: CGFloat = UIScreen.main.bounds.size.width * 0.95
        
        // Get desired content origin point
        let offsetX = (size.width - sourceFrame.size.width ) / 2
//        let offsetY = (size.height - sourceFrame.size.width ) / 2
        var desiredOrigin = CGPoint(x: sourceFrame.origin.x - offsetX, y: sourceFrame.origin.y)
        
        ariangle.origin = CGPoint(x: (size.width - appearance.ariangleSize.width) / 2.0, y: -appearance.ariangleSize.height)
        
        if (desiredOrigin.x + size.width) > maxContentPos {
            desiredOrigin.x = maxContentPos - size.width
            ariangle.origin.x = size.width - appearance.cornerRadius - appearance.ariangleSize.width
        }
        if desiredOrigin.x < minContentPos {
            desiredOrigin.x = minContentPos
            ariangle.origin.x = appearance.cornerRadius
        }
        
//        var rect = CGRect(x: contentFrame.width - appearance.cornerRadius-appearance.ariangleSize.width, y: -appearance.ariangleSize.height, width: appearance.ariangleSize.width, height: appearance.ariangleSize.height)
//        if appearance.showAriangle {
            
//        }
        
        if desiredOrigin.y + size.height > view.bounds.height {
            desiredOrigin.y = min(desiredOrigin.y, sourceFrame.origin.y - size.height)
            ariangle.origin.y = size.height
            ariangle.direction = .bottom
        }
        
        // Move content in place
        translateOverflowX(desiredOrigin: &desiredOrigin, contentSize: size)
        translateOverflowY(desiredOrigin: &desiredOrigin, contentSize: size)
        
        desiredOrigin.x += appearance.contentOffset.x
        desiredOrigin.y += appearance.contentOffset.y
        
        return desiredOrigin
    }
    
    /// Move content into view if it's overflowed in X axis.
    ///
    /// - Parameters:
    ///   - desiredOrigin: The desired origin point
    ///   - contentSize: Content size
    fileprivate func translateOverflowX(desiredOrigin: inout CGPoint, contentSize: CGSize) {
        let edgePadding: CGFloat = 8
        // Check content in left or right side
        let leftSide = (desiredOrigin.x - view.center.x) < 0
        
        // Check view overflow
        let origin = CGPoint(x: leftSide ? desiredOrigin.x : desiredOrigin.x + contentSize.width, y: desiredOrigin.y)
        
        // Move accordingly
        if !view.frame.contains(origin) {
            let overflowX: CGFloat = (leftSide ? 1 : -1) * ((leftSide ? view.frame.origin.x : view.frame.origin.x + view.frame.size.width) - origin.x) + edgePadding
            
            desiredOrigin = CGPoint(x: desiredOrigin.x - (leftSide ? -1 : 1) * overflowX, y: origin.y)
        }
    }
    
    /// Move content into view if it's overflowed in Y axis.
    ///
    /// - Parameters:
    ///   - desiredOrigin: The desired origin point
    ///   - contentSize: Content size
    fileprivate func translateOverflowY(desiredOrigin: inout CGPoint, contentSize: CGSize) {
        let edgePadding: CGFloat
        
        let origin = CGPoint(x: desiredOrigin.x, y: desiredOrigin.y + contentSize.height)
        
        if #available(iOS 11.0, *) {
            edgePadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 8
        } else {
            edgePadding = 8
        }
        
        // Check content inside of view or not
        if !view.frame.contains(origin) {
            let overFlowY: CGFloat = origin.y - view.frame.size.height + edgePadding
            
            desiredOrigin = CGPoint(x: desiredOrigin.x, y: desiredOrigin.y - overFlowY)
        }
    }
    
    /// Determine the content width by the longest title possible.
    ///
    /// - Returns: The fitting width for content
    fileprivate func calculateContentWidth() -> CGFloat {
        var contentFitWidth: CGFloat = 0
        contentFitWidth += PopMenu.Manager.default.appearance.textPadding * 2
        
        // Calculate the widest width from action titles to determine the width
        if let action = actions.max(by: {
            let title1 = $0.title
            let title2 = $1.title
            return title1.count < title2.count
        }) {
            let sizingLabel = UILabel()
            sizingLabel.text = action.title
            
            let desiredWidth = sizingLabel.sizeThatFits(view.bounds.size).width
            contentFitWidth += desiredWidth
            
            contentFitWidth += appearance.iconSize.width
        }
        
        return min(contentFitWidth,maxContentWidth)
    }
    
    /// Setup actions view.
    fileprivate func configureActionsView() {
        actionsView.translatesAutoresizingMaskIntoConstraints = false
        actionsView.axis = .vertical
        actionsView.alignment = .fill
        actionsView.distribution = .fillEqually
        
        // Configure each action
        actions.forEach { action in
            let action_view = PopMenu.ActionItem(menu: action)
            if action.title != actions.last?.title {
                action_view.cutLine.isHidden = !appearance.showCutLine
            }
            // Give separator to each action but the last
            if action.title != actions.last?.title {
                addSeparator(to: view)
            }
            
            let tapper = UITapGestureRecognizer(target: self, action: #selector(menuDidTap(_:)))
            tapper.delaysTouchesEnded = false
            
            action_view.addGestureRecognizer(tapper)
            
            actionsView.addArrangedSubview(action_view)
        }
        
        // Check add scroll view or not
        if actions.count >= (appearance.actionCountForScrollable) {
            // Scrollable actions
            let scrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = !appearance.scrollIndicatorHidden
            scrollView.indicatorStyle = appearance.scrollIndicatorStyle
            scrollView.contentSize.height = appearance.actionHeight * CGFloat(actions.count)
            
            scrollView.addSubview(actionsView)
            contentView.addSubview(scrollView)
            
            NSLayoutConstraint.activate([
                scrollView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
                scrollView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            
            NSLayoutConstraint.activate([
                actionsView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                actionsView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                actionsView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                actionsView.heightAnchor.constraint(equalToConstant: scrollView.contentSize.height)
            ])
        } else {
            // Not scrollable
            actionsView.addGestureRecognizer(panGestureForMenu)
            
            contentView.addSubview(actionsView)
            
            NSLayoutConstraint.activate([
                actionsView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
                actionsView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
                actionsView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
                actionsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])
        }
        
        if appearance.showAriangle, let color = appearance.colorStyle.backgroundColor.colors.last {
            
            let rect = CGRect(origin: ariangle.origin, size: appearance.ariangleSize)
            
            containerView.fb.effect(.ariangle).direction(ariangle.direction).rect(rect).borderColor(color).draw()
        }

    }
    
    /// Add separator view for the given action view.
    ///
    /// - Parameters:
    ///   - separator: Separator style
    ///   - actionView: Action's view
    fileprivate func addSeparator(to actionView: UIView) {
        // Only setup separator if the style is neither 0 height or clear color
        guard appearance.itemSeparator != .none() else { return }
        
        let separator = appearance.itemSeparator
        
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = separator.color
        
        actionView.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.leftAnchor.constraint(equalTo: actionView.leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: actionView.rightAnchor),
            separatorView.bottomAnchor.constraint(equalTo: actionView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: separator.height)
        ])
    }
    
}

// MARK: - Gestures Control

extension PopMenu.PMViewController {
    
    /// Once the background view is tapped (for dismissal).
    @objc fileprivate func backgroundViewDidTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.isEqual(tapGestureForDismissal), !touchedInsideContent(location: gesture.location(in: view)) else { return }
        
        dismiss(animated: true) {
            // No selection made.
            self.didDismiss?(false)
        }
    }
    
    /// When the menu action gets tapped.
    @objc fileprivate func menuDidTap(_ gesture: UITapGestureRecognizer) {
        guard let attachedView = gesture.view as? PopMenu.ActionItem, let index = actions.firstIndex(where: { $0.title == attachedView.menu.title }) else { return }
        attachedView.actionSelected(animated: true)
        actionDidSelect(at: index)
    }
    
    /// When the pan gesture triggered in actions view.
    @objc fileprivate func menuDidPan(_ gesture: UIPanGestureRecognizer) {
        guard enablePanGesture else { return }
        
        switch gesture.state {
        case .began, .changed:
            if let index = associatedActionIndex(gesture) {
                var action = actions[index]
                // Must not be already highlighted
                guard !action.highlighted else { return }
                
                if haptics {
                    FunBox.Haptic.selection.generate()
                }
                
                // Highlight current action view.
                action.highlighted = true
                // Unhighlight other actions.
                for i in 0...(actions.count-1) {
                    if index != i {
                        actions[index].highlighted = false
                    }
                }
            }
        case .ended:
            // Unhighlight all actions.
            for index in 0...(actions.count-1) {
                actions[index].highlighted = false
            }
            // Trigger action selection.
            if let index = associatedActionIndex(gesture), let attachedView = gesture.view as? PopMenu.ActionItem {
                actionDidSelect(at: index)
                attachedView.actionSelected(animated: false)
            }
        default:
            return
        }
    }
    
    /// Check if touch is inside content view.
    fileprivate func touchedInsideContent(location: CGPoint) -> Bool {
        return containerView.frame.contains(location)
    }
    
    ///  Get the gesture associated action index.
    ///
    /// - Parameter gesture: Gesture recognizer
    /// - Returns: The index
    fileprivate func associatedActionIndex(_ gesture: UIGestureRecognizer) -> Int? {
        guard touchedInsideContent(location: gesture.location(in: view)) else { return nil }
        
        // Check which action is associated.
        let touchLocation = gesture.location(in: actionsView)
        // Get associated index for touch location.
        if let touchedView = actionsView.arrangedSubviews.filter({ return $0.frame.contains(touchLocation) }).first,
           let index = actionsView.arrangedSubviews.firstIndex(of: touchedView){
            return index
        }
        
        return nil
    }
    
    /// Triggers when an action is selected.
    ///
    /// - Parameter index: The index for action
    fileprivate func actionDidSelect(at index: Int) {

        if haptics {
            // Generate haptics
            if #available(iOS 10.0, *) {
                FunBox.Haptic.impact(.medium).generate()
            }
        }
        
        // Should dismiss or not
        if dismissOnSelection {
            dismiss(animated: true) {
                // Selection made.
                self.didDismiss?(true)
                // Notify delegate
                self.didSelect?(self.actions[index])
            }
        } else {
            // Notify delegate
            didSelect?(actions[index])
        }
    }
    
}

// MARK: - Transitioning Delegate
extension PopMenu.PMViewController: UIViewControllerTransitioningDelegate {
    
    /// Custom presentation animation.
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopMenu.PresentAnimationController(sourceFrame: absoluteSourceFrame)
    }
    
    /// Custom dismissal animation.
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopMenu.DismissAnimationController(sourceFrame: absoluteSourceFrame)
    }
    
}

// MARK: - The default PopMenu action class.
extension FunBox {
    public class PopMenu: PopMenuAction {
        
        
        /// Title of action.
        public let title: String
        
        /// Icon of action.
        public let image: UIImage?
        
        /// Handler of action when selected.
//        public let didSelect: PopMenuActionHandler?

        /// Text color of the label.
        public var tintColor: Color?
//            = PopMenu.Manager.default.appearance.colorStyle.actionColor.color
        
        public var font: UIFont = PopMenu.Manager.default.appearance.font
        
        /// Rounded corner radius for action view.
        public var cornerRadius: CGFloat = PopMenu.Manager.default.appearance.cornerRadius
        
        /// Inidcates if the action is being highlighted.
        public var highlighted: Bool = false
        
//        public var showCutLine: Bool = false
        
        /// Initializer.
        public init(title: String, image: UIImage? = nil, color: Color = PopMenu.Manager.default.appearance.colorStyle.actionColor.color) {
            self.title = title
            self.image = image
            self.tintColor = color
//            self.didSelect = didSelect
            
        }
        
    }
}

extension String: PopMenuElement {
    
    public func asPopMenu() -> PopMenuAction {
        let element = FunPopMenu(title: self)
        
        return element
    }
    
}

extension PopMenu {
    public final class GradientView: UIView {

        /// Gradient starting color.
        var startColor:   UIColor = .black { didSet { updateColors() }}
        
        /// Gradient ending color.
        var endColor:     UIColor = .white { didSet { updateColors() }}
        
        /// Gradient starting location.
        var startLocation: Double =   0.05 { didSet { updateLocations() }}
        
        /// Gradient ending location.
        var endLocation:   Double =   0.95 { didSet { updateLocations() }}
        
        /// Is horizontal gradient or not.
        var horizontalMode:  Bool =  false { didSet { updatePoints() }}
        
        /// Is diagonal gradient or not.
        var diagonalMode:    Bool =  false { didSet { updatePoints() }}
        
        /// The layer class type.
        override public class var layerClass: AnyClass { return CAGradientLayer.self }
        
        /// View's gradient layer.
        var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
        
        /// Update gradient points.
        func updatePoints() {
            if horizontalMode {
                gradientLayer.startPoint = diagonalMode ? CGPoint(x: 1, y: 0) : CGPoint(x: 0, y: 0.5)
                gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0.5)
            } else {
                gradientLayer.startPoint = diagonalMode ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
                gradientLayer.endPoint   = diagonalMode ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
            }
        }
        
        /// Update gradient locations.
        func updateLocations() {
            gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
        }
        
        /// Update gradient colors.
        func updateColors() {
            gradientLayer.colors    = [startColor.cgColor, endColor.cgColor]
        }
        
        /// Setup gradient properties.
        func setup() {
            updatePoints()
            updateLocations()
            updateColors()
        }
        
        /// Layout subviews override.
        override public func layoutSubviews() {
            super.layoutSubviews()
            
            setup()
        }
        
    }
}

// MARK: - PopMenuActionView
extension PopMenu {
    class ActionItem: UIView {
        private var _backgroundColor: Color = .white
        let menu: PopMenuAction
        var cutLine = UIView()
        init(menu: PopMenuAction, frame: CGRect = .zero) {
            self.menu = menu
            super.init(frame: frame)
            
            layer.cornerRadius = 14
            layer.masksToBounds = true
            
            var hasImage = false
            if let tintColor = menu.tintColor {
                iconImageView.tintColor = tintColor
                titleLabel.textColor = tintColor
                _backgroundColor = tintColor.fb.contrasting
                cutLine.backgroundColor = tintColor.fb.light
            }
            if let image = menu.image {
                hasImage = true
                addSubview(iconImageView)
                iconImageView.image = image.withRenderingMode(.alwaysTemplate)
                NSLayoutConstraint.activate([
                    iconImageView.widthAnchor.constraint(equalToConstant: PopMenu.Manager.default.appearance.iconSize.width),
                    iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),
                    iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PopMenu.Manager.default.appearance.iconPadding),
                    iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
                ])
            }
            
            titleLabel.text = menu.title
            addSubview(titleLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: hasImage ? iconImageView.trailingAnchor : leadingAnchor, constant: hasImage ? 8 : PopMenu.Manager.default.appearance.textPadding),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20),
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            
            cutLine.isHidden = true
            addSubview(cutLine)
//            NSLayoutConstraint.activate([
//                cutLine.trailingAnchor.constraint(equalTo: trailingAnchor),
//                cutLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
//                cutLine.bottomAnchor.constraint(equalTo: bottomAnchor),
//                cutLine.heightAnchor.constraint(equalToConstant: 1)
//            ])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            cutLine.frame = CGRect(x: 12, y: bounds.height - 0.5, width: bounds.width - 12, height: 0.5)
        }
        
        /// Title label view instance.
        private lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.isUserInteractionEnabled = false
            
            return label
        }()
        
        /// Icon image view instance.
        private lazy var iconImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        /// Highlight the view when panned on top,
        /// unhighlight the view when pan gesture left.
        func highlightActionView(_ highlight: Bool) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.26, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 9, options: self.menu.highlighted ? UIView.AnimationOptions.curveEaseIn : UIView.AnimationOptions.curveEaseOut, animations: {
                    self.transform = self.menu.highlighted ? CGAffineTransform.identity.scaledBy(x: 1.09, y: 1.09) : .identity
                    self.backgroundColor = self.menu.highlighted ? self._backgroundColor.withAlphaComponent(0.25) : .clear
                }, completion: nil)
            }
        }
        
        /// When the action is selected.
        func actionSelected(animated: Bool) {
            // Trigger handler.
//            menu.didSelect?(self.menu)
            
            // Animate selection
            guard animated else { return }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.175, animations: {
                    self.transform = CGAffineTransform.identity.scaledBy(x: 0.915, y: 0.915)
                    self.backgroundColor = self._backgroundColor.withAlphaComponent(0.18)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.175, animations: {
                        self.transform = .identity
                        self.backgroundColor = .clear
                    })
                })
            }
        }
    }
}

// MARK: - Appearance for PopMenu.
extension PopMenu {
    /// Appearance for PopMenu.
    /// Use for configuring custom styles and looks.
    public struct Appearance {
        
        public static var `default`: Appearance {
            return Appearance()
        }
        
        /// Background and tint colors.
        public var colorStyle: ColorStyle = .default()
        
        /// Background style.
        public var backgroundStyle: BackgroundStyle = .dimmed(color: .black, opacity: 0.4)
        
        /// The font for labels.
        public var font: UIFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        /// Corner radius for rounded corners.
        public var cornerRadius: CGFloat = 24
        
        /// How tall each action is.
        public var actionHeight: CGFloat = 50
        
        /// How many actions are the breakpoint to trigger scrollable.
        public var actionCountForScrollable: UInt = 6
        
        /// The scroll indicator style when the actions are scrollable.
        public var scrollIndicatorStyle: UIScrollView.IndicatorStyle = .white
        
        /// Hide the scroll indicator or not when the actions are scrollable.
        public var scrollIndicatorHidden = false
        
        /// The separator style for each action.
        public var itemSeparator: ActionSeparator = .none()
        
        /// The status bar style of the pop menu.
        public var statusBarStyle: UIStatusBarStyle?
        
        /// The presentation style
//        public var presentationStyle: PresentationStyle = .cover()
        
        public var showCutLine: Bool = false
        
        public var showAriangle: Bool = false
        
        public var ariangleSize: CGSize = CGSize(width: 14, height: 14)
        
        // MARK: - Constants
        
        public var textPadding: CGFloat = 25
        
        public var iconPadding: CGFloat = 18
        
        public var iconSize: CGSize = CGSize(width: 27, height: 27)
        
        public var contentOffset: CGPoint = .zero
        
    }
    /// Background styles for PopMenu.
    public struct BackgroundStyle {
        
        // MARK: - Dimmed Style
        
        /// Determines is the style in dimmed mode.
        public let isDimmed: Bool?
        
        /// If dimmed, store the dim color.
        public let dimColor: Color?
        
        /// If dimmed, store the dim opacity.
        public let dimOpacity: CGFloat?
        
        // MARK: - Blur Style
        
        /// Determines is the style in blur mode.
        public let isBlurred: Bool?
        
        /// If blurred, store the blur style.
        public let blurStyle: UIBlurEffect.Style?
        
        // MARK: - Initializers
        
        /// Quick setter for dimmed mode.
        public static func dimmed(color: Color, opacity: CGFloat) -> BackgroundStyle {
            return BackgroundStyle(isDimmed: true, dimColor: color, dimOpacity: opacity, isBlurred: nil, blurStyle: nil)
        }
        
        /// Quick setter for blurred mode.
        public static func blurred(_ style: UIBlurEffect.Style) -> BackgroundStyle{
            return BackgroundStyle(isDimmed: nil, dimColor: nil, dimOpacity: nil, isBlurred: true, blurStyle: style)
        }
        
        /// No background style.
        public static func none() -> BackgroundStyle{
            return BackgroundStyle(isDimmed: nil, dimColor: nil, dimOpacity: nil, isBlurred: nil, blurStyle: nil)
        }
        
    }
    /// Color structure for PopMenu color styles.
    public struct ColorStyle {
        
        /// Background color instance.
        public var backgroundColor: ActionBackgroundColor
        
        /// Action tint color instance.
        public var actionColor: ActionColor
        
        /// Compose the color.
        public static func configure(background: ActionBackgroundColor, action: ActionColor) -> ColorStyle {
            return ColorStyle(backgroundColor: background, actionColor: action)
        }
        
        /// Get default background and action color.
        public static func `default`() -> ColorStyle {
            return ColorStyle(backgroundColor: .gradient(fill: #colorLiteral(red: 0.168627451, green: 0.168627451, blue: 0.168627451, alpha: 1), #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)), actionColor: .tint(.white))
        }
    }
    /// Background color structure to control PopMenu backgrounds.
    public struct ActionBackgroundColor {
        
        /// All colors (only one if solid color, or else it's gradient)
        public let colors: [Color]
        
        /// Fill an only solid color into the colors palette.
        public static func solid(fill color: Color) -> ActionBackgroundColor {
            return .init(colors: [color])
        }
        
        /// Fill gradient colors into the colors palette.
        public static func gradient(fill colors: Color...) -> ActionBackgroundColor {
            return .init(colors: colors)
        }
        
    }
    /// Action color structure to control PopMenu actions.
    public struct ActionColor {
        
        /// Tint color.
        public let color: Color
        
        /// Get action's color instance with given color.
        public static func tint(_ color: Color) -> ActionColor {
            return ActionColor(color: color)
        }
        
    }
    /// Action separator structure to control PopMenu item separators.
    public struct ActionSeparator: Equatable {
        
        /// Height of separator.
        public let height: CGFloat
        
        /// Color of separator.
        public let color: Color
        
        /// Fill separator color with given color and height.
        public static func fill(_ color: Color = Color.white.withAlphaComponent(0.5), height: CGFloat = 0.5) -> ActionSeparator {
            return ActionSeparator(height: height, color: color)
        }
        
        /// Get separator instance with no separator style.
        public static func none() -> ActionSeparator {
            return ActionSeparator(height: 0, color: .clear)
        }
        
        /// Equatable operation.
        public static func == (lhs: ActionSeparator, rhs: ActionSeparator) -> Bool {
            return lhs.color == rhs.color && lhs.height == rhs.height
        }
        
    }
    ///
//    public struct PresentationStyle {
//
//        /// The direction enum for the menu.
//        public let direction: Direction
//
//        /// Custom offset coordinates.
//        public let offset: CGPoint?
//
//        /// The default presentation that covers the source view.
//        public static func cover() -> PresentationStyle {
//            return PresentationStyle(direction: .none, offset: nil)
//        }
//
//        /// The custom presentation that shows near the source view in a direction and offset.
//        public static func near(_ direction: Direction, offset: CGPoint? = nil) -> PresentationStyle {
//            return PresentationStyle(direction: direction, offset: offset)
//        }
//    }
    
//    public enum Direction {
//        case top
//        case left
//        case right
//        case bottom
//        case none
//    }
}

fileprivate extension UIView {
    
    /// Quick configuration to give the view shadows.
    func addShadow(offset: CGSize = .zero, opacity: Float = 0.65, radius: CGFloat = 20, color: UIColor = .black) {
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowColor = color.cgColor
        layer.masksToBounds = false
    }
    
}
