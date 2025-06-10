//
//  Models.swift
//  Hungry
//
//  Created by Apple on 08/06/25.
//

// Models.swift
import Foundation

struct RecipeV2: Codable {
    let uri: String
    let label: String
    let image: String
    let url: String?

    let ingredientLines: [String]?
    let calories: Double?
    let yield: Double?
    let totalTime: Double?
    let cuisineType: [String]?
    let mealType: [String]?
    let dishType: [String]?
}

struct HitV2: Codable {
    let recipe: RecipeV2
}

struct RecipeV2Response: Codable {
    let hits: [HitV2]
}

struct RecipeDetailResponse: Codable {
    let recipe: RecipeV2
}


