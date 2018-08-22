//
//  GroupFeedVC.swift
//  breakpoint
//
//  Created by Caleb Stultz on 7/25/17.
//  Copyright © 2017 Caleb Stultz. All rights reserved.
//

import UIKit
import Firebase
import MessageUI
import FirebaseStorage

class GroupFeedVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var membersLbl: UILabel!
    @IBOutlet weak var sendBtnView: UIView!
    @IBOutlet weak var messageTextField: InsetTextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var attachmentBtn: UIButton!
    @IBOutlet weak var sentEmailButton: UIButton!
    @IBOutlet weak var attachmentViewerView: UIView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var attachmentCloseButton: UIButton!
    
    var group: Group?
    var groupMessages = [Message]()
    
    private let storage = Storage.storage().reference()
    
    func initData(forGroup group: Group) {
        self.group = group
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTitleLbl.text = group?.groupTitle
        DataService.instance.getEmailsFor(group: group!) { (returnedEmails) in
            self.membersLbl.text = returnedEmails.joined(separator: ", ")
        }
        
        DataService.instance.REF_GROUPS.observe(.value) { (snapshot) in
            DataService.instance.getAllMessagesFor(desiredGroup: self.group!, handler: { (returnedGroupMessages) in
                self.groupMessages = returnedGroupMessages
                self.tableView.reloadData()
                
                if self.groupMessages.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.groupMessages.count - 1, section: 0), at: .none, animated: true)
                }
            })
        }
    }
    
    func configureViews() {
        sendBtnView.bindToKeyboard()
        tableView.delegate = self
        tableView.dataSource = self
        sentEmailButton.isHidden = MFMailComposeViewController.canSendMail() ? false : true
    }
    
    @IBAction func sendBtnWasPressed(_ sender: Any) {
        if messageTextField.text != "" {
            messageTextField.isEnabled = false
            sendBtn.isEnabled = false
            attachmentBtn.isEnabled = false
            DataService.instance.uploadPost(withMessage: messageTextField.text!, isMedia: false, forUID: Auth.auth().currentUser!.uid, withGroupKey: group?.key, sendComplete: { (complete) in
                if complete {
                    self.messageTextField.text = ""
                    self.messageTextField.isEnabled = true
                    self.sendBtn.isEnabled = true
                    self.attachmentBtn.isEnabled = true
                }
            })
        }
    }
    
    @IBAction func didPressAttachmentButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismissDetail()
    }
    
    @IBAction func didPressSentEmailButton(_ sender: Any) {
        showEmailPopUp()
    }
    
    @IBAction func didPressAttachmentCloseButton(_ sender: Any) {
        attachmentViewerView.isHidden = true
    }
    //MARK:- Helper Methods
    func showEmailPopUp() {
        DataService.instance.getEmailsFor(group: group!) { (returnedEmails) in
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            let recipients = returnedEmails.filter { $0 != Auth.auth().currentUser?.email }
            composeVC.setToRecipients(recipients)
            self.present(composeVC, animated: true, completion: nil)
        }
        
    }
    
    private func sendPhoto(_ image: UIImage) {
        sendBtn.isEnabled = false
        attachmentBtn.isEnabled = false
        uploadImage(image, toGroup: group!.key) { [weak self] url in
            guard let `self` = self else {
                return
            }
            guard let url = url else {
                return
            }
            DataService.instance.uploadPost(withMessage: url.absoluteString, isMedia: true, forUID: Auth.auth().currentUser!.uid, withGroupKey: self.group?.key, sendComplete: { (complete) in
                if complete {
                    self.sendBtn.isEnabled = true
                    self.attachmentBtn.isEnabled = true
                }
            })
            
        }
    }
    
    private func uploadImage(_ image: UIImage, toGroup groupKey: String, completion: @escaping (URL?) -> Void) {
    
        guard let data = UIImageJPEGRepresentation(image, 0.4) else {
            completion(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child(groupKey).child(imageName).putData(data, metadata: metadata) { meta, error in
            completion(meta?.downloadURL())
        }
    }
    
    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        Utility.showLoadingIndicator()
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        ref.getData(maxSize: megaByte) { data, error in
            Utility.hideLoadingIndicator()
            guard let imageData = data else {
                completion(nil)
                return
            }
            
            completion(UIImage(data: imageData))
        }
    }
}

extension GroupFeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupFeedCell", for: indexPath) as? GroupFeedCell else { return UITableViewCell() }
        let message = groupMessages[indexPath.row]
        
        DataService.instance.getUsername(forUID: message.senderId) { (email) in
            cell.configureCell(profileImage: UIImage(named: "defaultProfileImage")!, email: email, content: message.content, isMedia: message.isMedia)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = groupMessages[indexPath.row]
        if message.isMedia {
            downloadImage(at: URL(string: message.content)!) { (image) in
                self.attachmentViewerView.isHidden = false
                self.attachmentImageView.image = image
            }
        }
    }
}

extension GroupFeedVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension GroupFeedVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        print(newImage.size)
        sendPhoto(newImage)
        dismiss(animated: true)
    }
}















