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

-- DROP INDEX `PRIMARY` ON Student;
-- 6. List the names of students who have taken all courses offered by department v8 (deptId).
EXPLAIN ANALYZE
SELECT name FROM Student,
	(SELECT studId
	FROM Transcript
		WHERE crsCode IN
		(SELECT crsCode FROM Course WHERE deptId = @v8 AND crsCode IN (SELECT crsCode FROM Teaching))
		GROUP BY studId
		HAVING COUNT(*) = 
			(SELECT COUNT(*) FROM Course WHERE deptId = @v8 AND crsCode IN (SELECT crsCode FROM Teaching))) as alias
WHERE id = alias.studId;
/*-> Nested loop inner join  (cost=1041.00 rows=0) (actual time=4.276..4.276 rows=0 loops=1)
    -> Table scan on Student  (cost=41.00 rows=400) (actual time=0.065..0.259 rows=400 loops=1)
    -> Covering index lookup on alias using <auto_key0> (studId=student.id)  (actual time=0.000..0.000 rows=0 loops=400)
        -> Materialize  (cost=0.00..0.00 rows=0) (actual time=3.971..3.971 rows=0 loops=1)
            -> Filter: (count(0) = (select #5))  (actual time=3.892..3.892 rows=0 loops=1)
                -> Table scan on <temporary>  (actual time=0.000..0.001 rows=19 loops=1)
                    -> Aggregate using temporary table  (actual time=3.889..3.890 rows=19 loops=1)
                        -> Nested loop inner join  (cost=1020.25 rows=10000) (actual time=0.652..0.762 rows=19 loops=1)
                            -> Filter: (transcript.crsCode is not null)  (cost=10.25 rows=100) (actual time=0.008..0.068 rows=100 loops=1)
                                -> Table scan on Transcript  (cost=10.25 rows=100) (actual time=0.008..0.061 rows=100 loops=1)
                            -> Single-row index lookup on <subquery3> using <auto_distinct_key> (crsCode=transcript.crsCode)  (actual time=0.000..0.000 rows=0 loops=100)
                                -> Materialize with deduplication  (cost=120.52..120.52 rows=100) (actual time=0.682..0.683 rows=19 loops=1)
                                    -> Filter: (course.crsCode is not null)  (cost=110.52 rows=100) (actual time=0.537..0.620 rows=19 loops=1)
                                        -> Filter: (teaching.crsCode = course.crsCode)  (cost=110.52 rows=100) (actual time=0.537..0.618 rows=19 loops=1)
                                            -> Inner hash join (<hash>(teaching.crsCode)=<hash>(course.crsCode))  (cost=110.52 rows=100) (actual time=0.535..0.612 rows=19 loops=1)
                                                -> Table scan on Teaching  (cost=0.13 rows=100) (actual time=0.432..0.491 rows=100 loops=1)
                                                -> Hash
                                                    -> Filter: (course.deptId = <cache>((@v8)))  (cost=10.25 rows=10) (actual time=0.015..0.081 rows=19 loops=1)
                                                        -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.007..0.064 rows=100 loops=1)
                -> Select #5 (subquery in condition; uncacheable)
                    -> Aggregate: count(0)  (cost=211.25 rows=1000) (actual time=0.159..0.159 rows=1 loops=19)
                        -> Nested loop inner join  (cost=111.25 rows=1000) (actual time=0.084..0.158 rows=19 loops=19)
                            -> Filter: ((course.deptId = <cache>((@v8))) and (course.crsCode is not null))  (cost=10.25 rows=10) (actual time=0.003..0.064 rows=19 loops=19)
                                -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.001..0.052 rows=100 loops=19)
                            -> Single-row index lookup on <subquery6> using <auto_distinct_key> (crsCode=course.crsCode)  (actual time=0.000..0.000 rows=1 loops=361)
                                -> Materialize with deduplication  (cost=20.25..20.25 rows=100) (actual time=0.089..0.090 rows=97 loops=19)
                                    -> Filter: (teaching.crsCode is not null)  (cost=10.25 rows=100) (actual time=0.001..0.052 rows=100 loops=19)
                                        -> Table scan on Teaching  (cost=10.25 rows=100) (actual time=0.001..0.045 rows=100 loops=19)
            -> Select #5 (subquery in projection; uncacheable)
                -> Aggregate: count(0)  (cost=211.25 rows=1000) (actual time=0.159..0.159 rows=1 loops=19)
                    -> Nested loop inner join  (cost=111.25 rows=1000) (actual time=0.084..0.158 rows=19 loops=19)
                        -> Filter: ((course.deptId = <cache>((@v8))) and (course.crsCode is not null))  (cost=10.25 rows=10) (actual time=0.003..0.064 rows=19 loops=19)
                            -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.001..0.052 rows=100 loops=19)
                        -> Single-row index lookup on <subquery6> using <auto_distinct_key> (crsCode=course.crsCode)  (actual time=0.000..0.000 rows=1 loops=361)
                            -> Materialize with deduplication  (cost=20.25..20.25 rows=100) (actual time=0.089..0.090 rows=97 loops=19)
                                -> Filter: (teaching.crsCode is not null)  (cost=10.25 rows=100) (actual time=0.001..0.052 rows=100 loops=19)
                                    -> Table scan on Teaching  (cost=10.25 rows=100) (actual time=0.001..0.045 rows=100 loops=19)
*/
/*Add primary key decrease the actual time*/
ALTER TABLE Student ADD PRIMARY KEY (id);
EXPLAIN ANALYZE
SELECT name FROM Student,
	(SELECT studId
	FROM Transcript
		WHERE crsCode IN
		(SELECT crsCode FROM Course WHERE deptId = @v8 AND crsCode IN (SELECT crsCode FROM Teaching))
		GROUP BY studId
		HAVING COUNT(*) = 
			(SELECT COUNT(*) FROM Course WHERE deptId = @v8 AND crsCode IN (SELECT crsCode FROM Teaching))) as alias
