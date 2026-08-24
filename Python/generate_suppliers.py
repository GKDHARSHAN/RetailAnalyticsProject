from faker import Faker
import pandas as pd
import random

fake = Faker("en_IN")

SUPPLIER_COUNT = 20

COMPANY_SUFFIX = [
    "Traders",
    "Distributors",
    "Enterprises",
    "Industries",
    "Wholesalers",
    "Supply Co.",
    "Solutions",
    "Retail Hub"
]


def generate_supplier():

    company_name = (
        fake.company().replace("\n", " ")
        + " "
        + random.choice(COMPANY_SUFFIX)
    )

    return {

        "supplier_name": company_name,

        "city": fake.city(),

        "state": fake.state(),

        "country": "India"

    }


def generate_suppliers(count):

    suppliers = []

    for _ in range(count):
        suppliers.append(generate_supplier())

    return suppliers


def save_to_csv(suppliers, filename):

    df = pd.DataFrame(suppliers)

    df.to_csv(filename, index=False)

    print(f"{len(suppliers)} suppliers saved to {filename}")


def main():

    suppliers = generate_suppliers(SUPPLIER_COUNT)

    save_to_csv(suppliers, "datasets/suppliers.csv")

    print("Supplier generation completed successfully!")


if __name__ == "__main__":
    main()