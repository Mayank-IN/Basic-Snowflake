-------Load raw json-------
use manage_db;
create or replace schema cosmos;

create or replace table raw_file(
    raw variant
);

select * from raw_file;

create or replace file format json_format
type = json;

create or replace stage manage_db.external_stages.json_stage
    url='s3://bucketsnowflake-jsondemo'
    file_format = json_format;
     
desc stage json_stage;
list @manage_db.external_stages.json_stage;

copy into raw_file from @manage_db.external_stages.json_stage
file_format = json_format;

select * from raw_file;

// Handle raw data
select raw:first_name::string as first_name from raw_file;
select $1:city::string as city from raw_file;

select 
    $1:id::int as id,
    $1:first_name::string as first_name,
    $1:last_name::string as last_name,
    $1:city::string as city,
    $1:gender::string as gender
from raw_file;


// Handle nested data
select $1:job::string as job from raw_file;

select 
    $1:job.title::string as job_title,
    $1:job.salary::int as salary from raw_file;
    
    
//Handle arrays
select $1:prev_company::string as prev_company from raw_file;
select 
    $1:id::int as id,
    $1:first_name::string as first_name,
    $1:last_name::string as last_name,
    $1:prev_company as prev_company from raw_file;

select array_size($1:prev_company) as prev_companies from raw_file;

create or replace mattable1
as
    select 
        $1:id::int as id,
        $1:first_name::string as first_name,
        $1:last_name::string as last_name,
        $1:gender::string as gender,
        $1:job.title::string as job_title,
        $1:job.salary::int as salary,
        $1:prev_company[0]::string as prev_company
    from raw_file
    union all
    select 
        $1:id::int as id,
        $1:first_name::string as first_name,
        $1:last_name::string as last_name,
        $1:gender::string as gender,
        $1:job.title::string as job_title,
        $1:job.salary::int as salary,
        $1:prev_company[1]::string as prev_company
    from raw_file order by id ;

select * from raw_file, table(flatten($1:prev_company));

select * from table1;


//Handle arrays of objects
select * from raw_file;
select $1:spoken_languages[0] as first_languages from raw_file;

select 
    $1:id::int as id,
    $1:first_name::string as first_name,
    $1:last_name::string as last_name,
    array_size($1:spoken_languages) as spoken_languages from raw_file;
    
select 
    $1:id::int as id,
    $1:first_name::string as first_name,
    $1:last_name::string as last_name,
    $1:spoken_languages[0].language::string as first_language,
    $1:spoken_languages[0].level::string as level from raw_file;
    
    
//flattten function
select * from raw_file, table(flatten($1:spoken_languages));
select 
    f.value:language::string as language,
    f.value:level::string as level
    from raw_file, table(flatten($1:spoken_languages)) as f;

select 
    f.value:language::string as language,
    f.value:level::string as level
    from raw_file, table(flatten($1:spoken_languages)) as f;

select 
    raw:id::int as id,
    raw:first_name::string as first_name,
    raw:last_name::string as last_name,
    f.value:language::string as language,
    f.value:level::string as level
    from raw_file, table(flatten($1:spoken_languages)) as f order by raw:id;
          
select * from raw_file;



            

