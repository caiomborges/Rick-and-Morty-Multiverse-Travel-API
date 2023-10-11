require "./config/*" # here load jennifer and all required configurations
require "./models/*"
require "./db/migrations/*"
require "sam"

load_dependencies "jennifer"

# ...

Sam.help