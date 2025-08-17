-- Create databases for microservices
CREATE DATABASE user_db;
CREATE DATABASE product_db;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE user_db TO postgres;
GRANT ALL PRIVILEGES ON DATABASE product_db TO postgres;