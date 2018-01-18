/**
 *  https://github.com/tadija/AEConsole
 *  Copyright (c) Marko Tadić 2016-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit
import AELog

class Brain: NSObject {
    
    // MARK: - Outlets
    
    var console: View!
    
    // MARK: - Properties
    
    fileprivate let settings = Settings.shared

    var lines = [Line]()
    var filteredLines = [Line]()
    
    var contentWidth: CGFloat = 0.0
    
    var filterText: String? {
        didSet {
            isFilterActive = !isEmpty(filterText)
        }
    }
    
    var isFilterActive = false {
        didSet {
            updateFilter()
            updateInterfaceIfNeeded()
        }
    }
    
    // MARK: - API

    func configureConsole(in window: UIWindow?) {
        guard let window = window else { return }
        console = createConsoleView(in: window)
        console.tableView.dataSource = self
        console.tableView.delegate = self
        console.textField.delegate = self
    }
    
    func addLogLine(_ line: Line) {
        calculateContentWidth(for: line)
        updateFilteredLines(with: line)
        lines.append(line)
        updateInterfaceIfNeeded()
    }
    
    func isEmpty(_ text: String?) -> Bool {
        guard let text = text else { return true }
        let characterSet = CharacterSet.whitespacesAndNewlines
        let isTextEmpty = text.trimmingCharacters(in: characterSet).isEmpty
        return isTextEmpty
    }
    
    // MARK: - Actions
    
    func clearLog() {
        lines.removeAll()
        filteredLines.removeAll()
        updateInterfaceIfNeeded()
    }
    
    func exportAllLogLines() {
        let stringLines = lines.map({ $0.description })
        let log = stringLines.joined(separator: "\n")
        
        if isEmpty(log) {
            logToDebugger("Log is empty, nothing to export here.")
        } else {
            exportLog(log)
        }
    }
    
}

extension Brain {
    
    // MARK: - Helpers
    
    fileprivate func updateFilter() {
        if isFilterActive {
            applyFilter()
        } else {
            clearFilter()
        }
    }
    
    private func applyFilter() {
        guard let filter = filterText else { return }
        logToDebugger("Filter Lines [\(isFilterActive)] - <\(filter)>")
        let filtered = lines.filter({ $0.description.localizedCaseInsensitiveContains(filter) })
        filteredLines = filtered
    }
    
    private func clearFilter() {
        logToDebugger("Filter Lines [\(isFilterActive)]")
        filteredLines.removeAll()
    }
    
    fileprivate func updateInterfaceIfNeeded() {
        if console.isOnScreen {
            console.updateUI()
        }
    }
    
    fileprivate func createConsoleView(in window: UIWindow) -> View {
        let view = View()
        
        view.frame = window.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.isOnScreen = false
        window.addSubview(view)
        
        return view
    }
    
    fileprivate func calculateContentWidth(for line: Line) {
        let calculatedLineWidth = getWidth(for: line)
        if calculatedLineWidth > contentWidth {
            contentWidth = calculatedLineWidth
        }
    }
    
    fileprivate func updateFilteredLines(with line: Line) {
        if isFilterActive {
            guard let filter = filterText else { return }
            if line.description.contains(filter) {
                filteredLines.append(line)
            }
        }
    }
    
    private func getWidth(for line: Line) -> CGFloat {
        let text = line.description
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: settings.rowHeight)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        let attributes = [NSAttributedStringKey.font : settings.consoleFont]
        let nsText = text as NSString
        let size = nsText.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        let width = size.width
        return width
    }
    
    fileprivate func exportLog(_ log: String) {
        let filename = "\(Date().timeIntervalSince1970).aelog"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath: documentsPath)
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        do {
            try log.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            logToDebugger("Log is exported to path: \(fileURL)")
        } catch {
            logToDebugger("\(error)")
        }
    }
    
}

extension Brain: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = isFilterActive ? filteredLines : lines
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier) as! Cell
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rows = isFilterActive ? filteredLines : lines
        let logLine = rows[indexPath.row]
        cell.textLabel?.text = logLine.description
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            console.currentOffsetX = scrollView.contentOffset.x
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        console.currentOffsetX = scrollView.contentOffset.x
    }
    
}

extension Brain: UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if !isEmpty(textField.text) {
            filterText = textField.text
        }
        return true
    }
    
}
