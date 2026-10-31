# 1. Creates a private network channel; hides warnings if it already exists; continues script safely
docker network create mongo-net 2>/dev/null || true

# 2. Launches the MongoDB container in the background (-d)
docker run -d \
  -p 27017:27017 \ # Connects your local machine's database port to the container port
  --name mongo \ # Assigns the system name 'mongo' to this running container
  --network mongo-net \ # attaches this container to our private virtual network
  -v ./custom-db:/data/db \ # Keeps database records safely stored on your local hard drive
  -e MONGO_INITDB_ROOT_USERNAME='root' \ # Configures the admin username
  -e MONGO_INITDB_ROOT_PASSWORD='123' \ # Configures the admin password
  mongo:latest # The image template Docker will download and use

# 3. Launches the Browser UI container in the background (-d)
docker run -d \
  -p 8081:8081 \ # Exposes port 8081 so you can visit http://localhost:8081
  --name mongo-web-ui \ # Assigns the system name 'mongo-web-ui' to this container
  --network mongo-net \ # Attaches it to the same network so it can find the database container
  -e ME_CONFIG_MONGODB_URL='mongodb://root:123@mongo:27017/?authSource=admin' \ # Feeds the login details and target address ('mongo') to the UI
  mongo-express:latest # The web application image template Docker will run
