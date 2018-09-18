/**
 *  https://github.com/tadija/AEConsole
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit

internal final class Cell: UITableViewCell {
    
    // MARK: - Constants
    
    internal static let identifier = "AEConsoleCell"

    // MARK: Outlets

    let label = UILabel()
    
    // MARK: - Properties
    
    private let settings = Console.shared.settings
    
    // MARK: - Init
    
    internal override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func commonInit() {
        backgroundColor = UIColor.clear
        configureLayout()
        configureLabel()
    }

    private func configureLayout() {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        let leading = label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let trailing = label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        let top = label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4)
        let bottom = label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)

        NSLayoutConstraint.activate([leading, trailing, top, bottom])
    }
    
    private func configureLabel() {
        label.font = settings.consoleFont
        label.textColor = settings.textColorWithOpacity
        label.numberOfLines = 0
        label.textAlignment = .left
    }
    
    // MARK: - Override
    
    internal override func prepareForReuse() {
        super.prepareForReuse()
        
        label.textColor = settings.textColorWithOpacity
    }

}
