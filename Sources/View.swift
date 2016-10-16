//
// View.swift
//
// Copyright (c) 2016 Marko Tadić <tadija@me.com> http://tadija.net
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import AELog

class View: UIView {
    
    // MARK: - Constants
    
    fileprivate struct Layout {
        static let FilterHeight: CGFloat = 60
        static let FilterExpandedTop: CGFloat = 0
        static let FilterCollapsedTop: CGFloat = -Layout.FilterHeight
        
        static let MenuWidth: CGFloat = 300
        static let MenuHeight: CGFloat = 50
        static let MenuExpandedLeading: CGFloat = -Layout.MenuWidth
        static let MenuCollapsedLeading: CGFloat = -75
        
        static let MagicNumber: CGFloat = 10
    }
    
    // MARK: - Outlets
    
    let tableView = UITableView()
    let textField = UITextField()
    
    fileprivate let filterView = UIView()
    fileprivate let filterStack = UIStackView()
    fileprivate var filterViewTop: NSLayoutConstraint!
    
    fileprivate let exportLogButton = UIButton()
    fileprivate let linesCountStack = UIStackView()
    fileprivate let linesTotalLabel = UILabel()
    fileprivate let linesFilteredLabel = UILabel()
    fileprivate let clearFilterButton = UIButton()
    
    fileprivate let menuView = UIView()
    fileprivate let menuStack = UIStackView()
    fileprivate var menuViewLeading: NSLayoutConstraint!
    
    fileprivate let toggleToolbarButton = UIButton()
    fileprivate let forwardTouchesButton = UIButton()
    fileprivate let autoFollowButton = UIButton()
    fileprivate let clearLogButton = UIButton()
    
    fileprivate let updateOpacityGesture = UIPanGestureRecognizer()
    fileprivate let hideConsoleGesture = UITapGestureRecognizer()
    
    // MARK: - Properties
    
    var isOnScreen = false {
        didSet {
            isHidden = !isOnScreen
            
            if isOnScreen {
                updateUI()
            }
        }
    }
    
    var currentOffsetX = -Layout.MagicNumber
    
    fileprivate let brain = AEConsole.shared.brain
    fileprivate let config = Config.shared
    
    fileprivate var isToolbarActive = false {
        didSet {
            currentTopInset = isToolbarActive ? topInsetLarge : topInsetSmall
        }
    }
    
    fileprivate var opacity: CGFloat = 1.0 {
        didSet {
            configureColors(with: opacity)
        }
    }
    
    fileprivate var currentTopInset = Layout.MagicNumber
    fileprivate var topInsetSmall = Layout.MagicNumber
    fileprivate var topInsetLarge = Layout.MagicNumber + Layout.FilterHeight
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        configureUI()
        opacity = config.opacity
    }
    
    // MARK: - Override
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateContentLayout()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        let filter = hitView?.superview == filterStack
        let menu = hitView?.superview == menuStack
        if !filter && !menu && forwardTouchesButton.isSelected {
            return nil
        }
        
        return hitView
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if config.isShakeGestureEnabled {
                toggleUI()
            }
        }
    }
    
    // MARK: - API
    
    func toggleUI() {
        textField.resignFirstResponder()
        
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: { () -> Void in
            self.isOnScreen = !self.isOnScreen
        }, completion:nil)
    }
    
    func updateUI() {
        tableView.reloadData()
        
        updateLinesCountLabels()
        updateContentLayout()
        
        if autoFollowButton.isSelected {
            scrollToBottom()
        }
    }
    
}

extension View {
    
    // MARK: - Helpers
    
    fileprivate func updateLinesCountLabels() {
        linesTotalLabel.text = "□ \(brain.lines.count)"
        let filteredCount = brain.isFilterActive ? brain.filteredLines.count : 0
        linesFilteredLabel.text = "■ \(filteredCount)"
    }
    
    fileprivate func updateContentLayout() {
        let maxWidth = max(brain.contentWidth, bounds.width)
        
        let newFrame = CGRect(x: 0.0, y: 0.0, width: maxWidth, height: bounds.height)
        tableView.frame = newFrame
        
        UIView.animate(withDuration: 0.3, animations: { [unowned self] () -> Void in
            let inset = Layout.MagicNumber
            let newInset = UIEdgeInsets(top: self.currentTopInset, left: inset, bottom: inset, right: maxWidth)
            self.tableView.contentInset = newInset
        })
        
        updateContentOffset()
    }
    
