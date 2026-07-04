select *
from {{ ref('int_business_names_cleaned') }}
where (duplicate_rank = 1 and flag_duplicate != 0)
   or (duplicate_rank > 1 and flag_duplicate != 1)
   or duplicate_rank < 1
