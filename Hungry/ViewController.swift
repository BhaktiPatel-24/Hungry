//
//  ViewController.swift
//  Hungry
//
//  Created by Apple on 02/06/25.
//

import UIKit

class RecipeCell: UICollectionViewCell {
    static let identifier = "RecipeCell"

    let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(recipeImageView)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            recipeImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            recipeImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            recipeImageView.heightAnchor.constraint(equalTo: recipeImageView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -4),
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        recipeImageView.image = nil
        titleLabel.text = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    let appId = "your app id"
    let appKey = "your api key"
    let userName = "your user name id"

    var recipes: [RecipeV2] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RecipeCell.self, forCellWithReuseIdentifier: RecipeCell.identifier)
        fetchRecipes(for: "all")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "all"
        fetchRecipes(for: query)
        searchBar.resignFirstResponder()
    }

    func fetchRecipes(for query: String) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.edamam.com/api/recipes/v2?type=public&q=\(encodedQuery)&app_id=\(appId)&app_key=\(appKey)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue(userName, forHTTPHeaderField: "Edamam-Account-User")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let decoded = try JSONDecoder().decode(RecipeV2Response.self, from: data)
                self.recipes = decoded.hits.map { $0.recipe }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch {
                print("Decoding Error:", error)
            }
        }.resume()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCell.identifier, for: indexPath) as? RecipeCell else {
            return UICollectionViewCell()
        }

        let recipe = recipes[indexPath.item]
        cell.titleLabel.text = recipe.label

        if let url = URL(string: recipe.image) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        if let visibleCell = collectionView.cellForItem(at: indexPath) as? RecipeCell {
                            visibleCell.recipeImageView.image = UIImage(data: data)
                        }
                    }
                }
            }.resume()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRecipe = recipes[indexPath.item]

        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailVC else {
            print("Failed to load DetailVC")
            return
        }

        detailVC.recipe = selectedRecipe

        if let nav = navigationController {
            nav.pushViewController(detailVC, animated: true)
        } else {
            detailVC.modalPresentationStyle = .fullScreen
            present(detailVC, animated: true, completion: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let spacing: CGFloat = 12
        let columns: CGFloat = 2
        let totalSpacing = (columns - 1) * spacing + padding * 2
        let width = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: width, height: width + 60)
    }

    @IBAction func data(_ sender: Any) {
        guard let dataVC = storyboard?.instantiateViewController(withIdentifier: "DataVC") as? DataVC else { return }
        dataVC.modalPresentationStyle = .fullScreen
        present(dataVC, animated: true)
    }
}
