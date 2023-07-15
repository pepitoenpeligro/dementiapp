import csv
from dataclasses import dataclass
import requests
import time

header = {
    "Content-Type" : "application/json",
    "Authorization": "eyJraWQiOiJSeHlrbE9SbmQ1MHV5b244SlkyWVZJVWVHZHR5RE9UY2RZYVMyZVlqWkxJPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI0ZjIzMjkzMS03ZjY1LTQzNGQtYWJjMi0yZDZlOWZhZjU1MTkiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTkF5QWRBYWRnIiwiY29nbml0bzp1c2VybmFtZSI6ImN1aWRhZG8iLCJvcmlnaW5fanRpIjoiZWQ3ZWI3YTItMDQwOC00YjkyLThlYzgtZWNmY2I2MTkyNzMyIiwiYXVkIjoiMmNudHBvaTFoYjk5YmtmYnRhZTNpamU0Z2IiLCJldmVudF9pZCI6ImI2MDc3NjUxLWExOGQtNDc4Ny04ZmViLWViZDdmZDUwMmYyMyIsInRva2VuX3VzZSI6ImlkIiwiYXV0aF90aW1lIjoxNjg4OTEzMTYxLCJleHAiOjE2ODg5MTY3NjEsImlhdCI6MTY4ODkxMzE2MSwianRpIjoiM2Q0MmI2MzEtM2Q4ZC00MjdlLTgyNDgtNGVhOGU2ZTkwODkxIiwiZW1haWwiOiJjdWlkYWRvQGRlbWVudGlhcHAuY29tIn0.wVpAU8aNosGe5pFtbbu2yEHdLX5TYszbR7khMKdTnLpaorvrnDkfn9yHqZcvtcFuuSrZWDyrAMSg2Gl61KX2giNSv4cmBD2wSbeBnS4tMJQ0n9JTK0PvolD2_IzFrbgOBuRPVToZ19EyObEeOLos7Fb5_QNQs3rdQp7ce6cLi4s697wmSKo5AEjKVCpmkCvrFA6Wx84q6cTdIF5c3LRx3pT4sZjyTvnDVCAHrmBSH-bLkl-pDc_gEtvSCn0_p1pKum7uKRNjBdtlzOd5lkj5dIaxr8ymZWwVS2MNzlKDcSW3GHxTFZa_m0B7PeaXlPbvrgblnxbxLeCTGizj4Wr_gA"
}

@dataclass
class Location:
    createdAt: str
    locationId: str
    latitude: str
    userId: str
    longitude: str
    

# with open("/Users/pp/Downloads/selected.csv", newline='') as csvfile:
with open("/Users/pp/Desktop/albondon_beone_v2.csv", newline='') as csvfile:
    reader = csv.reader(csvfile)
    next(reader)
    locations = []
    for row in reader:
        # print(row)
        location = Location(createdAt=row[1], locationId=row[0], latitude=row[2], longitude=row[3], userId=row[4])
        # location = Location(createdAt=row[1], locationId=row[0], latitude=row[3], longitude=row[2], userId=row[4])
        # location = Location(*row)
        # print(location)
        locations.append(location)

for location in locations:
    data = {
        "userId": "da3b1187-90e7-48ed-984e-5bc0b20a9522",
        "location" : {
            "latitude": location.latitude,
            "longitude": location.longitude,
        }
    }
    print(f"Sending ${data}")

    response = requests.post("https://fsz12ocgr6.execute-api.eu-west-1.amazonaws.com/prod/location", json=data, headers=header)
    print(response.content)
    time.sleep(0)


