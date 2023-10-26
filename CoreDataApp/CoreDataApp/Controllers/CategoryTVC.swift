//
//  CategoryTVC.swift
//  CoreDataApp
//
//  Created by Apple on 25.10.23.
//

import UIKit
import CoreData

class CategoryTVC: UITableViewController {
    
    var categories = [CategoryModel]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }

    @IBAction func addNewCategory(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        ///дабавлям TextField в AlertController
        alert.addTextField { textField in
            textField.placeholder = "Category"
        }
        /// даваляем и описываем кнопки в AlertController
        let cancel = UIAlertAction(title: "Cencel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [ weak self ] _ in
            if let texField = alert.textFields?.first,
               let text = texField.text,
               text != "",
               let self = self
            {
                ///на основании данных из TextField создаем новую категорию
                let newCategory = CategoryModel(context: self.context)
                newCategory.name = text
                self.categories.append(newCategory)
                self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .automatic)
                ///добавляем новую категорию в БД
                self.saveCategories()
            }
        }
        
        alert.addAction(cancel)
        alert.addAction(addAction)
        
        self.present(alert, animated: true)
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - CoreData
    
    // метод по отображению данных, если они есть в БД
    private func getData() {
        loadCategories()
        tableView.reloadData()
    }
    
    //метод по загрузке категорий
    private func loadCategories(with request: NSFetchRequest<CategoryModel> = CategoryModel.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    private func saveCategories() {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}


//                метод для добавления новой категории в БД
//                self.saveCategories()




// NSFetchRequest<CategoryModel>  - почему такие скобки?