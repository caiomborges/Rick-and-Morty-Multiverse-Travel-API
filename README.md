# Installation

To use this API you need the following installed in your system:

* Docker Desktop
* Postman (or any API Client)

You can get the docker installer in the docker official website:
https://www.docker.com/get-started/

# First Steps

After cloning the repository, you first need to build the docker-compose image:

```
docker-compose build
```

Then, run the docker containers:

```
docker-compose up
```

Wait for the execution to finish until you see the following message on the log:

```
[development] Kemal is ready to lead at http://0.0.0.0:3000
```

Open your API Client and test the API!

# Endpoints

## 1. Create a new travel plan

* **Endpoint:** POST /travel_plans
* **Example:** POST localhost:3000/travel_plans
  * **Request body (Content-Type: application/json):**
  * ```
    {
      "travel_stops": [1, 2]
    }
    ```
  * **Successful response (Status: 201, Content-Type: application/json):**
  * ```
    {
      "id": 1,
      "travel_stops": [1, 2]
    }
    ```

## 2. Get all travel plans

* **Endpoint:** GET /travel_plans
* **Query Parameters (optional):**
  * **Optimize (boolean - false by default):** When true, the travel_stops Array is sorted in a way to optimize the travel, reducing the number of interdimensional jumps required and starting from the most popular locations in each dimension.
  * **Expand (boolean - false by default):** When true, the travel_stops field shows detailed informations about each stop.
* **Example:** GET localhost:3000/travel_plans
  * **Successful response (Status: 200, Content-Type: application/json):**
  * ```
    [
      {
        "id": 1,
        "travel_stops": [1, 2]
      },
      {
        "id": 2,
        "travel_stops": [3, 7]
      }
    ]
    ```
* **Example:** GET localhost:3000/travel_plans?optimize=false&expand=true
  * **Successful response (Status: 200, Content-Type: application/json):**
  * ```
    [
      {
        "id": 1,
        "travel_stops": [
          {
            "id": 1,
            "name": "Earth (C-137)",
            "type": "Planet",
            "dimension": "Dimension C-137"
          },
          {
            "id": 2,
            "name": "Abadango",
            "type": "Cluster",
            "dimension": "unknown"
          }
        ]
      },
      {
        "id": 2,
        "travel_stops": [
          {
            "id": 3,
            "name": "Citadel of Ricks",
            "type": "Space station",
            "dimension": "unknown"
          },
          {
            "id": 7,
            "name": "Immortality Field Resort",
            "type": "Resort",
            "dimension": "unknown"
          }
        ]
      }
    ]
    ```

## 3. Get a specific travel plan

* **Endpoint:** GET /travel_plans/{id}
* **Parameters:**
  * {id}: Unique travel plan identifier.
* **Query Parameters (optional):**
  * **Optimize (boolean - false by default):** When true, the travel_stops Array is sorted in a way to optimize the travel, reducing the number of interdimensional jumps required and starting from the most popular locations in each dimension.
  * **Expand (boolean - false by default):** When true, the travel_stops field shows detailed informations about each stop.
* **Example:** GET localhost:3000/travel_plans/1
  * **Successful response (Status: 200, Content-Type: application/json):**
  * ```
    {
      "id": 1,
      "travel_stops": [1, 2]
    }
    ```
* **Example:** GET localhost:3000/travel_plans/1?optimize=false&expand=true
  * **Successful response (Status: 200, Content-Type: application/json):**
  * ```
    {
      "id": 1,
      "travel_stops": [
        {
          "id": 1,
          "name": "Earth (C-137)",
          "type": "Planet",
          "dimension": "Dimension C-137"
        },
        {
          "id": 2,
          "name": "Abadango",
          "type": "Cluster",
          "dimension": "unknown"
        }
      ]
    }
    ```

## 4. Update an existing travel plan

* **Endpoint:** PUT /travel_plans/{id}
* **Parameters:**
  * {id}: Unique travel plan identifier.
* **Example:** PUT localhost:3000/travel_plans/1
  * **Request body (Content-Type: application/json):**
  * ```
    {
      "travel_stops": [4, 5, 6]
    }
    ```
  * **Successful response (Status: 200, Content-Type: application/json):**
  * ```
    {
      "id": 1,
      "travel_stops": [4, 5, 6]
    }
    ```

## 5. Exclude an existing travel plan

* **Endpoint:** DELETE /travel_plans/{id}
* **Parameters:**
  * {id}: Unique travel plan identifier.
* **Example:** DELETE localhost:3000/travel_plans/1
  * **Successful response (Status: 204): No body response**
