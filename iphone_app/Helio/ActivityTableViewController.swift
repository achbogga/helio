//
//  ActivityTableViewController.swift
//  Helio
//
//  Created by Michelle Rueda on 7/20/24.
//

import Foundation
import UIKit

class ActivityTableViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var items: [String] = ["whatsup", "what now"]
  
  // MARK: - Properties
  lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.delegate = self
    tableView.dataSource = self
    return tableView
  }()
  
  override func viewDidLoad() {
      super.viewDidLoad()
      setupTableView()
  }
  
  
  func setupTableView() {
          tableView = UITableView(frame: CGRect(x: 20, y: 40, width: view.bounds.width - 40, height: 300))
          tableView.delegate = self
          tableView.dataSource = self
          tableView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
          tableView.layer.cornerRadius = 10
          view.addSubview(tableView)
      }
      
      // MARK: - UITableViewDataSource methods
      
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return items.count
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
          cell.textLabel?.text = items[indexPath.row]
          cell.backgroundColor = .clear
          cell.textLabel?.textColor = .white
          return cell
      }
      
      // MARK: - UITableViewDelegate methods
      
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          print("Selected item: \(items[indexPath.row])")
          tableView.deselectRow(at: indexPath, animated: true)
      }

}
