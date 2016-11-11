//
//  FeedVC.swift
//  Travellr
//
//  Created by Manish Gehani on 11/4/16.
//  Copyright © 2016 Manish Gehani. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var cameraImg: UIImageView!
    
    var posts = [Post]()                    //initialized so numberOfRowsInSection can be determined
    var imageSelected = false
    var imagePicker: UIImagePickerController!
    static let imageCache = NSCache()       //makes one instance of it globally available

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 350
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        initObservers()
    }
    
    func initObservers() {
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: {snapshot in
            
            self.posts = []             //we're emptying it out as we're gonna replace the data
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    print("Snap: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key                                      //key is the ID of the post
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]                     //will create a new cell for each post
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage        //in order to grab single instance of the static variable
            }
            
            cell.configureCell(post, img: img)
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        cameraImg.image = image
        imageSelected = true
    }
    
    @IBAction func selectImg(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        if let txt = postField.text where txt != "" {
            
            if let img = cameraImg.image where imageSelected == true {
                
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)! //compress the image to 20% of original
                let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)! //Alamofire requires everything to be converted to data
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")   //data is the first bit that we need to upload; name is gotten from imageshack; fileName can be anything as it will be overwritten by imageshack anyway; mimeType is the type of the file which is jpeg here
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    
                }) {encodingResult in
                    
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON(completionHandler: { response in
                            if let info = response.result.value as? Dictionary<String, AnyObject> {
                                
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    if let imgLink = links["image_link"] as? String {
                                        print("Link: \(imgLink)")
                                        self.postToFirebase(imgLink)
                                    }
                                }
                            }
                        })
                    case.Failure(let error):
                        print(error)
                    }
                }
                
            } else {
                self.postToFirebase(nil)    //we're not posting image here
            }
        }
    }
    
    func postToFirebase(imgUrl: String?) {
        var post: Dictionary<String, AnyObject> = ["description": postField.text!, "likes": 0]
        
        if imgUrl != nil {
            post["imageUrl"] = imgUrl!
        }
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        postField.text = ""
        cameraImg.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
}
