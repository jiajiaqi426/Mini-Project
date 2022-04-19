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

-- 2. List the names of students with id in the range of v2 (id) to v3 (inclusive).
/*
The speed is low because the query using full table scan for the range query.
Solution: create primary index on uid
*/
EXPLAIN ANALYZE 
SELECT name FROM Student WHERE id BETWEEN @v2 AND @v3;
-- DROP INDEX `PRIMARY` ON Student;
/*'-> '-> Filter: (student.id between <cache>((@v2)) and <cache>((@v3)))  (cost=5.44 rows=44) (actual time=0.050..0.193 rows=278 loops=1)\n    
-> Table scan on Student  (cost=5.44 rows=400) (actual time=0.021..0.171 rows=400 loops=1)\n'
*/

ALTER TABLE Student ADD PRIMARY KEY (id);
EXPLAIN analyze
SELECT name FROM Student WHERE id BETWEEN @v2 AND @v3;
/*'-> Filter: (student.id between <cache>((@v2)) and <cache>((@v3)))  (cost=56.47 rows=278) (actual time=0.010..0.091 rows=278 loops=1)
    -> Index range scan on Student using PRIMARY over (1145072 <= id <= 1828467)  (cost=56.47 rows=278) (actual time=0.008..0.074 rows=278 loops=1)'
*/