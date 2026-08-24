from faker import Faker
import pandas as pd
import random

fake = Faker("en_IN")

CUSTOMER_COUNT = 1000

def generate_customer():
    customer = {
        "first_name": fake.first_name(),
        "last_name": fake.last_name(),
        "gender": random.choice(["Male", "Female"]),
        "email": fake.email(),
        "phone": fake.phone_number(),
        "city": fake.city(),
        "state": fake.state(),
        "country": "India",
        "signup_date": fake.date_between(
            start_date="-5y",
            end_date="today"
        )
    }

    return customer


def generate_customers(count):
    customers = []

    for i in range(count):
        customers.append(generate_customer())

    return customers
    


def save_to_csv(customers, filename):

    df = pd.DataFrame(customers)

    df["signup_date"] = pd.to_datetime(
    df["signup_date"]
).dt.strftime("%Y-%m-%d")

    df.to_csv(filename, index=False)

    print(f"{len(customers)} customers saved to {filename}")


def main():

    customers = generate_customers(CUSTOMER_COUNT)

    save_to_csv(customers, "datasets/customers.csv")


if __name__ == "__main__":
    main()