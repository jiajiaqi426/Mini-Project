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

-- 4. List the names of students who have taken a course taught by professor v5 (name).
-- CTE is easier to read and has less redundancy, use a CTE for readability and performance.
/*EXPLAIN ANALYZE
SELECT name FROM Student,
	(SELECT studId FROM Transcript,
		(SELECT crsCode, semester FROM Professor
			JOIN Teaching
			WHERE Professor.name = @v5 AND Professor.id = Teaching.profId) as alias1
	WHERE Transcript.crsCode = alias1.crsCode AND Transcript.semester = alias1.semester) as alias2
WHERE Student.id = alias2.studId;*/

EXPLAIN ANALYZE
WITH cte1 AS (
SELECT studId FROM Transcript
WHERE crsCode IN 
			(SELECT crsCode FROM Professor
					JOIN Teaching
                    WHERE Professor.name = @v5 AND Professor.id = Teaching.profId)
			)
SELECT name FROM Student
JOIN cte1 ON cte1.studId = Student.id;