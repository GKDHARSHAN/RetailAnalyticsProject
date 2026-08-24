from faker import Faker
import pandas as pd
import random

fake = Faker("en_IN")

EMPLOYEE_COUNT = 100

DEPARTMENT_IDS = [1, 2, 3, 4, 5]


def generate_employee():

    employee = {
        "first_name": fake.first_name(),

        "last_name": fake.last_name(),

        "department_id": random.choice(DEPARTMENT_IDS),

        "manager_id": None,

        "hire_date": fake.date_between(
            start_date="-5y",
            end_date="today"
        ),

        "salary": random.randint(25000, 100000)
    }

    return employee


def generate_employees(count):

    employees = []

    for i in range(count):
        employees.append(generate_employee())

    return employees


def save_to_csv(employees, filename):

    df = pd.DataFrame(employees)

    df.to_csv(
        filename,
        index=False
    )

    print(f"{len(employees)} employees saved to {filename}")


def main():

    employees = generate_employees(EMPLOYEE_COUNT)

    save_to_csv(
        employees,
        "datasets/employees.csv"
    )


if __name__ == "__main__":
    main()