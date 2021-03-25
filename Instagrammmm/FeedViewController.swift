//
//  FeedViewController.swift
//  Instagrammmm
//
//  Created by Shy Shy on 3/13/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var posts = [PFObject]()
    var numberOfPost: Int!
    var selectedPost: PFObject!
    //var comment = [PFObject]()
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //myRefreshControl.add....self, action: #selector()-the selector when the refresher get trigger, for: .valueChanged)
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        //add below to see the loading wheel
        tableView.refreshControl = myRefreshControl
        
        commentBar.inputTextView.placeholder = "Add a comment...."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHiddent(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillBeHiddent(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    //hacking the framework
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        //return true (don't want to show it by default, use below
        return showsCommentBar
    }
    
    //after finsihing compose, want the tableview to refresh, use code below.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
           
        
        
        //do the query, based on Parse, class name is "Posts"
        //inquery the post, storage the data, then reload the TableView
        let query = PFQuery(className: "Posts")
        //not only we fetch the ("author", we need "comments" & "(each comments fetch from the related author)") ('","","" - are the keys)
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 35
        
        query.findObjectsInBackground { (posts, Error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
                
                self .myRefreshControl.endRefreshing()
                
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        //create the comment
       
        let comment = PFObject(className: "Comments")
        //  comment["text"] = "This is a random comment"
        //  comment["post"] = posts
        //  comment["author"] = PFUser.current()!
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground {(success, Error) in
            if success {
                print("Another comment saved")
            } else {
                print("Error saving another comment")
            }
        }
        tableView.reloadData()
    
    
        //clear & dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
        }
     
    
    @objc func loadPosts() {
        
        //do the query, based on Parse, class name is "Posts"
        //inquery the post, storage the data, then reload the TableView
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        numberOfPost = 20
        query.limit = 40
        
        
        query.findObjectsInBackground { (posts, Error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
                
                self .myRefreshControl.endRefreshing()
                
            }
        }
        
    }
    
    func loadMorePosts() {
        
        //do the query, based on Parse, class name is "Posts"
        //inquery the post, storage the data, then reload the TableView
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.limit = self.numberOfPost + 20
        
        query.findObjectsInBackground { (posts, Error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
                
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //# of comments+1, for the actual post, one for each comment
        let post = posts[section]
        //grab the comment (?? nil coalescing operator - convenient way to express default value)
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        //return 1, then return comments.count+1 have the row shows up, use #OfRowInSection, now it's 2 as the "add comment cell"
        return comments.count + 2
    }
    //give each post its own section, each section have different # of rows
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        //how to tell what type of cell I return. which one is the "Post Cell", the 0 row
        if indexPath.row == 0 {
            //create an array of PFObject above override func viewDidLoad
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            //use indexPath to grab particular post
            
            let user = post["author"] as! PFUser
            cell.userNameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as? String
            
            //grab image URL
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af.setImage(withURL: url)
            
            return cell
        } else if indexPath.row <= comments.count {
            print(indexPath.row)
            print(comments.count)
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            //indexPath.row-1 = the first comment
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
        /*  let cell = UITableViewCell()
         return cell */
    }
    
    //create an array of PFObject above override func viewDidLoad
    //let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
    //use indexPath to grab particular post
    //let post = posts[indexPath.row]
    
    /*    let user = post["author"] as! PFUser
     cell.userNameLabel.text = user.username
     
     cell.captionLabel.text = post["caption"] as? String
     
     //grab image URL
     let imageFile = post["image"] as! PFFileObject
     let urlString = imageFile.url!
     let url = URL(string: urlString)!
     
     cell.photoView.af.setImage(withURL: url)
     
     return cell
     
     }
     */
    //choose a post to add comment. everytime I select a table, a post, will add this change comments depend on how many time I click on the photo
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //video 4 start over //not [indexpath.row]
        let post = posts[indexPath.section]
        //let comment = PFObject(className: "Comments")
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        /*
         //Below is the fake comment
         comment["text"] = "This is a random comment"
         comment["post"] = post
         comment["author"] = PFUser.current()!
         //comments - make up, every post should have an array called "comments"
         post.add(comment, forKey: "comments")
         
         post.saveInBackground { (success, Error) in
         if success {
         print("Comment saved")
         } else {
         print("Error saving comment")
         }
         }
         */
        
        //if you are the last cell, go ahead to show it.
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            //earse the keyboard
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
            
        }
      
        
    }
    
    
    
    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        //passing the XML
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        
        //let delegate = UIApplication.shared.delegate as! AppDelegate
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate
        
        else {
            return
        }
        
        delegate.window?.rootViewController = loginViewController
        
        
    }
    
    
}

