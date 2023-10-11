require "kemal"
require "./config/config.cr"
require "json"
require "http/client"

### Endpoints ###

module Api
    VERSION = "0.1.0"

    #Create a new travel plan
    post "/travel_plans" do |env|
        #Get the Array as a String from the request body
        travel_stops = env.params.body["travel_stops"]?

        #If the request body is empty, respond with status 403 and an error message
        if travel_stops == nil
            env.response.content_type = "application/json"
            env.response.status_code = 403
            {message: "ERROR: The request body must not be empty, travel_stops array required!"}.to_json
        #Not empty
        elsif travel_stops
            #Cast from String to Array(Int32)
            travel_stops = travel_stops.delete(" []")
            travel_stops = travel_stops.split(",")
            travel_stops = travel_stops.map {|x| x.to_i32?}

            #Insert in the DB
            travel = Travels.new({travel_stops: travel_stops.to_json})
            travel.save

            #Define the response type as application/json and status 201
            env.response.content_type = "application/json"
            env.response.status_code = 201

            #Response with both ID and Array inserted in the DB
            {id: travel.id, travel_stops: travel_stops}.to_json
        end
    end

    #Get all travel plans
    get "/travel_plans" do |env|
        #Search the IDs and travel_stops Arrays in the DB
        all_travel_stops = get_all_stops()
        all_ids = get_all_ids()

        #Check if the DB is empty
        if all_ids[0].to_s != ""
            #Receive the query parameter optimize
            optimize = get_optimize(env)

            #Receive the query parameter expand
            expand = get_expand(env)

            #Check if optimize is true, then optimizes the travel plans
            if optimize == true
                x=0
                loop do
                    all_travel_stops[x] = optimize_travel(all_travel_stops[x])
                    break if x>=all_travel_stops.size-1
                    x+=1
                end
            end

            #Check if expand is true, then expands the travel plans
            if expand == true
                temp = all_travel_stops.clone
                all_travel_stops = Array(Array(Hash(String, String | Int32))).new
                x=0
                loop do
                    all_travel_stops << expand_travel(temp[x])
                    break if x>=temp.size-1
                    x+=1
                end
            end

            #Define the response type as application/json and status 200
            env.response.content_type = "application/json"
            env.response.status_code = 200

            #Response with all travel plans
            temp = {"id" => all_ids[0], "travel_stops" => all_travel_stops[0]}
            all_plans = [temp]
            i=1
            loop do
                break if i > all_ids.size-1
                temp = {"id" => all_ids[i], "travel_stops" => all_travel_stops[i]}
                all_plans << temp
                i+=1
            end
            all_plans.to_json
        #DB is empty
        else
            #Define the response type as application/json and status 200
            env.response.content_type = "application/json"
            env.response.status_code = 200
            temp = [] of JSON
            temp.to_json
        end
    end

    #Get a specific travel plan
    get "/travel_plans/:id" do |env|
        #Receive the ID from the request url
        id = env.params.url["id"]?

        #Search the travel_stops in the DB
        travel_stops = get_stops(id)

        #If the ID don't exist, respond with status 403 and an error message
        if travel_stops[0] == 0
            env.response.content_type = "application/json"
            env.response.status_code = 403
            {message: "ERROR: ID not found!"}.to_json
        #ID exists
        else
            #Receive the query parameter optimize
            optimize = get_optimize(env)

            #Receive the query parameter expand
            expand = get_expand(env)

            #Check if optimize is true, then optimizes the travel plans
            if optimize == true
                travel_stops = optimize_travel(travel_stops)
            end

            #Check if expand is true, then expands the travel plans
            if expand == true
                travel_stops = expand_travel(travel_stops)
            end

            #Define the response type as application/json and status 200
            env.response.content_type = "application/json"
            env.response.status_code = 200

            #Response with the specific travel plan
            travel_plan = {"id" => id, "travel_stops" => travel_stops}
            travel_plan.to_json
        end
    end

    #Update an existing travel plan
    put "/travel_plans/:id" do |env|
        #Receive the ID from the request url
        id = env.params.url["id"]?

        #Search the travel_stops in the DB
        travel_stops = get_stops(id)

        #If the ID don't exists, respond with status 403 and an error message
        if travel_stops[0] == 0
            env.response.content_type = "application/json"
            env.response.status_code = 403
            {message: "ERROR: ID not found!"}.to_json
        else
            #Receive the new Array as String from the request body
            travel_stops = env.params.body["travel_stops"]?

            #If the request body is empty, respond with status 403 and an error message
            if !travel_stops
                env.response.content_type = "application/json"
                env.response.status_code = 403
                {message: "ERROR: The request body must not be empty, travel_stops array required!"}.to_json
            #ID exists
            else
                #Cast from String to Array(Int32)
                travel_stops = travel_stops.delete(" []")
                travel_stops = travel_stops.split(",")
                travel_stops = travel_stops.map {|x| x.to_i32?}

                #Update the DB
                Travels.where {_id == id}.update { {:travel_stops => travel_stops.to_json} }

                #Define the response type as application/json and status 200
                env.response.content_type = "application/json"
                env.response.status_code = 200

                #Response with the ID and Array updated in the DB
                {id: id, travel_stops: travel_stops}.to_json
            end
        end
    end

    #If the ID for PUT is null, respond with status 403 and an error message
    put "/travel_plans" do |env|
        env.response.content_type = "application/json"
        env.response.status_code = 403
        {message: "ERROR: The ID must not be null!"}.to_json
    end

    #Delete an existing trave plan
    delete "/travel_plans/:id" do |env|
        #Receive the ID from the request URL
        id = env.params.url["id"]?

        #Search the travel_stops in the DB
        travel_stops = get_stops(id)

        #If the ID don't exists, respond with status 403 and an error message
        if travel_stops[0] == 0
            env.response.content_type = "application/json"
            env.response.status_code = 403
            {message: "ERROR: ID not found!"}.to_json
        #ID exists
        else
            #Delete in DB
            Travels.where {_id == id}.delete

            #Define the response status as 204
            env.response.status_code = 204
        end
    end

    #If the ID for DELETE is null, respond with status 403 and an error message
    delete "/travel_plans" do |env|
        env.response.content_type = "application/json"
        env.response.status_code = 403
        {message: "ERROR: The ID must not be null!"}.to_json
    end
