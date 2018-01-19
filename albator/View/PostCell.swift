//
//  PostCell.swift
//  albator
//
//  Created by Vincent Pacquet on 1/9/18.
//  Copyright © 2018 aerobace. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!

    var post: Post!
    var likesRef: DatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }

    func configureCell(post: Post) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        DataService.ds.REF_USER_CURRENT.child("displayName").observe(.value, with: { (snapshot) in
            let username = snapshot.value as? String
            self.usernameLbl.text = username
        })
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        
        let urlImage = URL(string: post.imageURL)
        self.postImg.kf.setImage(with: urlImage)
        if post.profileURL != "" {
            let urlProfile = URL(string: post.profileURL)
            self.profileImg.kf.setImage(with: urlProfile)
        }
        
        likesRef.observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        }
    }
    
    @objc func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value) { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        }
    }
    
}
