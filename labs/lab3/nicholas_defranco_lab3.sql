/*
Name: Nicholas Defranco
Student ID: 106732183
*/

SET SERVEROUTPUT ON;
SET VERIFY OFF;

------------------
-- Question 1
------------------

DECLARE    
    -- explicit cursors allow the programmer to have control over it
    -- It allows the programmer to handle queries with multiple 
    -- results one row at a time
    CURSOR c_descs IS
        SELECT description -- SELECT statement does not contain an INTO clause as the statement is not being executed here.
            FROM course
            WHERE prerequisite IS NULL
            ORDER BY description;
            
    v_course_desc     course.description%TYPE;
BEGIN
    OPEN c_descs; -- (1) identify the active set, size is # of rows that the query returned
    
    -- process the entire active set ...
    LOOP
        FETCH c_descs INTO v_course_desc; -- (2) obtains data stored in the current row being processed and stores it (destination specified by the INTO clause).
        EXIT WHEN c_descs%NOTFOUND; -- (3) true if the whole active set has been processed
        DBMS_OUTPUT.PUT_LINE('Course Description ' || c_descs%ROWCOUNT 
            || ': ' || v_course_desc);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('************************************');
    DBMS_OUTPUT.PUT_LINE('Total # of Courses without the Prerequisite is: ' 
        || c_descs%ROWCOUNT);
    CLOSE c_descs; -- (4) release the active set
END;
/
/*
Output:
Course Description 1: DP Overview
Course Description 2: Intro to Computers
Course Description 3: Java for C/C++ Programmers
Course Description 4: Operating Systems
************************************
Total # of Courses without the Prerequisite is: 4


PL/SQL procedure successfully completed.
*/

------------------
-- Question 2
------------------

DECLARE

    CURSOR c_descs IS
        SELECT description
            FROM course
            WHERE prerequisite IS NULL
            ORDER BY description;

    TYPE course_table_type IS TABLE OF
        course.description%TYPE
        INDEX BY PLS_INTEGER;
        
    course_tab      course_table_type;
BEGIN
    /*
    Cursor FOR loops implicitly OPEN, CLOSE, and FETCH into an implicitly
    declared record. The cursor FOR loop will also exit automatically 
    when all rows in the active set have been processed.
    */
    FOR r_descs IN c_descs LOOP
        course_tab(c_descs%ROWCOUNT) := r_descs.description;
        DBMS_OUTPUT.PUT_LINE('Course Description ' || c_descs%ROWCOUNT 
            || ': ' || course_tab(c_descs%ROWCOUNT));
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('************************************');
    DBMS_OUTPUT.PUT_LINE('Total # of Courses without the Prerequisite is: ' 
        || course_tab.count());
        
END;
/
/*
Output:
Course Description 1: DP Overview
Course Description 2: Intro to Computers
Course Description 3: Java for C/C++ Programmers
Course Description 4: Operating Systems
************************************
Total # of Courses without the Prerequisite is: 4


PL/SQL procedure successfully completed.
*/
------------------
-- Question 3
------------------

ACCEPT zip_code PROMPT 'Enter first 3 digits of a zip code: ';
DECLARE
    -- Cursors with parameter(s) allow the programmer to open the cursor 
    -- possibly with different parameters then previous opens, 
    -- which generates a unique active set based on the logic. 
    -- Alternative to using a bind variable.
    
    -- The formal paramter cannot accept a size as they are references
    -- to existing variables not variable declarations
    CURSOR c_zip(zip_code student.zip%TYPE) IS
        SELECT zip, count(student_id) AS amt
            FROM student
            WHERE zip LIKE (zip_code || '%')
            GROUP BY zip
            ORDER BY to_number(zip);
    
    -- %ROWTYPE attribute, takes the names and types from the columns 
    -- of (in this case) the zip_data cursor and creates a RECORD type
    -- convenient for processing
    rec_zip         c_zip%ROWTYPE;
    v_total_stud    PLS_INTEGER := 0;
