// Database to manage stage objects, fileformats etc.
CREATE OR REPLACE DATABASE MANAGE_DB;

CREATE OR REPLACE SCHEMA external_stages;


// Creating external stage with credentials
CREATE OR REPLACE STAGE aws_stage
    url='s3://bucketsnowflakes3'
    credentials=(aws_key_id='DUMMY_ID' aws_secret_key='abcd_key');


// Description of external stage
DESC STAGE aws_stage; 
    
    
// Alter external stage   
ALTER STAGE aws_stage
    SET credentials=(aws_key_id='DUMMY_ID' aws_secret_key='987xyz');
    
    
// Publicly accessible staging area    
CREATE OR REPLACE STAGE aws_stage
    url='s3://bucketsnowflakes3';


// List files in stage
LIST @aws_stage;


-- //Load data using copy command
-- COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
--     FROM @aws_stage
--     file_format= (type = csv field_delimiter=',' skip_header=1)
--     pattern='.*Order.*';
    

// Load data using copy command with fully qualified stage object
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
    FROM @MANAGE_DB.external_stages.aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1);


// List files contained in stage
LIST @MANAGE_DB.external_stages.aws_stage;    


// Copy command with specified file(s)
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
    FROM @MANAGE_DB.external_stages.aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails.csv');
    

// Copy command with pattern for file names
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
    FROM @MANAGE_DB.external_stages.aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*';
    

drop table OUR_FIRST_DB.PUBLIC.ORDERS;