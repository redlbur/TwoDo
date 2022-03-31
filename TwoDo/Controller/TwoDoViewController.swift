//
//  ViewController.swift
//  TwoDo
//
//  Created by Mederbek on 26/3/22.
//

import UIKit
import CoreData

class TwoDoViewController: UITableViewController {
  
  var holderArray = [Holder]()
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadHolder()
    
  }
  
  //MARK: - Add Button Pressed
  
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    
    var textFiled = UITextField()
    
    let alert = UIAlertController.init(title: "Add Category", message: "", preferredStyle: .alert)
    let action = UIAlertAction(title: "Add", style: .default) { action in
      let newCategory = Holder(context: self.context)
      newCategory.category = textFiled.text
      self.holderArray.append(newCategory)
      self.tableView.reloadData()
      self.saveHolder()
    }
    
    
    alert.addTextField { alertTextFiled in
      alertTextFiled.placeholder = "Create"
      textFiled = alertTextFiled
    }
    
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  
  
  //MARK: - TableView DataSource Method
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return holderArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TwoDoCell", for: indexPath)
    let item = holderArray[indexPath.row]
    cell.textLabel?.text = item.category
    return cell
  }
  
  //MARK: - TableView Delegate Method
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "goToList", sender: self)
    tableView.deselectRow(at: indexPath, animated: true)
    saveHolder()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destinationVC = segue.destination as! ListViewController
    
    if let indexPath = tableView.indexPathForSelectedRow {
      destinationVC.selectedHolder = holderArray[indexPath.row]
    }
  }
  
  //MARK: - Data Manipulating Methods
  
  func saveHolder() {
    do {
      try context.save()
    } catch {
      print("Error saving data from context \(error)")
    }
    tableView.reloadData()
  }
  
  func loadHolder(with request : NSFetchRequest<Holder> = Holder.fetchRequest()) {
    do {
      holderArray = try context.fetch(request)
    } catch {
      print("Error loading data from context \(error)")
    }
    tableView.reloadData()
  }
}