BEGIN
    OPEN c_zip ('&zip_code'); -- (1)
    LOOP
        FETCH c_zip INTO rec_zip; -- (2)
        IF c_zip%NOTFOUND THEN
            IF c_zip%ROWCOUNT = 0 THEN
                -- This can only be possible if the active set was empty
                -- in the first place. That is, there are no students in the
                -- matched zip area
                DBMS_OUTPUT.PUT_LINE('This zip area is empty. Please, try again.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('************************************');
                DBMS_OUTPUT.PUT_LINE('Total # of zip codes under ' 
                    || lpad(&zip_code, 3, '0') || ' is ' || c_zip%ROWCOUNT);
        
                DBMS_OUTPUT.PUT_LINE('Total # of Students under zip code ' 
                    || lpad(&zip_code, 3, '0') || ' is ' || v_total_stud); 
            END IF;
            EXIT; -- (3)
        END IF;
        v_total_stud := v_total_stud + rec_zip.amt;
        DBMS_OUTPUT.PUT_LINE('Zip code: ' || rec_zip.zip || ' has exactly ' 
            || rec_zip.amt || ' students enrolled.');
    END LOOP;
    CLOSE c_zip; -- (4)
END;
/
/*
Output 1 (value inputted was 073):
Zip code: 07302 has exactly 1 students enrolled.
Zip code: 07304 has exactly 2 students enrolled.
Zip code: 07306 has exactly 4 students enrolled.
Zip code: 07307 has exactly 3 students enrolled.
************************************
Total # of zip codes under 073 is 4
Total # of Students under zip code 073 is 10


PL/SQL procedure successfully completed.

Output 2 (value inputted was 013):
This zip area is empty. Please, try again.


PL/SQL procedure successfully completed.
*/
------------------
-- Question 4
------------------

ACCEPT zip_code PROMPT 'Enter first 3 digits of a zip code: ';
DECLARE      
    
    CURSOR c_zip(zip_code student.zip%TYPE) IS
        SELECT zip, count(student_id) AS amt
            FROM student
            WHERE zip LIKE (zip_code || '%')
            GROUP BY zip
            ORDER BY to_number(zip);
            
    TYPE zip_tab_type IS TABLE OF
        PLS_INTEGER
        INDEX BY student.zip%TYPE;
        
    zip_tab         zip_tab_type;
    v_total_stud    PLS_INTEGER := 0;
BEGIN

    FOR rec_zip IN c_zip('&zip_code') LOOP
        zip_tab(rec_zip.zip) := rec_zip.amt;
        v_total_stud := v_total_stud + zip_tab(rec_zip.zip);
        DBMS_OUTPUT.PUT_LINE('Zip code: ' || rec_zip.zip 
            || ' has exactly ' || zip_tab(rec_zip.zip) 
            || ' students enrolled.');
    END LOOP;
    
    IF zip_tab.count() = 0 THEN
        DBMS_OUTPUT.PUT_LINE('This zip area is empty. Please, try again.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('************************************');
        DBMS_OUTPUT.PUT_LINE('Total # of zip codes under ' 
            || lpad(&zip_code, 3, '0') || ' is ' || zip_tab.count());
        
        DBMS_OUTPUT.PUT_LINE('Total # of Students under zip code ' 
            || lpad(&zip_code, 3, '0') || ' is ' || v_total_stud);
    END IF;
END;
/
/*
Output 1 (value inputted was 073):
Zip code: 07302 has exactly 1 students enrolled.
Zip code: 07304 has exactly 2 students enrolled.
Zip code: 07306 has exactly 4 students enrolled.
Zip code: 07307 has exactly 3 students enrolled.
************************************
Total # of zip codes under 073 is 4
Total # of Students under zip code 073 is 10


PL/SQL procedure successfully completed.

Output 2 (value inputted was 013):
This zip area is empty. Please, try again.


PL/SQL procedure successfully completed.
*/