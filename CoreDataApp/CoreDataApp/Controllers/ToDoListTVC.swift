//
//  ToDoListTVC.swift
//  CoreDataApp
//
//  Created by Apple on 25.10.23.
//

import UIKit
import CoreData

class ToDoListTVC: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var selectedCategory: CategoryModel? {
        didSet {
            self.title = selectedCategory?.name
            getData()
        }
    }
    
    var itemsArray = [ItemModel]()
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
       
        alert.addTextField { textField in
            textField.placeholder = "New task"
        }
        
        let cancel = UIAlertAction(title: "Cencel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [ weak self ] _ in
            if let texField = alert.textFields?.first,
               let text = texField.text,
               text != "",
               let self = self
            {
                ///создаем новый элемент и связываем его с context
                let newItem = ItemModel(context: self.context)
                newItem.title = text
                newItem.done = false
                ///нужно  указать категория тк связь many to one
                newItem.parentCategory = self.selectedCategory
                
                self.itemsArray.append(newItem)
                self.saveItems()
                self.tableView.insertRows(at: [IndexPath(row: self.itemsArray.count - 1, section: 0)], with: .automatic)
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(addAction)
        
        self.present(alert, animated: true)
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return itemsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = itemsArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            ///нужно  задать сортировку и по  катерии и по имени эдемента
            if let categoryName = selectedCategory?.name,
               let itemName = itemsArray[indexPath.row].title {
                
                let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
                
                ///нужны 2 предиката: 1й по  категориии, 2й по элементам
                let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", categoryName)
                let itemPredicate =  NSPredicate(format: "title MATCHES %@", itemName)
                
                ///позволяет скомпоновать несколько предикатов в один
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, itemPredicate])
                
                if let  resault = try? context.fetch(request) {
                    for object in resault {
                        context.delete(object)
                    }
                    itemsArray.remove(at: indexPath.row)
                    saveItems()
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    // проставление марки при нажании на ячейку
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///удаляем серое выделение ячейки
        tableView.deselectRow(at: indexPath, animated: true)
        ///находим  ячейку, на которую кликнули и переворачиваем значение done
        itemsArray[indexPath.row].done.toggle()
        ///обновляем БД
        self.saveItems()
        ///перезагружаем только одну ячейку
        tableView.reloadRows(at: [indexPath], with: .fade)
    }

    // MARK: - CoreData
    
    private func getData() {
        loadItems()
    }
    /// добавляем свойство predicate для загрузки не всех items, а только тех, что нам нужны
    private func loadItems(with request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest(),
                           predicate: NSPredicate? = nil) {
        ///вытаскиваем из selectedCategory имя
        guard let name = selectedCategory?.name else { return }
       
        //второй способ создания предиката (нужны только элементы конктерной категории)
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
        
        if let predicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, categoryPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        do {
            itemsArray = try context.fetch(request) ///добавляем в массив все элементы нужной категории
        } catch {
            print("Error fetch context")
        }
        tableView.reloadData()  ///переносим. тк будем использовать каждый раз  при сортировке
       
    }
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
    // MARK: - Extension
// подключение Search bar (проверить поключение делегата!!!)
///textDidChange - отлавливает каждый ввод символа
extension ToDoListTVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.isEmpty {
            loadItems() ///отображение всех  эелементов на экране
            searchBar.resignFirstResponder() /// скрытие клавиатуры при завершении ввода
        } else {
            let request: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
            let searchPredicate = NSPredicate(format: "title CONTAINS %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadItems(with: request, predicate: searchPredicate)
        }
    }
}
