//
//  PostCell.swift
//  Travellr
//
//  Created by Manish Gehani on 11/4/16.
//  Copyright © 2016 Manish Gehani. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!

    private var _post: Post?
    
    var request: Request?               //is a Firebase object. We need this to cancel requests.
    var likeRef: FIRDatabaseReference!
    
    var post: Post? {
        return _post
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //Adding gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }

    func configureCell(post: Post, img: UIImage?) {
        self.showcaseImg.image = nil
        self._post = post
        self.likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            
            if img != nil {
                self.showcaseImg.image = img!            //if img is not nil, it means we have the image in our cache
            } else {
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: {request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!             //if-let required
                        self.showcaseImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post!.imageUrl!)
                    }
            })
            
            }
        } else {
            self.showcaseImg.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {           //in Firebase if .value is null, it will give us NSNull
                
                //This means we have not liked this post
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })

    }

    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let doesNotExist = snapshot.value as? NSNull {           //in Firebase if .value is null, it will give us NSNull
                
                //This means we have not liked this post
                self.likeImage.image = UIImage(named: "heart-full")
                self.post!.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post!.adjustLikes(false)
                self.likeRef.removeValue()
            }
            
            self.likesLbl.text = "\(self.post!.likes)"

        })
    }
}
