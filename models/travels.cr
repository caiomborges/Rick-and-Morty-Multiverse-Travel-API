class Travels < Jennifer::Model::Base
  with_timestamps

  mapping(
    id: Primary64,
    travel_stops: JSON::Any,
    created_at: Time?,
    updated_at: Time?,
  )
end
