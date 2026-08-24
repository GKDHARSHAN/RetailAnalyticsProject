from faker import Faker
import pandas as pd
import random

fake = Faker("en_IN")

# ======================================
# CONFIGURATION
# ======================================

PRODUCT_COUNT = 5000
SUPPLIER_COUNT = 20

COLORS = [
    "Black",
    "White",
    "Blue",
    "Red",
    "Silver",
    "Green"
]

CATEGORIES = {
    1: "Electronics",
    2: "Clothing",
    3: "Books",
    4: "Home & Kitchen",
    5: "Sports",
    6: "Beauty",
    7: "Furniture",
    8: "Toys",
    9: "Automotive",
    10: "Grocery"
}

# ======================================
# PRODUCT MASTER
# ======================================

PRODUCT_CATALOG = {

    "Electronics": [

        {"name": "Samsung Galaxy S25", "brand": "Samsung", "price": (75000, 100000)},
        {"name": "iPhone 17", "brand": "Apple", "price": (80000, 130000)},
        {"name": "Dell XPS 15", "brand": "Dell", "price": (120000, 180000)},
        {"name": "Sony WH-1000XM6", "brand": "Sony", "price": (25000, 40000)},
        {"name": "Canon EOS R5", "brand": "Canon", "price": (180000, 250000)},
        {"name": "HP Pavilion 15", "brand": "HP", "price": (60000, 90000)}

    ],

    "Clothing": [

        {"name": "Nike Air Max", "brand": "Nike", "price": (6000, 12000)},
        {"name": "Adidas Hoodie", "brand": "Adidas", "price": (2500, 5000)},
        {"name": "Puma Track Pants", "brand": "Puma", "price": (1800, 3500)},
        {"name": "Levi's Jeans", "brand": "Levi's", "price": (2500, 5000)},
        {"name": "Allen Solly Shirt", "brand": "Allen Solly", "price": (1800, 4000)},
        {"name": "H&M Jacket", "brand": "H&M", "price": (3500, 7000)}

    ],

    "Books": [

        {"name": "Python Crash Course", "brand": "No Starch Press", "price": (600, 1200)},
        {"name": "Atomic Habits", "brand": "Penguin", "price": (400, 900)},
        {"name": "Clean Code", "brand": "Pearson", "price": (700, 1500)},
        {"name": "The Psychology of Money", "brand": "Jaico", "price": (350, 800)},
        {"name": "Deep Work", "brand": "Grand Central", "price": (400, 900)},
        {"name": "Rich Dad Poor Dad", "brand": "Plata Publishing", "price": (300, 700)}

    ]

}


# ======================================
# GENERATE SINGLE PRODUCT
# ======================================

def generate_product():

    # Only categories that currently have products
    category_id = random.choice([1, 2, 3])

    category_name = CATEGORIES[category_id]

    product = random.choice(PRODUCT_CATALOG[category_name])

    selling_price = random.randint(
        product["price"][0],
        product["price"][1]
    )

    cost_price = int(
        selling_price * random.uniform(0.60, 0.85)
    )

    return {

        "product_name": product["name"],

        "brand": product["brand"],

        "category_id": category_id,

        "supplier_id": random.randint(1, SUPPLIER_COUNT),

        "color": random.choice(COLORS),

        "unit_price": selling_price,

        "cost_price": cost_price,

        "stock_quantity": random.randint(10, 500),

        "created_date": fake.date_between(
            start_date="-3y",
            end_date="today"
        ),

        "is_active": random.choice([True, True, True, False])

    }


# ======================================
# GENERATE MULTIPLE PRODUCTS
# ======================================

def generate_products(count):

    products = []

    for _ in range(count):
        products.append(generate_product())

    return products


# ======================================
# SAVE TO CSV
# ======================================

def save_to_csv(products, filename):

    df = pd.DataFrame(products)

    df.to_csv(filename, index=False)

    print(f"{len(products)} products saved to {filename}")


# ======================================
# MAIN
# ======================================

def main():

    products = generate_products(PRODUCT_COUNT)

    save_to_csv(products, "datasets/products.csv")

    print("Product generation completed successfully!")


if __name__ == "__main__":
    main()