# Health Wallet

A Rails application for managing patient health records, assessments, and observations.

## Requirements

- Ruby 3.4+
- Rails 8.1+
- MongoDB 6.0+

## Quick Start with Docker

The fastest way to run the application in development:

```bash
# Build and start all services
docker compose up --build

# In a separate terminal, seed the database (first time only)
docker compose exec web bin/rails db:seed
```

Visit [http://localhost:3000](http://localhost:3000)

### Configuration

You can customize ports via environment variables:

```bash
# Use a different MongoDB port (default: 27017)
MONGODB_PORT=27018 docker compose up --build
```

### Common Docker Commands

```bash
# Start services in the background
docker compose up -d

# View logs
docker compose logs -f web

# Run Rails console
docker compose exec web bin/rails console

# Run tests
docker compose exec web bin/rails test

# Stop services
docker compose down

# Stop services and remove volumes (clean slate)
docker compose down -v
```

---

## Manual Setup (without Docker)

### Requirements

- Ruby 3.4+ installed locally
- MongoDB 6.0+ running locally or via Docker

### 1. Install Dependencies

```bash
bundle install
```

### 2. MongoDB Setup

The application uses MongoDB via Mongoid. You need a running MongoDB instance.

#### Option A: Local MongoDB Installation

**macOS (Homebrew):**
```bash
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
```

**Ubuntu/Debian:**
```bash
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
```

#### Option B: Docker (Recommended for Development)

Run MongoDB in a Docker container:

```bash
docker run -d \
  --name health_wallet_mongo \
  -p 27017:27017 \
  -v mongodb_data:/data/db \
  mongo
```

To stop/start the container:
```bash
docker stop health_wallet_mongo
docker start health_wallet_mongo
```

### 3. Database Configuration

The MongoDB connection is configured in `config/mongoid.yml`. Default settings connect to `localhost:27017`.

### 4. Seed the Database

Populate the database with sample data:

```bash
bin/rails db:seed
```

This creates:
- 25 patients with varied demographics
- Random assessments (0-5 per patient)
- Random observations (2-6 per assessment) with realistic health metrics

### 5. Run the Application

```bash
bin/rails server
```

Visit [http://localhost:3000](http://localhost:3000)

## Running Tests

```bash
bin/rails test
```

## Data Model

The application uses MongoDB with Mongoid ODM. The data model consists of three main entities:

```
┌─────────────┐       ┌──────────────┐       ┌─────────────────┐
│   Patient   │──────<│  Assessment  │──────<│   Observation   │
└─────────────┘ 1   * └──────────────┘ 1   * └─────────────────┘
                         (has_many)              (embeds_many)
```

