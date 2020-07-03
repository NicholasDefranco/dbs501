/*
Name: Nicholas Defranco
Student ID: 106732183
*/


/*
Question #1:

Output

Local V_MINE is here: 700
Outer V_MINE is here: 500
Outer V_MINE is here: 1400

*/

-- This code was taken exactly from the instruction sheet
SET   SERVEROUTPUT ON
<<big>>
DECLARE
      v_mine  NUMBER(4) := 500;
BEGIN
  	<<small>>
  	DECLARE
      		v_mine  NUMBER(3) := 700;
  	BEGIN
      		dbms_output.put_line('Local V_MINE is here: ' || v_mine);
     		dbms_output.put_line('Outer V_MINE is here: ' || big.v_mine);     
      		big.v_mine := v_mine * 2;
  	END;
      dbms_output.put_line('Outer V_MINE is here: ' || v_mine);
END;
/

----------------
-- Question #2:
----------------

DECLARE
    v_str       VARCHAR2(32) := 'Introduction to Oracle Database';
    /*
    Note about v_num
    if 123456.789 is assigned to v_num, the value stored
    will be 123456.79. It will round to the nearest hundreth.
    Thus, it cannot properly be stored.
    
    if 1023456.78 is assigned to v_num, I'll recieve the error:
    "PL/SQL: numeric or value error: number precision too large"
    */
    v_num       NUMBER(8, 2) := 123456.78;
    v_const     CONSTANT CHAR(4) := '704B';
    v_bool      BOOLEAN;
    --v_date      DATE := sysdate + 7; This will store the exact execution time of sysdate; Not what is required.
    v_date      TIMESTAMP(0) := TO_TIMESTAMP(sysdate, 'yy-mm-dd')
            + INTERVAL '7' DAY;
BEGIN
    DBMS_OUTPUT.PUT_LINE('VARCHAR2 variable value: ' || v_str);
    DBMS_OUTPUT.PUT_LINE('NUMBER variable value: ' || v_num);
    DBMS_OUTPUT.PUT_LINE('CONSTANT variable value: ' || v_const);
    
    -- Note: hours of the day are not stored
    -- The hours, minutes, and seconds will always be displayed as 0
    DBMS_OUTPUT.PUT_LINE('DATE variable value: ' || v_date);
    
    -- Part D
    v_str := 'C++ advanced';
    
    -- All string comparisions are case-insensitive
    IF upper(v_str) LIKE '%SQL%' THEN
        DBMS_OUTPUT.PUT_LINE('The name of the course is: ' || v_str);
    ELSIF upper(v_const) LIKE '%704B%' THEN
        IF v_str IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('The name of the course is: ' || v_str);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Course is unknown');
        END IF;
        DBMS_OUTPUT.PUT_LINE('Room name is: ' || v_const);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Course and location could not be determined');
    END IF;
    
END;
/

/*

Output

NOTE: The DATE variable value will vary based on the time
it was executed.

WITHOUT assigning the 'C++ advanced' string literal:

VARCHAR2 variable value: Introduction to Oracle Database
NUMBER variable value: 123456.78
CONSTANT variable value: 704B
DATE variable value: 20-05-30 00:00:00
The name of the course is: Introduction to Oracle Database
Room name is: 704B


WITH assigning the 'C++ advanced' string literal:

VARCHAR2 variable value: Introduction to Oracle Database
NUMBER variable value: 123456.78
CONSTANT variable value: 704B
DATE variable value: 20-05-30 00:00:00
The name of the course is: C++ advanced
Room name is: 704B

*/


----------------
-- Question #3
----------------

/*
Used for testing
DROP TABLE Lab1_tab;
DROP SEQUENCE Lab1_seq;
*/

CREATE TABLE lab1_tab (
    
    id      NUMBER(8),
    lname   VARCHAR2(20)
    
);

CREATE SEQUENCE lab1_seq
    INCREMENT BY 5
    START WITH 1;
    


<<outer>>
DECLARE
    v_id        lab1_tab.id%type;
    v_lname     lab1_tab.lname%type;
BEGIN

    <<most_enrolls>>
    DECLARE 
        v_max_no    NUMBER(4);  
    BEGIN
        SELECT max(count(section_id)) INTO v_max_no
            FROM enrollment
            GROUP BY student_id;

        SELECT last_name INTO outer.v_lname
        FROM student
        WHERE length(last_name) < 9
            AND student_id IN (
            
                SELECT student_id
                    FROM enrollment
                    GROUP BY student_id
                    HAVING count(section_id) = v_max_no
                    
        );
        
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            outer.v_lname := 'Multiple Names';
    
    END;  

    INSERT INTO lab1_tab 
        VALUES(lab1_seq.NEXTVAL, v_lname);
    
    <<min_enrolls>>
    DECLARE
        v_min_no    NUMBER(4);
        
    BEGIN
        SELECT min(count(section_id)) INTO v_min_no
            FROM enrollment
            GROUP BY student_id;
        
        SELECT last_name INTO outer.v_lname
        FROM student
        WHERE length(last_name) < 9
            AND student_id IN (
            
                SELECT student_id
                    FROM enrollment
                    GROUP BY student_id
                    HAVING count(section_id) = v_min_no
                    
        );   
            
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            outer.v_lname := 'Multiple Names';
    END;
    
    INSERT INTO lab1_tab 
        VALUES(lab1_seq.NEXTVAL, v_lname);
    
    <<least_taught>>
    DECLARE 
        v_min_no    NUMBER(4);
    BEGIN
        SELECT min(count(section_id)) INTO v_min_no
            FROM section
            GROUP BY instructor_id;
        
        SELECT last_name INTO outer.v_lname
            FROM instructor
            WHERE upper(last_name) NOT LIKE '%S'
                AND instructor_id IN (
                
                    SELECT instructor_id
                        FROM section
                        GROUP BY instructor_id
                        HAVING count(section_id) = v_min_no
                        
            );
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            outer.v_lname := 'Multiple Names';
    END;
    
    INSERT INTO lab1_tab 
        VALUES(v_id, v_lname);
    
    <<most_taught>>
    DECLARE
        v_max_no    NUMBER(4);
    BEGIN
        SELECT max(count(section_id)) INTO v_max_no
            FROM section
            GROUP BY instructor_id;
        
        SELECT last_name INTO outer.v_lname
            FROM instructor
            WHERE upper(last_name) NOT LIKE '%S'
                AND instructor_id IN (
                
                    SELECT instructor_id
                        FROM section
                        GROUP BY instructor_id
                        HAVING count(section_id) = v_max_no
                        
            );
            
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            outer.v_lname := 'Multiple Names';
    END;
    
    INSERT INTO lab1_tab 
        VALUES(lab1_seq.NEXTVAL, v_lname);
    
END;
/

-- verifying insertions
SELECT * FROM lab1_tab;

-- Saving changes by ending the transaction
COMMIT;

/*

Output - After running all of question 3 as a script
This is the query returned after the SELECT statement
is executed

ID      LName
     1  Williams
     6  Multiple Names
(null)  Lowry
    11  Multiple Names

*/
