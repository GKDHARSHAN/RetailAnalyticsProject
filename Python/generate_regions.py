import pandas as pd

REGIONS = {
    1: "North India",
    2: "South India",
    3: "East India",
    4: "West India",
    5: "Central India"
}


def generate_regions():

    regions = []

    for region_id, region_name in REGIONS.items():

        region = {
            "region_id": region_id,
            "region_name": region_name
        }

        regions.append(region)

    return regions


def save_to_csv(regions, filename):

    df = pd.DataFrame(regions)

    df.to_csv(filename, index=False)

    print(f"{len(regions)} regions saved to {filename}")


def main():

    regions = generate_regions()

    save_to_csv(
        regions,
        "datasets/regions.csv"
    )


if __name__ == "__main__":
    main()