//
//  DataVC.swift
//  Hungry
//
//  Created by Apple on 09/06/25.
//

import UIKit

struct FavoriteRecipee: Codable {
    let uri: String
    let label: String
    let imageURL: String
    let ingredientsText: String
    let nutritionText: String
}

class FavoriteRecipeCell: UITableViewCell {
    let recipeImageView = UIImageView()
    let nameLabel = UILabel()
    let ingredientsLabel = UILabel()
    let nutritionLabel = UILabel()

    var onTapIngredients: (() -> Void)?
    var onTapNutrition: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0

        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = 8
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        recipeImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        recipeImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true

        ingredientsLabel.font = .boldSystemFont(ofSize: 18)
        ingredientsLabel.textAlignment = .center
        ingredientsLabel.numberOfLines = 0
        ingredientsLabel.textColor = .systemBlue
        ingredientsLabel.isUserInteractionEnabled = true
        let ingTap = UITapGestureRecognizer(target: self, action: #selector(ingredientsTapped))
        ingredientsLabel.addGestureRecognizer(ingTap)

        ingredientsLabel.font = .boldSystemFont(ofSize: 18)
        nutritionLabel.textAlignment = .center
        nutritionLabel.numberOfLines = 0
        nutritionLabel.textColor = .systemGreen
        nutritionLabel.isUserInteractionEnabled = true
        let nutTap = UITapGestureRecognizer(target: self, action: #selector(nutritionTapped))
        nutritionLabel.addGestureRecognizer(nutTap)

        let stack = UIStackView(arrangedSubviews: [nameLabel, recipeImageView, ingredientsLabel, nutritionLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    @objc private func ingredientsTapped() {
        onTapIngredients?()
    }

    @objc private func nutritionTapped() {
        onTapNutrition?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DataVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var favoriteRecipes: [FavoriteRecipee] = []
    let favoritesKey = "favoriteRecipes"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 330
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(FavoriteRecipeCell.self, forCellReuseIdentifier: "cell")

        loadFavorites()
//        NotificationCenter.default.addObserver(self, selector: #selector(loadFavorites), name: .favoritesUpdated, object: nil)
    }

    @objc func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let recipes = try? JSONDecoder().decode([FavoriteRecipee].self, from: data) else {
            favoriteRecipes = []
            tableView.reloadData()
            return
        }
        favoriteRecipes = recipes
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? FavoriteRecipeCell else {
            return UITableViewCell()
        }

        let recipe = favoriteRecipes[indexPath.row]
        cell.nameLabel.text = recipe.label
        cell.ingredientsLabel.text = " Ingredients"
        cell.nutritionLabel.text = " Nutrition"
        cell.recipeImageView.image = nil

        
        cell.onTapIngredients = { [weak self] in
            self?.showPopup(title: "Ingredients", message: recipe.ingredientsText)
        }

        cell.onTapNutrition = { [weak self] in
            self?.showPopup(title: "Nutrition", message: recipe.nutritionText)
        }

        if let url = URL(string: recipe.imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.recipeImageView.image = image
                    }
                }
            }.resume()
        }

        return cell
    }

    func showPopup(title: String, message: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4

        let attributedMessage = NSAttributedString(string: message, attributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .paragraphStyle: paragraphStyle
        ])

        alert.setValue(attributedMessage, forKey: "attributedMessage")

        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           
            favoriteRecipes.remove(at: indexPath.row)
            
           
            if let data = try? JSONEncoder().encode(favoriteRecipes) {
                UserDefaults.standard.set(data, forKey: favoritesKey)
            }

            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}
