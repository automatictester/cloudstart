import UIKit

class InstanceTableViewController: UITableViewController {
    
    var instances: Instances = InstanceReader.get()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshInstanceList), for: .valueChanged)
        self.refreshControl = refreshControl
        
    }
    
    @objc func refreshInstanceList() {
        // TODO: implement logic
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instances.size()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellIdentifier")
        }
        
        cell!.textLabel!.text = instances.get(index: indexPath.row).name
        cell!.detailTextLabel!.text = instances.get(index: indexPath.row).status
        if (instances.get(index: indexPath.row).status == "Terminated") {
            cell!.textLabel?.textColor = UIColor.lightGray
            cell!.detailTextLabel?.textColor = UIColor.lightGray
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // TODO: implement logic
    }
    
    @IBAction func logout(_ sender: Any) {
        self.performSegue(withIdentifier: "doLogout", sender: self)
    }
}
