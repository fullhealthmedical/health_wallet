# Health Wallet

A Rails application for managing patient health records, assessments, and observations.

## Requirements

- Ruby 3.4+
- Rails 8.1+
- MongoDB 6.0+

## Setup

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
