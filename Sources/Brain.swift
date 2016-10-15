//
// Brain.swift
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

import Foundation

class AEConsoleBrain: NSObject, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // MARK: Outlets
    
    var consoleView: AEConsoleView!
    
    // MARK: Properties
    
    fileprivate let settings = AEConsoleSettings.sharedInstance
    
    var lines = [Line]()
    var filteredLines = [Line]()
    
    var contentWidth: CGFloat = 0.0
    
    var filterText: String? {
        didSet {
            filterActive = !isEmpty(filterText)
        }
    }
    
    var filterActive = false {
        didSet {
            updateFilter()
            updateInterfaceIfNeeded()
        }
    }
    
    // MARK: API
    
    func configureConsoleUIWithAppDelegate(_ delegate: UIApplicationDelegate) {
        guard let _window = delegate.window, let window = _window else { return }
        
        let console = AEConsoleView()
        console.frame = window.bounds
        console.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        console.onScreen = settings.consoleAutoStart
        window.addSubview(console)
        
        consoleView = console
        consoleView.tableView.dataSource = self
        consoleView.tableView.delegate = self
        consoleView.textField.delegate = self
    }
    
    func addLogLine(_ logLine: Line) {
        let calculatedLineWidth = widthForLine(logLine)
        if calculatedLineWidth > contentWidth {
            contentWidth = calculatedLineWidth
        }
        
        if filterActive {
            guard let filter = filterText else { return }
            if logLine.description.contains(filter) {
                filteredLines.append(logLine)
            }
        }
        
        lines.append(logLine)
        
        updateInterfaceIfNeeded()
    }
    
    // MARK: Helpers
    
    fileprivate func updateFilter() {
        if filterActive {
            guard let filter = filterText else { return }
            aelog("Filter Lines [\(filterActive)] - <\(filter)>")
            let filtered = lines.filter({ $0.description.localizedCaseInsensitiveContains(filter) })
            filteredLines = filtered
        } else {
            aelog("Filter Lines [\(filterActive)]")
            filteredLines.removeAll()
        }
    }
    
    fileprivate func updateInterfaceIfNeeded() {
        if consoleView.onScreen {
            consoleView.updateUI()
        }
    }
    
    fileprivate func widthForLine(_ line: Line) -> CGFloat {
        let text = line.description
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: settings.consoleRowHeight)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        let attributes = [NSFontAttributeName : settings.consoleFont]
        let nsText = text as NSString
        let size = nsText.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        let width = size.width
        return width
    }
    
    func isEmpty(_ text: String?) -> Bool {
        guard let text = text else { return true }
        let characterSet = CharacterSet.whitespacesAndNewlines
        let isTextEmpty = text.trimmingCharacters(in: characterSet).isEmpty
        return isTextEmpty
    }
    
    // MARK: Actions
    
    func clearLog() {
        lines.removeAll()
        filteredLines.removeAll()
        updateInterfaceIfNeeded()
    }
    
    func exportAllLogLines() {
        let stringLines = lines.map({ $0.description })
        let log = stringLines.joined(separator: "\n")
        
        if isEmpty(log) {
            aelog("Log is empty, nothing to export here.")
        } else {
            let filename = "\(Date().timeIntervalSince1970).aelog"
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentsURL = URL(fileURLWithPath: documentsPath)
            let fileURL = documentsURL.appendingPathComponent(filename)
            
            do {
                try log.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                aelog("Log is exported to path: \(fileURL)")
            } catch {
                aelog(error)
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = filterActive ? filteredLines : lines
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AEConsoleCell.identifier) as! AEConsoleCell
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rows = filterActive ? filteredLines : lines
        let logLine = rows[indexPath.row]
        cell.textLabel?.text = logLine.description
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            consoleView.currentOffsetX = scrollView.contentOffset.x
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        consoleView.currentOffsetX = scrollView.contentOffset.x
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if !isEmpty(textField.text) {
            filterText = textField.text
        }
        return true
    }
    
}
