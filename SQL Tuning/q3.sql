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

-- 3. List the names of students who have taken course v4 (crsCode).
-- DROP INDEX `PRIMARY` ON Student;
EXPLAIN ANALYZE
SELECT name FROM Student WHERE id IN (SELECT studId FROM Transcript WHERE crsCode = @v4);
/*# EXPLAIN
-> Inner hash join (student.id = `<subquery2>`.studId)  (cost=414.91 rows=400) (actual time=0.128..0.264 rows=2 loops=1)
    -> Table scan on Student  (cost=5.04 rows=400) (actual time=0.004..0.160 rows=400 loops=1)
    -> Hash
        -> Table scan on <subquery2>  (cost=0.26..2.62 rows=10) (actual time=0.000..0.001 rows=2 loops=1)
            -> Materialize with deduplication  (cost=11.51..13.88 rows=10) (actual time=0.063..0.064 rows=2 loops=1)
                -> Filter: (transcript.studId is not null)  (cost=10.25 rows=10) (actual time=0.024..0.058 rows=2 loops=1)
                    -> Filter: (transcript.crsCode = <cache>((@v4)))  (cost=10.25 rows=10) (actual time=0.023..0.058 rows=2 loops=1)
                        -> Table scan on Transcript  (cost=10.25 rows=100) (actual time=0.007..0.045 rows=100 loops=1)
*/

/*
loop join opeartion is theexpensive. 
Table scan on Student is more expensive than table scan on Transcript since the Student table is larger than the Transcript.
Both tables don't have indexes.
Solution: create primary index on Student table
create composite primary index on Transcript table.
*/

ALTER TABLE Student ADD PRIMARY KEY (id);
ALTER TABLE Transcript ADD PRIMARY KEY (studId, crsCode);

EXPLAIN ANALYZE
SELECT name
FROM Student, Transcript
WHERE Student.id = Transcript.studId AND Transcript.crsCode = @v4 ;
/*# EXPLAIN
-> Nested loop inner join  (cost=3.63 rows=10) (actual time=0.084..0.087 rows=2 loops=1)
    -> Filter: (`<subquery2>`.studId is not null)  (cost=10.33..2.00 rows=10) (actual time=0.073..0.074 rows=2 loops=1)
        -> Table scan on <subquery2>  (cost=0.26..2.62 rows=10) (actual time=0.000..0.001 rows=2 loops=1)
            -> Materialize with deduplication  (cost=11.51..13.88 rows=10) (actual time=0.073..0.073 rows=2 loops=1)
                -> Filter: (transcript.studId is not null)  (cost=10.25 rows=10) (actual time=0.036..0.068 rows=2 loops=1)
                    -> Filter: (transcript.crsCode = <cache>((@v4)))  (cost=10.25 rows=10) (actual time=0.036..0.068 rows=2 loops=1)
                        -> Table scan on Transcript  (cost=10.25 rows=100) (actual time=0.019..0.057 rows=100 loops=1)
    -> Single-row index lookup on Student using PRIMARY (id=`<subquery2>`.studId)  (cost=0.72 rows=1) (actual time=0.006..0.006 rows=1 loops=2)
*/