end

### Functions ###

#Receive the query parameter optimize, if null, it's false by default
def get_optimize(env)
    optimize = false
    temp = env.params.query["optimize"]?
    if temp
        temp = temp.downcase
        if temp == "true"
            optimize = true
        end
    end
    return optimize
end

#Receive the query parameter expand, if null, it's false by default
def get_expand(env)
    expand = false
    temp = env.params.query["expand"]?
    if temp
        temp = temp.downcase
        if temp == "true"
            expand = true
        end
    end
    return expand
end

#Optimize the travels as described in the docs
def optimize_travel(travel_stops)
    #Get the informations about all locations in the Array
    locations = Array(JSON::Any).new
    travel_stops.each do |x|
        response = HTTP::Client.get "https://rickandmortyapi.com/api/location/#{x}"
        response = response.body
        locations << JSON.parse(response)
    end

    #Find the popularity of each location
    pop_locations = Array(Hash(String, String | Int32)).new
    locations.each do |x|
        popularity = 0
        residents = x["residents"].as_a
        residents.each do |y|
            response = HTTP::Client.get y.to_s
            response = response.body
            response = JSON.parse(response)
            popularity+= response["episode"].size
        end
        temp = {"id" => x["id"].as_i, "location" => x["name"].as_s, "dimension" => x["dimension"].as_s, "location_popularity" => popularity}
        pop_locations <<  temp
    end

    #Find the average popularity of each dimension
    pop_dimensions = Hash(String, Array(Int32)).new
    pop_locations.each do |x|
        if pop_dimensions.has_key?(x["dimension"].to_s)
            pop_dimensions[x["dimension"].to_s][0] += x["location_popularity"].to_i32
            pop_dimensions[x["dimension"].to_s][1] += 1
        else
            pop_dimensions[x["dimension"].to_s] = [x["location_popularity"].to_i32,1]
        end
    end

    #Add the dimension popularity to the locations Array
    x = 0
    loop do
        pop_locations[x]["dimension_popularity"] = (pop_dimensions[pop_locations[x]["dimension"]][0]/pop_dimensions[pop_locations[x]["dimension"]][1]).to_i32
        break if x >= locations.size-1
        x+=1
    end
    
    #Order by dimension popularity
    pop_locations.sort_by! {|x| x["dimension_popularity"].to_i32}

    #Order by alphabetical order of the dimensions
    dimensions = pop_locations.group_by {|x| x["dimension"]}
    dimensions_keys = dimensions.keys
    x = 0
    loop do
        break if x>dimensions_keys.size-2
        if dimensions[dimensions.keys[x]][0]["dimension_popularity"]==dimensions[dimensions.keys[x+1]][0]["dimension_popularity"]
            result = compare_strings(dimensions.keys[x].to_s, dimensions.keys[x+1].to_s)
            if result == 1
                dimensions_keys.swap(x, x+1)
            end
        end
        x+=1
    end
    pop_locations = Array(Hash(String, String | Int32)).new
    dimensions.each do |key, x|
        x.each do |y|
            pop_locations << y
        end
    end
    
    #Order by location popularity
    dimensions = pop_locations.group_by {|x| x["dimension"]}
    dimensions.each do |key, x|
        x.sort_by! {|y| y["location_popularity"].to_i32}
    end
    
    #Order by alphabetical order of the locations
    dimensions.each do |key, x|
        y = 0
        break if y>x.size-2
        if x[y]["location_popularity"]==x[y+1]["location_popularity"] && x.size>1
            result = compare_strings(x[y]["location"].to_s, x[y+1]["location"].to_s)
            if result == 1
                x.swap(y, y+1)
            end
        end
        y+=1
    end
    pop_locations = Array(Hash(String, String | Int32)).new
    dimensions.each do |key, x|
        x.each do |y|
            pop_locations << y
        end
    end

    #Return the optimized Array
    locations = Array(Int32 | Nil).new
    pop_locations.each do |x|
        locations << x["id"].to_i32
    end
    return locations
