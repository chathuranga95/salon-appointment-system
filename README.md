## Overview

This is a minimal salon appointment management system designed and implemented using API first approach and [Ballerina lang](https://ballerina.io/).

## How to run locally

### Prerequisites
1. Ballerina 2201.9.2
   > Download and install from: https://ballerina.io/
2. MySQL database
   > Run MySQL server or have a remote MySQL server
   > Create database and the tables using the script: [`/resources/db.sql`](https://github.com/chathuranga95/salon-appointment-system/blob/main/resources/db.sql)

### Run
1. Configure the application

   >> Create `Config.toml` file in the `salon-appointment-system` directory root.

   >> Have the following configs.
   ```toml
   host=""
   username=""
   password=""
   database=""
   port=3306
   ```
3. Run the application
  ```sh
    cd salon-appointment-system
    bal run
```

### Debug
1. Install VScode: https://code.visualstudio.com/
2. Install Ballerina plugin: https://ballerina.io/learn/vs-code-extension/
3. Configure the application (step 1 on Run)
4. Run and debug from VScode.
