//
//  FeedViewController.swift
//  Instagrammmm
//
//  Created by Shy Shy on 3/13/21.
//

import UIKit
import Parse
import AlamofireImage


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
  
        var posts = [PFObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        
        // Do any additional setup after loading the view.
        
    }
    
    //after finsihing compose, want the tableview to refresh, use code below.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //do the query, based on Parse, class name is "Posts"
        //inquery the post, storage the data, then reload the TableView
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = 20
        
        query.findObjectsInBackground { (posts, Error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        //create an array of PFObject above override func viewDidLoad
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        //use indexPath to grab particular post
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.userNameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as? String
        
        //grab image URL
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af.setImage(withURL: url)
        
        return cell
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    }

