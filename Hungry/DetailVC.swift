//
//  DetailVC.swift
//  Hungry
//
//  Created by Apple on 08/06/25.
//
import UIKit

struct FavoriteRecipe: Codable {
    let uri: String
    let label: String
    let imageURL: String
    let ingredientsText: String
    let nutritionText: String
}
class DetailVC: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var recipename: UILabel!
    @IBOutlet weak var ingredients: UILabel!
    @IBOutlet weak var nutrition: UILabel!

    var recipe: RecipeV2?

    private var fullIngredientsText: String = ""
    private var fullNutritionText: String = ""
    private var isFavorite = false
    private let favoritesKey = "favoriteRecipes"

    private let heartButton: UIButton = {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        button.setImage(UIImage(systemName: "heart", withConfiguration: config), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureView()
        setupTapGestures()
        setupHeartButton()
    }

    func setupUI() {
        image.layer.cornerRadius = 20
        image.clipsToBounds = true
        image.layer.masksToBounds = true
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.lightGray.cgColor

        recipename.numberOfLines = 0
        recipename.font = .boldSystemFont(ofSize: 20)

        ingredients.font = .systemFont(ofSize: 16)
        nutrition.font = .systemFont(ofSize: 16)

        ingredients.isUserInteractionEnabled = true
        nutrition.isUserInteractionEnabled = true
    }

    func setupHeartButton() {
        view.addSubview(heartButton)
        heartButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)

        NSLayoutConstraint.activate([
            heartButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            heartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            heartButton.widthAnchor.constraint(equalToConstant: 44),
            heartButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    func configureView() {
        guard let recipe = recipe else {
            recipename.text = "Recipe not found"
            ingredients.text = ""
            nutrition.text = ""
            return
        }

        recipename.text = recipe.label

        if let lines = recipe.ingredientLines, !lines.isEmpty {
            let list = lines.map { "• \($0)" }.joined(separator: "\n")
            fullIngredientsText = "Ingredients (\(lines.count)):\n\n\(list)"
        } else {
            fullIngredientsText = "No ingredients available."
        }
        ingredients.text = fullIngredientsText

        var info = "Nutrition Info:\n\n"
        if let cal = recipe.calories {
            info += String(format: "• Calories: %.0f kcal\n", cal)
        }
        if let servings = recipe.yield {
            info += "• Servings: \(Int(servings))\n"
        }
        if let time = recipe.totalTime {
            info += time > 0 ? "• Total Time: \(Int(time)) min" : "• Time not available"
        }
        fullNutritionText = info
        nutrition.text = fullNutritionText

        if let imageURL = URL(string: recipe.image) {
            URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.image.image = UIImage(data: data)
                    }
                }
            }.resume()
        }

        
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let saved = try? JSONDecoder().decode([FavoriteRecipe].self, from: data) {
            isFavorite = saved.contains(where: { $0.uri == recipe.uri })
        }
        updateHeartIcon()
    }

    func setupTapGestures() {
        let tapIngredients = UITapGestureRecognizer(target: self, action: #selector(showIngredientsDetail))
        ingredients.addGestureRecognizer(tapIngredients)

        let tapNutrition = UITapGestureRecognizer(target: self, action: #selector(showNutritionDetail))
        nutrition.addGestureRecognizer(tapNutrition)
    }

    @objc func showIngredientsDetail() {
        showStyledPopup(title: "Ingredients Details", message: fullIngredientsText)
    }

    @objc func showNutritionDetail() {
        showStyledPopup(title: "Nutrition Details", message: fullNutritionText)
    }

    func showStyledPopup(title: String, message: String) {
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

    func updateHeartIcon() {
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular)
        let iconName = isFavorite ? "heart.fill" : "heart"
        let icon = UIImage(systemName: iconName, withConfiguration: config)
        heartButton.setImage(icon, for: .normal)
        heartButton.tintColor = isFavorite ? .systemRed : .black
    }

    @objc func toggleFavorite() {
        guard let recipe = recipe else { return }

        var savedRecipes: [FavoriteRecipe] = []

        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([FavoriteRecipe].self, from: data) {
            savedRecipes = decoded
        }

        if let index = savedRecipes.firstIndex(where: { $0.uri == recipe.uri }) {
            
            savedRecipes.remove(at: index)
            isFavorite = false
            showAlert(title: "Removed", message: "Recipe removed from favorites.")
        } else {
           
            let favorite = FavoriteRecipe(
                uri: recipe.uri,
                label: recipe.label,
                imageURL: recipe.image,
                ingredientsText: fullIngredientsText,
                nutritionText: fullNutritionText
            )
            savedRecipes.append(favorite)
            isFavorite = true
            showAlert(title: "Saved", message: "Recipe saved to favorites.")
        }

        if let encoded = try? JSONEncoder().encode(savedRecipes) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }

        updateHeartIcon()

//        NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
