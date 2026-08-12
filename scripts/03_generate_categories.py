import pandas as pd

categories = [
    {
        "category_id": 1,
        "category_name": "Electronics",
        "description": "Smartphones, laptops, accessories and gadgets"
    },
    {
        "category_id": 2,
        "category_name": "Fashion",
        "description": "Clothing, footwear and accessories"
    },
    {
        "category_id": 3,
        "category_name": "Home & Kitchen",
        "description": "Furniture, appliances and kitchen essentials"
    },
    {
        "category_id": 4,
        "category_name": "Books",
        "description": "Fiction, non-fiction, educational and children's books"
    },
    {
        "category_id": 5,
        "category_name": "Beauty & Personal Care",
        "description": "Skincare, cosmetics and grooming products"
    },
    {
        "category_id": 6,
        "category_name": "Sports & Fitness",
        "description": "Sports equipment, fitness gear and accessories"
    },
    {
        "category_id": 7,
        "category_name": "Toys & Games",
        "description": "Toys, puzzles, board games and entertainment products"
    },
    {
        "category_id": 8,
        "category_name": "Grocery",
        "description": "Food items, beverages and daily essentials"
    },
    {
        "category_id": 9,
        "category_name": "Health",
        "description": "Healthcare products, supplements and wellness items"
    },
    {
        "category_id": 10,
        "category_name": "Automotive",
        "description": "Vehicle accessories, tools and automotive products"
    }
]

df = pd.DataFrame(categories)

df.to_csv("datasets/categories.csv", index=False)

print("categories.csv generated successfully!")