end

#Expand the Array as described in the docs
def expand_travel(travel_stops)
    #Get the informations about all locations in the Array
    locations = Array(JSON::Any).new
    travel_stops.each do |x|
        response = HTTP::Client.get "https://rickandmortyapi.com/api/location/#{x}"
        response = response.body
        locations << JSON.parse(response)
    end

    #Save all the informations in a new Array with the correct format
    expanded_array = Array(Hash(String, String | Int32)).new
    locations.each do |x|
        temp = Hash(String, String | Int32).new
        temp = {"id" => x["id"].as_i, "name" => x["name"].as_s, "type" => x["type"].as_s, "dimension" => x["dimension"].as_s}
        expanded_array << temp
    end

    #Return the expanded Array
    return expanded_array
end

#Compare two strings and return the first in alphabetical order
def compare_strings(string1, string2)
    x=0
    loop do
        if string1[x]<string2[x]
            return -1
        elsif string1[x]>string2[x]
            return 1
        end
        break if x>=string1.size-1 || x>=string2.size-1
        x+=1
    end
    if string1.size<string2.size
        return 1
    elsif string1.size>string2.size
        return -1
    else
        return 0
    end
end

#Search all stops Arrays in the DB, formats and return everything in a single new Array
def get_all_stops()
    all_travel_stops = Travels.all.pluck(:travel_stops)
    all_travel_stops = all_travel_stops.to_json
    all_travel_stops = all_travel_stops.split("],[")
    all_travel_stops = all_travel_stops.map {|x| x.delete("[]")}
    all_travel_stops = all_travel_stops.map {|x| x.split(",")}
    all_travel_stops = all_travel_stops.map {|x| x.map {|y| y.to_i32?}}
    return all_travel_stops
end

#Search a specific stops Array in the DB, formats and return it
def get_stops(id)
    temp = Travels.where {_id == id}
    temp = temp.to_json
    travel_stops = JSON.parse(temp)

    #Check if the element exists
    if travel_stops.size != 0
        travel_stops = travel_stops[0]["travel_stops"].as_a
        travel_stops = travel_stops.map {|x| x.as_i}
        return travel_stops
    else
        return [0]
    end
end

#Search all IDs in the DB, formats and return everything in a single new Array
def get_all_ids()
    all_ids = Travels.all.pluck(:id)
    all_ids = all_ids.to_json
    all_ids = all_ids.delete("[]")
    all_ids = all_ids.split(",")
    all_ids = all_ids.map {|x| x.to_i32?}
    return all_ids
end

Kemal.run