WHERE id = alias.studId
/*-> Nested loop inner join  (cost=86.25 rows=100) (actual time=2.754..2.754 rows=0 loops=1)
    -> Filter: (alias.studId is not null)  (cost=0.14..13.75 rows=100) (actual time=2.754..2.754 rows=0 loops=1)
        -> Table scan on alias  (cost=2.50..2.50 rows=0) (actual time=0.000..0.000 rows=0 loops=1)
            -> Materialize  (cost=2.50..2.50 rows=0) (actual time=2.753..2.753 rows=0 loops=1)
                -> Filter: (count(0) = (select #5))  (actual time=2.750..2.750 rows=0 loops=1)
                    -> Table scan on <temporary>  (actual time=0.000..0.001 rows=19 loops=1)
                        -> Aggregate using temporary table  (actual time=2.746..2.748 rows=19 loops=1)
                            -> Nested loop inner join  (cost=1020.25 rows=10000) (actual time=0.146..0.238 rows=19 loops=1)
                                -> Filter: (transcript.crsCode is not null)  (cost=10.25 rows=100) (actual time=0.009..0.057 rows=100 loops=1)
                                    -> Table scan on Transcript  (cost=10.25 rows=100) (actual time=0.008..0.051 rows=100 loops=1)
                                -> Single-row index lookup on <subquery3> using <auto_distinct_key> (crsCode=transcript.crsCode)  (actual time=0.000..0.000 rows=0 loops=100)
                                    -> Materialize with deduplication  (cost=120.52..120.52 rows=100) (actual time=0.169..0.170 rows=19 loops=1)
                                        -> Filter: (course.crsCode is not null)  (cost=110.52 rows=100) (actual time=0.067..0.124 rows=19 loops=1)
                                            -> Filter: (teaching.crsCode = course.crsCode)  (cost=110.52 rows=100) (actual time=0.067..0.122 rows=19 loops=1)
                                                -> Inner hash join (<hash>(teaching.crsCode)=<hash>(course.crsCode))  (cost=110.52 rows=100) (actual time=0.066..0.119 rows=19 loops=1)
                                                    -> Table scan on Teaching  (cost=0.13 rows=100) (actual time=0.003..0.040 rows=100 loops=1)
                                                    -> Hash
                                                        -> Filter: (course.deptId = <cache>((@v8)))  (cost=10.25 rows=10) (actual time=0.007..0.051 rows=19 loops=1)
                                                            -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.003..0.039 rows=100 loops=1)
                    -> Select #5 (subquery in condition; uncacheable)
                        -> Aggregate: count(0)  (cost=211.25 rows=1000) (actual time=0.128..0.128 rows=1 loops=19)
                            -> Nested loop inner join  (cost=111.25 rows=1000) (actual time=0.066..0.127 rows=19 loops=19)
                                -> Filter: ((course.deptId = <cache>((@v8))) and (course.crsCode is not null))  (cost=10.25 rows=10) (actual time=0.002..0.053 rows=19 loops=19)
                                    -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.001..0.042 rows=100 loops=19)
                                -> Single-row index lookup on <subquery6> using <auto_distinct_key> (crsCode=course.crsCode)  (actual time=0.000..0.000 rows=1 loops=361)
                                    -> Materialize with deduplication  (cost=20.25..20.25 rows=100) (actual time=0.070..0.072 rows=97 loops=19)
                                        -> Filter: (teaching.crsCode is not null)  (cost=10.25 rows=100) (actual time=0.001..0.043 rows=100 loops=19)
                                            -> Table scan on Teaching  (cost=10.25 rows=100) (actual time=0.001..0.037 rows=100 loops=19)
                -> Select #5 (subquery in projection; uncacheable)
                    -> Aggregate: count(0)  (cost=211.25 rows=1000) (actual time=0.128..0.128 rows=1 loops=19)
                        -> Nested loop inner join  (cost=111.25 rows=1000) (actual time=0.066..0.127 rows=19 loops=19)
                            -> Filter: ((course.deptId = <cache>((@v8))) and (course.crsCode is not null))  (cost=10.25 rows=10) (actual time=0.002..0.053 rows=19 loops=19)
                                -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.001..0.042 rows=100 loops=19)
                            -> Single-row index lookup on <subquery6> using <auto_distinct_key> (crsCode=course.crsCode)  (actual time=0.000..0.000 rows=1 loops=361)
                                -> Materialize with deduplication  (cost=20.25..20.25 rows=100) (actual time=0.070..0.072 rows=97 loops=19)
                                    -> Filter: (teaching.crsCode is not null)  (cost=10.25 rows=100) (actual time=0.001..0.043 rows=100 loops=19)
                                        -> Table scan on Teaching  (cost=10.25 rows=100) (actual time=0.001..0.037 rows=100 loops=19)
    -> Single-row index lookup on Student using PRIMARY (id=alias.studId)  (cost=0.63 rows=1) (never executed)
*/