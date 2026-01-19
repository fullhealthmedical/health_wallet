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

---

# FHM Coding Task: Import laboratory results
Laboratories use [HL7 format](https://www.hl7.org/implement/standards/) to share information between systems. 

Add a feature that allows users to upload laboratory results files in a simplified HL7 format. These files contain patient information, assessment references, and observation results. The system should parse these files and create or update the corresponding records in the database. The imported data will be visible in the patient's assessment page.

## File Format
The simplified HL7 files will follow the structure described below:
```
patient_name|patient_dob|patient_sex_at_birth|assessment_reference
code|result|units
code|result|units
```
### Example Files
Each file will contain data for one or more assessments. Here are some example files:
John_Doe_HL7.txt
```
John Doe|1985-03-15|M|REF-2024-001
8480-6|120|mmHg
8462-4|80|mmHg
8867-4|72|bpm
8310-5|98.6|°F
```
Jane_Smith_HL7.txt
```
Jane Smith|1990-07-22|F|REF-2024-002
2708-6|98|%
29463-7|65.5|kg
8302-2|165|cm
2339-0|95|mg/dL
```
Multiple_Patients_HL7.txt
```
John Doe|1985-03-15|M|REF-2024-003
2093-3|190|mg/dL
Jane Smith|1990-07-22|F|REF-2024-004
8480-6|118|mmHg
8462-4|78|mmHg
Josh Brown|1978-11-05|M|REF-2024-005
8867-4|75|bpm
8310-5|99.1|°F
```

### Observation codes
For non existing observations in the assessments, they should be created if present in the following list:
| LOINC Code | Description |
| :--- | :--- |
| **8480-6** | Blood Pressure (Systolic) |
| **8462-4** | Blood Pressure (Diastolic) |
| **8867-4** | Heart Rate |
| **8310-5** | Body Temperature |
| **9279-1** | Respiratory Rate |
| **2708-6** | Oxygen Saturation |
| **29463-7** | Body Weight |
| **8302-2** | Body Height |
| **2339-0** | Blood Glucose |
| **2093-3** | Cholesterol |

## Data model
The current data model is composed by:
- `Patient`: represent a patient with name, date of birth and sex at birth.
- `Assessment`: a patient's health assessment, containing the taken observations.
- `Observation`: represent a single measurement taken for the assessment, 
  identified by a code, with a value and units. For this exercise, we will use it to represent laboratory results.
*If needed, you can extend the data model to accommodate the import requirements.*

## Requirements
### 1. Upload files through web interface
- Add a new page to allow users to upload laboratory result files
- Trigger background import process upon upload
- Provide feedback to user on import status (e.g., pending, completed, failed)
### 2. Parse and Import Data
- Run background job to process uploaded files
- Read, parse, and validate the file content
- For each file, extract patient information, assessment reference, and observations
- Create or update `Patient`, `Assessment`, and `Observation` records in the database 
  following these rules:
  - **Patient:** Find existing by `name` + `dob` + `sex_at_birth`, or create new
  - **Assessment:** Find existing by `reference` within patient, or create new
  - **Observation:** Find existing by `code` within assessment and update `value`/`units`, or create new
