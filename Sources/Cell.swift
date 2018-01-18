/**
 *  https://github.com/tadija/AEConsole
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit

internal final class Cell: UITableViewCell {
    
    // MARK: - Constants
    
    internal static let identifier = "AEConsoleCell"
    
    // MARK: - Properties
    
    private let settings = Console.shared.settings
    
    // MARK: - Init
    
    internal override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        backgroundColor = UIColor.clear
        configureLabel()
    }
    
    private func configureLabel() {
        guard let label = textLabel else {
            return
        }
        label.font = settings.consoleFont
        label.textColor = settings.textColorWithOpacity
        label.numberOfLines = 1
        label.textAlignment = .left
    }
    
    // MARK: - Override
    
    internal override func prepareForReuse() {
        super.prepareForReuse()
        
        textLabel?.textColor = settings.textColorWithOpacity
    }
    
    internal override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = bounds
    }
    
}
