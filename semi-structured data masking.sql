use database manage_db;
use schema cosmos;

select * from raw_file;

//function for masking an object
create or replace function json_masking(v variant)
returns variant
language javascript
AS
$$
v['salary'] = "**masked**";
return V;
$$;

show functions like '%json_masking';

//masking policy
Create or replace masking policy semi_data_masking 
as (val variant) returns variant ->
    case when true 
        then array_json_masking(val)
    else array_json_masking(val)
End;

show masking policies like '%masking';

//apply masking policy
alter table raw_file modify column "job" 
set masking policy Semi_Data_Masking;

select * from raw_file;

select * 
from table(information_schema.policy_references('semi_data_masking'));


//masking arrays of objects

//function
create or replace function array_json_masking(v variant)
returns variant
language javascript
AS
$$
for( var i = 0; i<V.length; i++){
    V[i]['level'] = "**masked**";
}
return V;
$$;

//masking policy
Create or replace masking policy array_data_masking 
as (val variant) returns variant ->
    case when true 
        then array_json_masking(val)
    else array_json_masking(val)
End;

//applying
alter table raw_file modify column "spoken_languages" 
set masking policy array_data_masking;

select "spoken_languages" from raw_file;

alter table raw_file modify column "spoken_languages" unset masking policy;
alter table raw_file modify column "job" unset masking policy;

drop masking policy semi_data_masking;
drop masking policy array_data_masking;

drop function json_masking;
drop function array_json_masking;
