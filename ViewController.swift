
import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalFootprintLabel: UILabel!

    var habits: [Habit] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchHabits()
        calculateTotal()
    }

    func fetchHabits() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
        do {
            habits = try context.fetch(fetchRequest)
        } catch {
            print("Fetch failed")
        }
    }

    func calculateTotal() {
        let total = habits.reduce(0.0) { $0 + $1.footprint }
        totalFootprintLabel.text = String(format: "🌍 Total CO₂: %.2f kg", total)
    }

    @IBAction func addHabitTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Habit", message: "Enter activity and CO₂ footprint", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Activity (e.g. Car ride)" }
        alert.addTextField { $0.placeholder = "Footprint (kg CO₂)"; $0.keyboardType = .decimalPad }

        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let name = alert.textFields?[0].text,
                  let footprintStr = alert.textFields?[1].text,
                  let footprint = Double(footprintStr) else { return }

            self.saveHabit(name: name, footprint: footprint)
        }
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    func saveHabit(name: String, footprint: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let newHabit = Habit(context: context)
        newHabit.name = name
        newHabit.footprint = footprint
        do {
            try context.save()
            habits.append(newHabit)
            tableView.reloadData()
            calculateTotal()
        } catch {
            print("Failed to save habit")
        }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let habit = habits[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(habit.name ?? "") – \(habit.footprint) kg CO₂"
        return cell
    }
}
