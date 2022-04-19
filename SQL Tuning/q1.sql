USE springboardopt;

-- -------------------------------------
SET @v1 = 1612521;
SET @v2 = 1145072;
SET @v3 = 1828467;
SET @v4 = 'MGT382';
SET @v5 = 'Amber Hill';
SET @v6 = 'MGT';
SET @v7 = 'EE';			  
SET @v8 = 'MAT';

-- 1. List the name of the student with id equal to v1 (id).
EXPLAIN ANALYZE
SELECT name FROM Student WHERE id = @v1;
/* '-> Filter: (student.id = <cache>((@v1)))  (cost=41.00 rows=40) (actual time=0.095..0.218 rows=1 loops=1)    
-> Table scan on Student  (cost=41.00 rows=400) (actual time=0.058..0.200 rows=400 loops=1)
*/
/*
The speed is low because the query use full table scan, the original table doesn't have any index.
Solution: create primary index on uid
*/
ALTER TABLE Student ADD PRIMARY KEY (id);
EXPLAIN analyze
SELECT Student.name FROM Student WHERE id = @v1;
/*'-> Rows fetched before execution  (cost=0.00..0.00 rows=1) (actual time=0.000..0.000 rows=1 loops=1)\n'
*/
