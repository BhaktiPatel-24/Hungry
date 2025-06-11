# Recipe Finder iOS App

A simple iOS application built using **Swift** and **UIKit** that allows users to search for recipes via the **Edamam Recipe Search API**.

---

## Features

- Search recipes by keyword (e.g., `chicken`, `paneer`, `pasta`)
- View recipe images and titles in a grid layout
- Tap on a recipe to see detailed instructions and ingredients
- Responsive and minimal user interface
- Favorites/heart feature removed to keep the app clean and avoid storing local data

---

## Technologies Used

- Swift
- UIKit
- URLSession for API calls
- Auto Layout for responsive UI
- Edamam Recipe Search API

---

## Edamam API Usage

This app integrates with the [Edamam Recipe Search API](https://developer.edamam.com/edamam-recipe-api) to fetch recipe data.

To use the API, you must provide:

- `app_id` – Your Edamam Application ID  
- `app_key` – Your Edamam Application Key  
- `type=public` – Required query type  
- `q=your_query` – The recipe search term (e.g., `egg`, `salad`)

### Example API Call:

[![Watch the video]([https://img.youtube.com/vi/VIDEO_ID/0.jpg)](https://www.youtube.com/watch?v=VIDEO_ID](https://www.linkedin.com/posts/bhakti-patel-330139308_hungry-just-search-eat-repeat-excited-activity-7338460303900176384-kEhN?utm_source=social_share_video_v2&utm_medium=android_app&rcm=ACoAAE5UfZQB3AdKvAdVC-7Bsw6CuUIAjeBg91A&utm_campaign=copy_link))

