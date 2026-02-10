-- Example test model demonstrating the use of the trim parameter
-- Users can adapt this for their own testing

with sample_data as (
  
  select 'John' as first_name, 'Doe' as last_name, 1 as id
  union all
  select ' John ' as first_name, ' Doe ' as last_name, 2 as id  -- Same names with extra spaces
  union all
  select 'Jane' as first_name, 'Smith' as last_name, 3 as id
  
),

hashed_keys as (
  
  select 
    id,
    first_name,
    last_name,
    -- Without trim - different hashes for different spacing
    {{ dbt_utils.generate_surrogate_key(['first_name', 'last_name'], trim_whitespace=false) }} as key_without_trim,
    -- With trim - same hashes for logically same values
    {{ dbt_utils.generate_surrogate_key(['first_name', 'last_name'], trim_whitespace=true) }} as key_with_trim
  
  from sample_data
  
)

select * from hashed_keys