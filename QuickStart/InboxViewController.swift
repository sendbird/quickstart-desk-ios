//
//  InboxViewController.swift
//  Quickstart
//
//  Created by Minhyuk Kim on 2021/11/25.
//

import UIKit
import SendBirdDesk
import SendBirdUIKit

class InboxViewController: UIViewController {
    enum Page: Int {
        case open, closed
    }
    
    @IBOutlet var ticketTableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet var openTabButton: UIButton!
    @IBOutlet var openTabButtonLine: UIView!
    
    @IBOutlet var closedTabButton: UIButton!
    @IBOutlet var closedTabButtonLine: UIView!
    
    @IBOutlet var emptyResultView: UIView!
    @IBOutlet var emptyResultImageView: UIImageView!
    @IBOutlet var emptyResultLabel: UILabel!
    @IBOutlet var emptyResultButton: UIButton!
    
    // MARK: Tickets
    var tickets: [SBDSKTicket] = []
    
    var currentPage = Page.open
    
    var ticketsOffset: Int = 0
    var hasMoreTickets = true
    var isLoadingTickest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openTabButton.setTitleColor(UIColor(named: "color_gray"), for: .normal)
        openTabButton.setTitleColor(UIColor(named: "color_primary_sendbird"), for: .disabled)

        closedTabButton.setTitleColor(UIColor(named: "color_gray"), for: .normal)
        closedTabButton.setTitleColor(UIColor(named: "color_primary_sendbird"), for: .disabled)
        
        let ticketRefreshControl = UIRefreshControl()
        ticketTableView.refreshControl = ticketRefreshControl
        ticketRefreshControl.addTarget(self, action: #selector(refreshTicketTable), for: .valueChanged)
        
        ticketTableView.register(UINib(nibName: "InboxTicketTableViewCell", bundle: nil), forCellReuseIdentifier: InboxTicketTableViewCell.identifier)
        
        ticketTableView.delegate = self
        ticketTableView.dataSource = self
        
        refreshTicketTable()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "iconSettingsFilled")!.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(showSettings)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        
        refreshTicketTable(showActivityIndicator: true)
    }

    @objc
    func showSettings() {
        self.performSegue(withIdentifier: "showSettings", sender: nil)
    }
    
    @IBAction func retryTickets(_ sender: Any) {
        refreshTicketTable()
    }
    
    @IBAction func viewOpenTickets(_ sender: Any) {
        currentPage = .open
        
        openTabButton.isEnabled = false
        openTabButtonLine.isHidden = false
        
        closedTabButton.isEnabled = true
        closedTabButtonLine.isHidden = true
        
        refreshTicketTable(showActivityIndicator: true)
    }
    
    
    @IBAction func viewClosedTickets(_ sender: Any) {
        currentPage = .closed
        
        closedTabButton.isEnabled = false
        closedTabButtonLine.isHidden = false
        
        openTabButton.isEnabled = true
        openTabButtonLine.isHidden = true
        
        refreshTicketTable(showActivityIndicator: true)
    }
    
    // MARK: Retrieve tickets (Opened / Closed)
    func loadTickets() {
        guard hasMoreTickets else {
            self.ticketTableView.refreshControl?.endRefreshing()
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            return
        }
        
        if isLoadingTickest { return }
        isLoadingTickest = true
        
        switch currentPage {
            case .open:
                SBDSKTicket.getOpenedList(withOffset: Int(ticketsOffset)) { [weak self] tickets, hasNext, error in
                    guard let self = self else { return }
                    
                    defer { self.isLoadingTickest = false }
                    
                    guard let tickets = tickets, error == nil else {
                        self.handleEmptyResultView(shouldShow: true, error: error)
                        return
                    }
                    
                    self.handleTicketListResponse(tickets: tickets, hasNext: hasNext)
                }
            case .closed:
                SBDSKTicket.getClosedList(withOffset: Int(ticketsOffset)) { [weak self] tickets, hasNext, error in
                    guard let self = self else { return }
                    
                    defer { self.isLoadingTickest = false }
                    
                    guard let tickets = tickets, error == nil else {
                        self.handleEmptyResultView(shouldShow: true, error: error)
                        return
                    }
                    
                    self.handleTicketListResponse(tickets: tickets, hasNext: hasNext)
                }
        }
    }
    
    func handleEmptyResultView(shouldShow: Bool, error: Error?) {
        emptyResultView.isHidden = !shouldShow
        
        if error == nil {
            emptyResultButton.isHidden = true
            emptyResultImageView.image = UIImage(named: "iconMessage")
            emptyResultLabel.text = "No conversations yet."
        } else {
            emptyResultButton.isHidden = false
            emptyResultImageView.image = UIImage(named: "iconError")
            emptyResultLabel.text = "Something is wrong."
        }
    }
    
    @objc
    func refreshTicketTable(showActivityIndicator: Bool = false) {
        DispatchQueue.main.async {
            self.hasMoreTickets = true
            self.ticketsOffset = 0
            self.tickets.removeAll()
//            self.ticketTableView.reloadData()
            
            if showActivityIndicator {
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.isHidden = false
            }
            
            self.loadTickets()
        }
    }
    
    func handleTicketListResponse(tickets: [SBDSKTicket], hasNext: Bool) {
        DispatchQueue.main.async {
            self.ticketTableView.refreshControl?.endRefreshing()
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            
            self.hasMoreTickets = hasNext
            self.ticketsOffset += tickets.count
            self.tickets.append(contentsOf: tickets)
            self.ticketTableView.reloadData()
        }
    }
    
    // MARK: Create ticket
    @IBAction func createTicket(_ sender: Any) {
        guard let currentUser = SBUGlobals.CurrentUser else { return }
        let userID = currentUser.refinedNickname()
        let title = String(Date().timeIntervalSince1970)
        
        SBDSKTicket.createTicket(withTitle: title, userName: userID) { [weak self] ticket, error in
            guard let self = self else { return }
            guard let ticket = ticket, error == nil else {
                // Handler error
                return
            }
            self.openTicket(ticket)
        }
    }
    
    func openTicket(_ ticket: SBDSKTicket) {
        let chatVC = ChatViewController(channel: ticket.channel!, messageListParams: nil)
        let nav = UINavigationController(rootViewController: chatVC)
        chatVC.ticket = ticket
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}


