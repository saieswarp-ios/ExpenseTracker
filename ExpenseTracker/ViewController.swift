import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var summaryCard: UIView!

    @IBOutlet weak var totalLabel: UILabel!

    @IBOutlet weak var expenseCountLabel: UILabel!

    @IBOutlet weak var categoryCountLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    var expenses: [Expense] = [

        Expense(
            title: "Pizza",
            amount: 250,
            category: "Food",
            date: Date()
        ),

        Expense(
            title: "Uber",
            amount: 180,
            category: "Travel",
            date: Date()
        ),

        Expense(
            title: "Netflix",
            amount: 499,
            category: "Entertainment",
            date: Date()
        )
    ]
    var filteredExpenses: [Expense] = []

    override func viewDidLoad() {
        super.viewDidLoad()

     

        summaryCard.layer.cornerRadius = 25

        summaryCard.backgroundColor =
            UIColor.systemIndigo

        summaryCard.layer.shadowColor =
        UIColor.black.cgColor

        summaryCard.layer.shadowOpacity = 1

        summaryCard.layer.shadowRadius = 10

        summaryCard.layer.shadowOffset =
            CGSize(width: 0, height: 5)
        // Text Colors

        totalLabel.textColor = .white

        expenseCountLabel.textColor = .white

        categoryCountLabel.textColor = .white
        searchBar.delegate = self

        filteredExpenses = expenses
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            UINib(
                nibName: "ExpenseCell",
                bundle: nil
            ),
            forCellReuseIdentifier: "ExpenseCell"
        )

        loadExpenses()
        filteredExpenses = expenses

        updateTotal()

        updateDashboard()
    }
    @IBAction func exportCSVTapped(
        _ sender: UIButton
    ) {
        var csvText =
            "Title,Amount,Category\n"

        for expense in expenses {

            csvText +=
                "\(expense.title),"

            csvText +=
                "\(expense.amount),"

            csvText +=
                "\(expense.category)\n"
        }
        let fileName =
            "Expenses.csv"

        let path =
            FileManager.default
                .temporaryDirectory
                .appendingPathComponent(
                    fileName
                )

        try? csvText.write(
            to: path,
            atomically: true,
            encoding: .utf8
        )
        let activityVC =
            UIActivityViewController(
                activityItems: [path],
                applicationActivities: nil
            )

        present(
            activityVC,
            animated: true
        )
    }

    @IBAction func addExpenseTapped(
        _ sender: UIButton
    ) {

        let alert = UIAlertController(
            title: "New Expense",
            message: "Enter details",
            preferredStyle: .alert
        )

        alert.addTextField {
            $0.placeholder = "Title"
        }

        alert.addTextField {
            $0.placeholder = "Amount"
            $0.keyboardType = .decimalPad
        }

        alert.addTextField {
            $0.placeholder = "Category"
        }

        let save = UIAlertAction(
            title: "Save",
            style: .default
        ) { _ in

            let title =
                alert.textFields?[0].text ?? ""

            let amount =
                Double(
                    alert.textFields?[1].text ?? ""
                ) ?? 0

            let category =
                alert.textFields?[2].text ?? ""

            let expense = Expense(
                title: title,
                amount: amount,
                category: category,
                date: Date()
            )

            self.expenses.append(expense)

            self.filteredExpenses = self.expenses
            self.saveExpenses()

            self.updateTotal()

            self.updateDashboard()

            self.tableView.reloadData()
        }

        alert.addAction(save)

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )

        present(alert, animated: true)
    }

    func updateTotal() {

        let total =
            expenses.reduce(0) {
                $0 + $1.amount
            }

        totalLabel.text =
            "₹\(Int(total))"
    }

    func updateDashboard() {

        expenseCountLabel.text =
            "📊 Expenses: \(expenses.count)"

        let categories =
            Set(
                expenses.map {
                    $0.category
                }
            )

        categoryCountLabel.text =
            "🏷️ Categories: \(categories.count)"
    }

    func iconForCategory(
        _ category: String
    ) -> String {

        switch category.lowercased() {

        case "food":
            return "🍔"
     

        case "travel":
            return "🚗"

        case "shopping":
            return "🛒"

        case "entertainment":
            return "🎬"
        case "medical" :
            return "🏥"
        case "education":
            return "📚"

        default:
            return "💰"
        }
    }

    func saveExpenses() {

        let encoder = JSONEncoder()

        if let data =
            try? encoder.encode(expenses) {

            UserDefaults.standard.set(
                data,
                forKey: "expenses"
            )
        }
    }
    func loadExpenses() {

        if let data =
            UserDefaults.standard.data(
                forKey: "expenses"
            ) {

            let decoder = JSONDecoder()

            if let savedExpenses =
                try? decoder.decode(
                    [Expense].self,
                    from: data
                ) {

                expenses = savedExpenses

                filteredExpenses = expenses
            }
        }
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return filteredExpenses.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "ExpenseCell",
                for: indexPath
            ) as! ExpenseCell

        let expense = filteredExpenses[indexPath.row]

        cell.iconLabel.text =
            iconForCategory(
                expense.category
            )

        cell.titleLabel.text =
            expense.title

        cell.categoryLabel.text =
            expense.category

        cell.amountLabel.text =
            "₹\(Int(expense.amount))"

        cell.amountLabel.textColor =
            .systemRed

        return cell
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {

        if editingStyle == .delete {

            expenses.remove(
                at: indexPath.row
            )
            filteredExpenses = expenses

            saveExpenses()

            updateTotal()

            updateDashboard()

            tableView.deleteRows(
                at: [indexPath],
                with: .automatic
            )
        }
    }
}
extension ViewController: UISearchBarDelegate {

    func searchBar(
        _ searchBar: UISearchBar,
        textDidChange searchText: String
    ) {

        if searchText.isEmpty {

            filteredExpenses = expenses

        } else {

            filteredExpenses =
                expenses.filter {

                    $0.title.lowercased()
                        .contains(
                            searchText.lowercased()
                        )

                    ||

                    $0.category.lowercased()
                        .contains(
                            searchText.lowercased()
                        )
                }
        }

        tableView.reloadData()
    }
}
extension ViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let expense =
            filteredExpenses[indexPath.row]

        let alert = UIAlertController(
            title: "Edit Expense",
            message: nil,
            preferredStyle: .alert
        )

        alert.addTextField {
            $0.text = expense.title
        }

        alert.addTextField {
            $0.text = "\(expense.amount)"
            $0.keyboardType = .decimalPad
        }

        alert.addTextField {
            $0.text = expense.category
        }
        let save = UIAlertAction(
            title: "Save",
            style: .default
        ) { _ in

            let newTitle =
                alert.textFields?[0].text ?? ""

            let newAmount =
                Double(
                    alert.textFields?[1].text ?? ""
                ) ?? 0

            let newCategory =
                alert.textFields?[2].text ?? ""

            if let originalIndex =
                self.expenses.firstIndex(
                    where: {
                        $0.title == expense.title &&
                        $0.amount == expense.amount
                    }
                ) {

                self.expenses[originalIndex] =
                    Expense(
                        title: newTitle,
                        amount: newAmount,
                        category: newCategory,
                        date: expense.date
                    )

                self.filteredExpenses =
                    self.expenses

                self.saveExpenses()

                self.updateTotal()

                self.updateDashboard()

                self.tableView.reloadData()
            }
        }
        alert.addAction(save)

        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
        )

        present(alert, animated: true)
    }

}
