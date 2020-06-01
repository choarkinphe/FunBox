//
//  TableViewController.swift
//  FunBox_Example
//
//  Created by choarkinphe on 2020/5/11.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import FunBox


class TableViewController: UITableViewController {
    override init(style: UITableView.Style) {
        super.init(style: style)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        view.backgroundColor = UIColor.red
        
        print(rt.options?.params)
        
//        var arefreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 120))
//        arefreshControl.attributedTitle = NSAttributedString(string: "正在刷新")
//        arefreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
//        refreshControl = arefreshControl
        tableView.fb.refresher.text("下拉刷新").timeOut(3).tintColor(.orange).complete { (refresher) in
            refresher.attributedTitle = NSAttributedString(string: "正在刷新")
            print("开始刷新")
        }
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        print(sender.isRefreshing)
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            sender.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
