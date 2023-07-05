import csv
from dataclasses import dataclass
import requests
import time

header = {
    "Content-Type" : "application/json",
    "Authorization": "eyJraWQiOiJSeHlrbE9SbmQ1MHV5b244SlkyWVZJVWVHZHR5RE9UY2RZYVMyZVlqWkxJPSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiJmNTQ5NzkzMS02MzQ5LTQzOWYtODgyMy1iYjgxODdiODA1YzIiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNzIjoiaHR0cHM6XC9cL2NvZ25pdG8taWRwLmV1LXdlc3QtMS5hbWF6b25hd3MuY29tXC9ldS13ZXN0LTFfTkF5QWRBYWRnIiwiY29nbml0bzp1c2VybmFtZSI6Impvc2UiLCJvcmlnaW5fanRpIjoiMzZjNjBlMzctMDcwOC00MzhiLWE1YTYtNGNkNzc5Y2UxOTI2IiwiYXVkIjoiMmNudHBvaTFoYjk5YmtmYnRhZTNpamU0Z2IiLCJldmVudF9pZCI6ImRmN2M0MzMxLTgzMTAtNGQ5YS05NGMxLTIyMjliOWVjOTQzYSIsInRva2VuX3VzZSI6ImlkIiwiYXV0aF90aW1lIjoxNjgxOTE2NTM1LCJleHAiOjE2ODE5MjAxMzQsImlhdCI6MTY4MTkxNjUzNSwianRpIjoiMThjZDc1ZGUtZDVjNC00YmJlLWFiZjEtMzRkZTBhZjM3ZGQ1IiwiZW1haWwiOiJqb3NlZXppb18zNUBob3RtYWlsLmNvbSJ9.y3JAq7wcIlXDZO537AEpUS0kDrfe99kZPhhK8lWFMbQWlZDr74aphCVeXI3gvyhjlh1Y1ANFArpJzhtSjxQiFXtR4BI_NUgtUj8s7mrmPR9zvr7CDXq9vm1YMjOKdJ08NvOFh8ttI1FF-VunpOeDtvh39nDOKbF6kIGa7HRiqUu_dMZNnkfQi2bCaeUKw22ypIuqiHeVyfi6X9QZ0tigNAa6ATuJolS9vpXIE4PDV0mDW6Ps9ZNRVwkVAtQOqMJycd3DSXWlv4j62LSkXCyg8BgnOBTTC6JvlB1VoZYLeUeVNNdmuPlFOFNHi9HC8rLp15YLVrhsz4Je5je1-DKWKg"
}

@dataclass
class Location:
    createdAt: str
    locationId: str
    latitude: str
    userId: str
    longitude: str
    

# with open("/Users/pp/Downloads/selected.csv", newline='') as csvfile:
with open("/Users/pp/Desktop/albondon_beone.csv", newline='') as csvfile:
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
        "userId": "d4a4fa59-b144-480f-ac5a-829dbd9484eb",
        "location" : {
            "latitude": location.latitude,
            "longitude": location.longitude,
        }
    }
    print(f"Sending ${data}")

    response = requests.post("https://fsz12ocgr6.execute-api.eu-west-1.amazonaws.com/prod/location", json=data, headers=header)
    print(response.content)
    time.sleep(0)


