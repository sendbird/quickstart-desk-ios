//
//  InboxViewController.UITableViewDelegate.swift
//  Quickstart
//
//  Created by Jaesung Lee on 2021/12/20.
//

import UIKit

extension InboxViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        handleEmptyResultView(shouldShow: tickets.count == 0, error: nil)
        return tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InboxTicketTableViewCell.identifier, for: indexPath) as? InboxTicketTableViewCell else { return UITableViewCell() }
        
        cell.configure(ticket: tickets[indexPath.row])
        
        if indexPath.row == self.tickets.count - 1 {
            self.loadTickets()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openTicket(tickets[indexPath.row])
    }
}