    private func updateContentOffset() {
        if isToolbarActive {
            if tableView.contentOffset.y == -topInsetSmall {
                let offset = CGPoint(x: tableView.contentOffset.x, y: -topInsetLarge)
                tableView.setContentOffset(offset, animated: true)
            }
        } else {
            if tableView.contentOffset.y == -topInsetLarge {
                let offset = CGPoint(x: tableView.contentOffset.x, y: -topInsetSmall)
                tableView.setContentOffset(offset, animated: true)
            }
        }
        tableView.flashScrollIndicators()
    }
    
    fileprivate func scrollToBottom() {
        let diff = tableView.contentSize.height - tableView.bounds.size.height
        if diff > 0 {
            let offsetY = diff + Layout.MagicNumber
            let bottomOffset = CGPoint(x: currentOffsetX, y: offsetY)
            tableView.setContentOffset(bottomOffset, animated: false)
        }
    }
    
    fileprivate func configureColors(with opacity: CGFloat) {
        tableView.backgroundColor = config.backColor.withAlphaComponent(opacity)
        
        let textOpacity = max(0.3, opacity * 1.1)
        config.textColorWithOpacity = config.textColor.withAlphaComponent(textOpacity)
        
        let toolbarOpacity = min(0.7, opacity * 1.5)
        filterView.backgroundColor = config.backColor.withAlphaComponent(toolbarOpacity)
        menuView.backgroundColor = config.backColor.withAlphaComponent(toolbarOpacity)
        
        let borderOpacity = toolbarOpacity / 2
        filterView.layer.borderColor = config.backColor.withAlphaComponent(borderOpacity).cgColor
        filterView.layer.borderWidth = 1.0
        menuView.layer.borderColor = config.backColor.withAlphaComponent(borderOpacity).cgColor
        menuView.layer.borderWidth = 1.0
        
        // refresh text color
        tableView.reloadData()
    }
    
}

extension View {
    
    // MARK: - UI
    
    fileprivate func configureUI() {
        configureOutlets()
        configureLayout()
    }
    
    private func configureOutlets() {
        configureTableView()
        configureFilterView()
        configureMenuView()
        configureGestures()
    }
    
    private func configureTableView() {
        tableView.rowHeight = config.rowHeight
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
    }
    
    private func configureFilterView() {
        configureFilterStack()
        configureFilterLinesCount()
        configureFilterTextField()
        configureFilterButtons()
    }
    
    private func configureFilterStack() {
        filterView.alpha = 0.3
        filterStack.axis = .horizontal
        filterStack.alignment = .fill
        filterStack.distribution = .fill
        
        let stackInsets = UIEdgeInsets(top: Layout.MagicNumber, left: 0, bottom: 0, right: 0)
        filterStack.layoutMargins = stackInsets
        filterStack.isLayoutMarginsRelativeArrangement = true
    }
    
    private func configureFilterLinesCount() {
        linesCountStack.axis = .vertical
        linesCountStack.alignment = .fill
        linesCountStack.distribution = .fillEqually
        let stackInsets = UIEdgeInsets(top: Layout.MagicNumber, left: 0, bottom: Layout.MagicNumber, right: 0)
        linesCountStack.layoutMargins = stackInsets
        linesCountStack.isLayoutMarginsRelativeArrangement = true
        
        linesTotalLabel.font = config.consoleFont
        linesTotalLabel.textColor = config.textColor
        linesTotalLabel.textAlignment = .left
        
        linesFilteredLabel.font = config.consoleFont
        linesFilteredLabel.textColor = config.textColor
        linesFilteredLabel.textAlignment = .left
    }
    
    private func configureFilterTextField() {
        let textColor = config.textColor
        textField.autocapitalizationType = .none
        textField.tintColor = textColor
        textField.font = config.consoleFont.withSize(14)
        textField.textColor = textColor
        let attributes = [NSForegroundColorAttributeName : textColor.withAlphaComponent(0.5)]
        let placeholderText = NSAttributedString(string: "Type here...", attributes: attributes)
        textField.attributedPlaceholder = placeholderText
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(Layout.MagicNumber, 0, 0)
    }
    
