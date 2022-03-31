//
//  ListViewController.swift
//  TwoDo
//
//  Created by Mederbek on 26/3/22.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {
  
  var listArray = [List]()
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  
  var selectedHolder : Holder? {
    didSet {
      loadList()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

  }
  @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
    var textFiled = UITextField()
    
    let alert = UIAlertController.init(title: "Add items", message: "", preferredStyle: .alert)
    let action = UIAlertAction(title: "Add", style: .default) { action in
      let newItem = List(context: self.context)
      newItem.item = textFiled.text!
      newItem.done = false
      newItem.parentHolder = self.selectedHolder
      self.listArray.append(newItem)
      self.saveList()
    }
    alert.addTextField { alertTextFiled in
      alertTextFiled.placeholder = "Create"
      textFiled = alertTextFiled
    }
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: - TableView DataSource Methods
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listArray.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
    let items = listArray[indexPath.row]
    cell.textLabel?.text = items.item
    
    cell.accessoryType = items.done ? .checkmark : .none
    return cell
  }
  
  //MARK: - TableView Delegate Methods
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    listArray[indexPath.row].done = !listArray[indexPath.row].done
    saveList()
    loadList()
    tableView.deselectRow(at: indexPath, animated: true)
    
  }
  
  
  //MARK: - Model Manipulating Methods
  
  func saveList() {
    do {
      try context.save()
    } catch {
      print("Error fetching data from context \(error)")
    }
    tableView.reloadData()
  }
  
  func loadList(with request: NSFetchRequest<List> = List.fetchRequest(), predicate : NSPredicate? = nil) {
    let categoryPredicate = NSPredicate(format: "parentHolder.category MATCHES %@", selectedHolder!.category!)
    
    if let additionalPredicate = predicate {
      request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
    } else {
      request.predicate = categoryPredicate
    }
    
    do {
      listArray = try context.fetch(request)
    } catch {
      print("Error fetching data from context \(error)")
    }
    tableView.reloadData()
  }
  
}

//MARK: - Search Bar Methods

extension ListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

      let request : NSFetchRequest<List> = List.fetchRequest()
      let predicate = NSPredicate(format: "item CONTAINS[cd] %@", searchBar.text!)
      request.sortDescriptors = [NSSortDescriptor(key: "item", ascending: true)]

      loadList(with: request, predicate: predicate)
    }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text?.count == 0 {
      loadList()

      DispatchQueue.main.async {
        searchBar.resignFirstResponder()
      }
    }
  }
}
