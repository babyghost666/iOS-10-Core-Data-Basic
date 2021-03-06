//
//  ItemDetailVC.swift
//  iOS 10 Core Data
//
//  Created by Peter Leung on 18/11/2016.
//  Copyright © 2016 winandmac Media. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var storePicker: UIPickerView!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfDetails: UITextField!
    @IBOutlet weak var imageThumbView: UIImageView!
    
    var storesArray = [Store]()
    var itemToEdit: Item?
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        
        storePicker.delegate = self
        storePicker.dataSource = self
        //deleteStores()
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        if !launchedBefore {
            let store = Store(context: context)
            store.name = "Best Buy"
            let store2 = Store(context: context)
            store2.name = "Tesco"
            let store3 = Store(context: context)
            store3.name = "Curry PC"
            let store4 = Store(context: context)
            store4.name = "K Mart"
            
            AppD.saveContext()
        }
        getStores()
        
        if itemToEdit != nil {
            loadItemData()
        }
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
    }
    
    func deleteStores(){
        let fetchRequest: NSFetchRequest<Store> = Store.fetchRequest()
        let delRequest: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        let coord = context.persistentStoreCoordinator
        do {
            try coord?.execute(delRequest, with: context)
        } catch {
            // TODO: handle the error
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let store = storesArray[row]
        return store.name
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return storesArray.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    @IBAction func savePressed(_ sender: Any) {
        var item: Item!
        let pic = Image(context: context)
        pic.image = imageThumbView.image
        
        
        if itemToEdit == nil {
            item = Item(context: context)
        } else {
            item = itemToEdit
        }
        
        guard let title = tfTitle.text, let price = tfPrice.text, let details = tfDetails.text else{
            return
        }
        item.title = title
        item.price = (price as NSString).doubleValue
        item.details = details
        item.toImage = pic
        
        item.toStore = storesArray[storePicker.selectedRow(inComponent: 0)]
        
        AppD.saveContext()
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    func getStores(){
        let fetchRequest: NSFetchRequest<Store> = Store.fetchRequest()
        do {
            self.storesArray = try context.fetch(fetchRequest)
            self.storePicker.reloadAllComponents()
        } catch {
            //error
        }
    }
    
    func loadItemData(){
        if let item = itemToEdit {
            tfTitle.text = item.title
            tfPrice.text = "\(item.price)"
            tfDetails.text = item.details
            imageThumbView.image = item.toImage?.image as? UIImage
            
            if let store = item.toStore {
                var index = 0
                
                repeat{
                    let s = storesArray[index]
                    if s.name == store.name {
                        storePicker.selectRow(index, inComponent: 0, animated: true)
                        break
                    }
                    index += 1
                } while (index < storesArray.count)
            }
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        if itemToEdit != nil {
            context.delete(itemToEdit!)
            AppD.saveContext()
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageThumbView.image = img
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
