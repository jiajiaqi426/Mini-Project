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

-- 5. List the names of students who have taken a course from department v6 (deptId), but not v7.
EXPLAIN ANALYZE
SELECT * FROM Student, 
	(SELECT studId FROM Transcript, Course WHERE deptId = @v6 AND Course.crsCode = Transcript.crsCode
	AND studId NOT IN
	(SELECT studId FROM Transcript, Course WHERE deptId = @v7 AND Course.crsCode = Transcript.crsCode)) as alias
WHERE Student.id = alias.studId;
/*# EXPLAIN
-> Filter: <in_optimizer>(transcript.studId,<exists>(select #3) is false)  (cost=4112.69 rows=4000) (actual time=1.384..4.519 rows=30 loops=1)
    -> Inner hash join (student.id = transcript.studId)  (cost=4112.69 rows=4000) (actual time=1.073..1.264 rows=30 loops=1)
        -> Table scan on Student  (cost=0.06 rows=400) (actual time=0.008..0.179 rows=400 loops=1)
        -> Hash
            -> Filter: (transcript.crsCode = course.crsCode)  (cost=110.52 rows=100) (actual time=0.985..1.039 rows=30 loops=1)
                -> Inner hash join (<hash>(transcript.crsCode)=<hash>(course.crsCode))  (cost=110.52 rows=100) (actual time=0.984..1.034 rows=30 loops=1)
                    -> Table scan on Transcript  (cost=0.13 rows=100) (actual time=0.009..0.045 rows=100 loops=1)
                    -> Hash
                        -> Filter: (course.deptId = <cache>((@v6)))  (cost=10.25 rows=10) (actual time=0.917..0.961 rows=26 loops=1)
                            -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.913..0.949 rows=100 loops=1)
    -> Select #3 (subquery in condition; dependent)
        -> Limit: 1 row(s)  (cost=110.52 rows=1) (actual time=0.106..0.106 rows=0 loops=30)
            -> Filter: <if>(outer_field_is_not_null, <is_not_null_test>(transcript.studId), true)  (cost=110.52 rows=100) (actual time=0.106..0.106 rows=0 loops=30)
                -> Filter: (<if>(outer_field_is_not_null, ((<cache>(transcript.studId) = transcript.studId) or (transcript.studId is null)), true) and (transcript.crsCode = course.crsCode))  (cost=110.52 rows=100) (actual time=0.106..0.106 rows=0 loops=30)
                    -> Inner hash join (<hash>(transcript.crsCode)=<hash>(course.crsCode))  (cost=110.52 rows=100) (actual time=0.053..0.099 rows=34 loops=30)
                        -> Table scan on Transcript  (cost=0.13 rows=100) (actual time=0.001..0.037 rows=100 loops=30)
                        -> Hash
                            -> Filter: (course.deptId = <cache>((@v7)))  (cost=10.25 rows=10) (actual time=0.003..0.043 rows=32 loops=30)
                                -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.001..0.035 rows=100 loops=30)
*/
/*
Add the primary index in Student Table. 
The actual time reduce a lot
*/
ALTER TABLE Student ADD PRIMARY KEY (id);
EXPLAIN ANALYZE
SELECT * FROM Student, 
	(SELECT studId FROM Transcript, Course WHERE deptId = @v6 AND Course.crsCode = Transcript.crsCode
	AND studId NOT IN
	(SELECT studId FROM Transcript, Course WHERE deptId = @v7 AND Course.crsCode = Transcript.crsCode)) as alias
WHERE Student.id = alias.studId
/*-> Nested loop inner join  (cost=27.77 rows=10) (actual time=0.245..3.406 rows=30 loops=1)
    -> Filter: (transcript.crsCode = course.crsCode)  (cost=20.52 rows=10) (actual time=0.079..0.144 rows=30 loops=1)
        -> Inner hash join (<hash>(transcript.crsCode)=<hash>(course.crsCode))  (cost=20.52 rows=10) (actual time=0.079..0.139 rows=30 loops=1)
            -> Filter: (transcript.studId is not null)  (cost=0.13 rows=10) (actual time=0.005..0.049 rows=100 loops=1)
                -> Table scan on Transcript  (cost=0.13 rows=100) (actual time=0.005..0.044 rows=100 loops=1)
            -> Hash
                -> Filter: (course.deptId = <cache>((@v6)))  (cost=10.25 rows=10) (actual time=0.014..0.059 rows=26 loops=1)
                    -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.011..0.047 rows=100 loops=1)
    -> Filter: <in_optimizer>(transcript.studId,<exists>(select #3) is false)  (cost=0.06 rows=1) (actual time=0.108..0.109 rows=1 loops=30)
        -> Single-row index lookup on Student using PRIMARY (id=transcript.studId)  (cost=0.06 rows=1) (actual time=0.002..0.002 rows=1 loops=30)
        -> Select #3 (subquery in condition; dependent)
            -> Limit: 1 row(s)  (cost=110.52 rows=1) (actual time=0.105..0.105 rows=0 loops=30)
                -> Filter: <if>(outer_field_is_not_null, <is_not_null_test>(transcript.studId), true)  (cost=110.52 rows=100) (actual time=0.105..0.105 rows=0 loops=30)
                    -> Filter: (<if>(outer_field_is_not_null, ((<cache>(transcript.studId) = transcript.studId) or (transcript.studId is null)), true) and (transcript.crsCode = course.crsCode))  (cost=110.52 rows=100) (actual time=0.105..0.105 rows=0 loops=30)
                        -> Inner hash join (<hash>(transcript.crsCode)=<hash>(course.crsCode))  (cost=110.52 rows=100) (actual time=0.054..0.103 rows=34 loops=30)
                            -> Table scan on Transcript  (cost=0.13 rows=100) (actual time=0.001..0.038 rows=100 loops=30)
                            -> Hash
                                -> Filter: (course.deptId = <cache>((@v7)))  (cost=10.25 rows=10) (actual time=0.003..0.044 rows=32 loops=30)
                                    -> Table scan on Course  (cost=10.25 rows=100) (actual time=0.001..0.036 rows=100 loops=30)

*/