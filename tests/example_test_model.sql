-- Test model demonstrating trim functionality
-- Validates that trimming produces consistent hashes

with test_data as (
  
  select 'customer_123' as customer_id, 'US' as region, 1 as id
  union all
  select ' customer_123 ' as customer_id, ' US ' as region, 2 as id  -- Same data with spaces
  union all
  select 'customer_456' as customer_id, 'CA' as region, 3 as id
  
),

hashed_keys as (
  
  select 
    id,
    customer_id,
    region,
    -- Without trim - different hashes for id 1 and 2
    {{ dbt_utils.generate_surrogate_key(
        ['customer_id', 'region'], 
        trim_whitespace=false
    ) }} as key_without_trim,
    -- With trim - SAME hash for id 1 and 2
    {{ dbt_utils.generate_surrogate_key(
        ['customer_id', 'region'], 
        trim_whitespace=true
    ) }} as key_with_trim
  
  from test_data
  
)

select * from hashed_keys

-- To validate: 
-- key_without_trim should be DIFFERENT for id 1 and 2
-- key_with_trim should be IDENTICAL for id 1 and 2