    private func configureFilterButtons() {
        exportLogButton.setTitle("🌙", for: .normal)
        exportLogButton.addTarget(self, action: #selector(didTapExportButton(_:)), for: .touchUpInside)
        
        clearFilterButton.setTitle("🔥", for: .normal)
        clearFilterButton.addTarget(self, action: #selector(didTapFilterClearButton(_:)), for: .touchUpInside)
    }
    
    private func configureMenuView() {
        configureMenuStack()
        configureMenuButtons()
    }
    
    private func configureMenuStack() {
        menuView.alpha = 0.3
        menuView.layer.cornerRadius = Layout.MagicNumber
        
        menuStack.axis = .horizontal
        menuStack.alignment = .fill
        menuStack.distribution = .fillEqually
    }
    
    private func configureMenuButtons() {
        toggleToolbarButton.setTitle("☀️", for: .normal)
        forwardTouchesButton.setTitle("⚡️", for: .normal)
        forwardTouchesButton.setTitle("✨", for: .selected)
        autoFollowButton.setTitle("🌟", for: .normal)
        autoFollowButton.setTitle("💫", for: .selected)
        clearLogButton.setTitle("🔥", for: .normal)
        
        autoFollowButton.isSelected = true
        
        toggleToolbarButton.addTarget(self, action: #selector(didTapToggleToolbarButton(_:)), for: .touchUpInside)
        forwardTouchesButton.addTarget(self, action: #selector(didTapForwardTouchesButton(_:)), for: .touchUpInside)
        autoFollowButton.addTarget(self, action: #selector(didTapAutoFollowButton(_:)), for: .touchUpInside)
        clearLogButton.addTarget(self, action: #selector(didTapClearLogButton(_:)), for: .touchUpInside)
    }
    
    private func configureGestures() {
        configureUpdateOpacityGesture()
        configureHideConsoleGesture()
    }
    
    private func configureUpdateOpacityGesture() {
        updateOpacityGesture.addTarget(self, action: #selector(didRecognizeUpdateOpacityGesture(_:)))
        menuView.addGestureRecognizer(updateOpacityGesture)
    }
    
    private func configureHideConsoleGesture() {
        hideConsoleGesture.numberOfTouchesRequired = 2
        hideConsoleGesture.numberOfTapsRequired = 2
        hideConsoleGesture.addTarget(self, action: #selector(didRecognizeHideConsoleGesture(_:)))
        addGestureRecognizer(hideConsoleGesture)
    }
    
}

extension View {
    
    // MARK: - Layout
    
    fileprivate func configureLayout() {
        configureHierarchy()
        configureViewsForLayout()
        configureConstraints()
    }
    
    private func configureHierarchy() {
        addSubview(tableView)
        
        filterStack.addArrangedSubview(exportLogButton)
        
        linesCountStack.addArrangedSubview(linesTotalLabel)
        linesCountStack.addArrangedSubview(linesFilteredLabel)
        filterStack.addArrangedSubview(linesCountStack)
        
        filterStack.addArrangedSubview(textField)
        filterStack.addArrangedSubview(clearFilterButton)
        
        filterView.addSubview(filterStack)
        addSubview(filterView)
        
        menuStack.addArrangedSubview(toggleToolbarButton)
        menuStack.addArrangedSubview(forwardTouchesButton)
        menuStack.addArrangedSubview(autoFollowButton)
        menuStack.addArrangedSubview(clearLogButton)
        menuView.addSubview(menuStack)
        addSubview(menuView)
    }
    
    private func configureViewsForLayout() {
        filterView.translatesAutoresizingMaskIntoConstraints = false
        filterStack.translatesAutoresizingMaskIntoConstraints = false
        
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuStack.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureConstraints() {
        configureFilterViewConstraints()
        configureFilterStackConstraints()
        configureFilterStackSubviewConstraints()
        
        configureMenuViewConstraints()
        configureMenuStackConstraints()
    }
    
    private func configureFilterViewConstraints() {
        let leading = filterView.leadingAnchor.constraint(equalTo: leadingAnchor)
        let trailing = filterView.trailingAnchor.constraint(equalTo: trailingAnchor)
        let height = filterView.heightAnchor.constraint(equalToConstant: Layout.FilterHeight)
        filterViewTop = filterView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.FilterCollapsedTop)
        NSLayoutConstraint.activate([leading, trailing, height, filterViewTop])
    }
    
    private func configureFilterStackConstraints() {
        let leading = filterStack.leadingAnchor.constraint(equalTo: filterView.leadingAnchor)
        let trailing = filterStack.trailingAnchor.constraint(equalTo: filterView.trailingAnchor)
        let top = filterStack.topAnchor.constraint(equalTo: filterView.topAnchor)
        let bottom = filterStack.bottomAnchor.constraint(equalTo: filterView.bottomAnchor)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }
    
    private func configureFilterStackSubviewConstraints() {
        let exportButtonWidth = exportLogButton.widthAnchor.constraint(equalToConstant: 75)
        let linesCountWidth = linesCountStack.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        let clearFilterButtonWidth = clearFilterButton.widthAnchor.constraint(equalToConstant: 75)
        NSLayoutConstraint.activate([exportButtonWidth, linesCountWidth, clearFilterButtonWidth])
    }
    
    private func configureMenuViewConstraints() {
        let width = menuView.widthAnchor.constraint(equalToConstant: Layout.MenuWidth + Layout.MagicNumber)
        let height = menuView.heightAnchor.constraint(equalToConstant: Layout.MenuHeight)
        let centerY = menuView.centerYAnchor.constraint(equalTo: centerYAnchor)
        menuViewLeading = menuView.leadingAnchor.constraint(equalTo: trailingAnchor, constant: Layout.MenuCollapsedLeading)
        NSLayoutConstraint.activate([width, height, centerY, menuViewLeading])
    }
    
    private func configureMenuStackConstraints() {
        let leading = menuStack.leadingAnchor.constraint(equalTo: menuView.leadingAnchor)
        let trailing = menuStack.trailingAnchor.constraint(equalTo: menuView.trailingAnchor, constant: -Layout.MagicNumber)
        let top = menuStack.topAnchor.constraint(equalTo: menuView.topAnchor)
        let bottom = menuStack.bottomAnchor.constraint(equalTo: menuView.bottomAnchor)
        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }
    
}

extension View {
    
    // MARK: - Actions
    
    func didTapToggleToolbarButton(_ sender: UIButton) {
        toggleToolbar()
    }
    
    func didTapForwardTouchesButton(_ sender: UIButton) {
        forwardTouchesButton.isSelected = !forwardTouchesButton.isSelected
        aelog("Forward Touches [\(forwardTouchesButton.isSelected)]")
    }
    
    func didTapAutoFollowButton(_ sender: UIButton) {
        autoFollowButton.isSelected = !autoFollowButton.isSelected
        aelog("Auto Follow [\(autoFollowButton.isSelected)]")
    }
    
    func didTapClearLogButton(_ sender: UIButton) {
        brain.clearLog()
    }
    
    func didTapExportButton(_ sender: UIButton) {
        brain.exportAllLogLines()
    }
    
    func didTapFilterClearButton(_ sender: UIButton) {
        textField.resignFirstResponder()
        if !brain.isEmpty(textField.text) {
            brain.filterText = nil
        }
        textField.text = nil
    }
    
    func didRecognizeUpdateOpacityGesture(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            if isToolbarActive {
                let xTranslation = sender.translation(in: menuView).x
                if abs(xTranslation) > (3 * Layout.MagicNumber) {
                    let location = sender.location(in: menuView)
                    let opacity = opacityForLocation(location)
                    self.opacity = opacity
                }
            }
        }
    }
    
    func didRecognizeHideConsoleGesture(_ sender: UITapGestureRecognizer) {
        toggleUI()
    }
    
    // MARK: - Helpers
    
    private func opacityForLocation(_ location: CGPoint) -> CGFloat {
        let calculatedOpacity = ((location.x * 1.0) / 300)
        let minOpacity = max(0.1, calculatedOpacity)
        let maxOpacity = min(0.9, minOpacity)
        return maxOpacity
    }
    
    private func toggleToolbar() {
        filterViewTop.constant = isToolbarActive ? Layout.FilterCollapsedTop : Layout.FilterExpandedTop
        menuViewLeading.constant = isToolbarActive ? Layout.MenuCollapsedLeading : Layout.MenuExpandedLeading
        let alpha: CGFloat = isToolbarActive ? 0.3 : 1.0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.filterView.alpha = alpha
            self.menuView.alpha = alpha
            self.filterView.layoutIfNeeded()
            self.menuView.layoutIfNeeded()
        })
        
        if isToolbarActive {
            textField.resignFirstResponder()
        }
        
        isToolbarActive = !isToolbarActive
    }
    
}
