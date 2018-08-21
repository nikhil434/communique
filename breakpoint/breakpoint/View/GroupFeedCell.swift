//
//  GroupFeedCell.swift
//  breakpoint
//
//  Created by Caleb Stultz on 7/25/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import UIKit

class GroupFeedCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var attachmentImage: UIImageView!
    @IBOutlet weak var attachMentImageWidth: NSLayoutConstraint!
    func configureCell(profileImage: UIImage, email: String, content: String, isMedia: Bool) {
        self.profileImage.image = profileImage
        self.emailLbl.text = email
        self.contentLbl.text = isMedia ? "Attachment" : content
        self.attachmentImage.isHidden = isMedia ? false: true
        self.attachMentImageWidth.constant = isMedia ? 25 : 0
    }
}
