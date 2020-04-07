//
//  GroupViewController.swift
//  Project6
//
//  Created by Paul Hudson on 03/08/2018.
//  Copyright © 2018 Hacking with Swift. All rights reserved.
//

import UIKit

class GroupViewController: UITableViewController {
    weak var delegate: ViewController?
    var group: ReminderGroup!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = group.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewReminder))
    }

    @objc func addNewReminder() {
        let ac = UIAlertController(title: "New Reminder", message: nil, preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "Add", style: .default) { action in
            guard let text = ac.textFields?[0].text else { return }
            self.addReminder(named: text)
        })

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(ac, animated: true)
    }

    func addReminder(named name: String) {
        let reminder = Reminder(title: name, isComplete: false)
        group.items.append(reminder)
        tableView.insertRows(at: [IndexPath(row: group.items.count - 1, section: 0)], with: .automatic)

        delegate?.update(group)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return group.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let reminder = group.items[indexPath.row]

        if reminder.isComplete {
            let attrs: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: 1,
                .foregroundColor: UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
            ]

            let attributedString = NSAttributedString(string: reminder.title, attributes: attrs)

            cell.textLabel?.attributedText = attributedString
        } else {
            cell.textLabel?.text = reminder.title
        }
        
        return cell
    }
}
