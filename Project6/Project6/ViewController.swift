//
//  ViewController.swift
//  Project6
//
//  Created by Paul Hudson on 03/08/2018.
//  Copyright © 2018 Hacking with Swift. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UITableViewController {
    var groups = [ReminderGroup]()
    var selectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Multiminder"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewGroup))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleNotifications))
        
        load()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UNUserNotificationCenter.current().requestAuthorization(options: .alert) { granted, _ in
            if granted == false {
                print("We need permissions!")
            }
        }
    }
    
    @objc func addNewGroup() {
        let ac = UIAlertController(title: "New Reminder Group", message: "What should this reminder group be called?", preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "Add", style: .default) { action in
            guard let text = ac.textFields?[0].text else { return }
            self.addGroup(named: text)
        })

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(ac, animated: true)
    }

    func addGroup(named name: String) {
        let group = ReminderGroup(name: name, items: [])
        groups.append(group)
        selectedIndex = groups.count - 1

        tableView.insertRows(at: [IndexPath(row: selectedIndex ?? 0, section: 0)], with: .automatic)
        show(group)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let group = groups[indexPath.row]
        cell.textLabel?.text = group.name

        if group.items.count == 1 {
            cell.detailTextLabel?.text = "1 reminder"
        } else {
            cell.detailTextLabel?.text = "\(group.items.count) reminders"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = groups[indexPath.row]
        selectedIndex = indexPath.row
        show(group)
    }
    
    @objc func scheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        for group in groups {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            for reminder in group.items {
                guard !reminder.isComplete else { continue }
                
                let content = UNMutableNotificationContent()
                content.title = reminder.title
                content.threadIdentifier = group.name
                content.summaryArgument = "\(group.name)"
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                center.add(request) { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

    func show(_ group: ReminderGroup) {
        guard let groupViewController = storyboard?.instantiateViewController(withIdentifier: "Group") as? GroupViewController else {
            fatalError("Unable to load group view controller")
        }

        groupViewController.delegate = self
        groupViewController.group = group
        navigationController?.pushViewController(groupViewController, animated: true)
    }

    func update(_ group: ReminderGroup) {
        guard let selectedIndex = selectedIndex else {
            fatalError("Attempted to update a group without a selection.")
        }

        groups[selectedIndex] = group
        let indexPath = IndexPath(row: selectedIndex, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)

        save()
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: "Reminders") else { return }
        let decoder = JSONDecoder()

        if let savedGroups = try? decoder.decode([ReminderGroup].self, from: data) {
            groups = savedGroups
        }
    }

    func save() {
        let encoder = JSONEncoder()

        if let data = try? encoder.encode(groups) {
            UserDefaults.standard.set(data, forKey: "Reminders")
        }
    }
}

