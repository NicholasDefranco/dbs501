/*
Name: Nicholas Defranco
Student ID: 106732183
*/

SET SERVEROUTPUT ON;
SET VERIFY OFF;

/*
NOTE: sysdate = 20-06-25 when this was tested
*/

------------------
-- Question 1
------------------

CREATE OR REPLACE FUNCTION get_descr (
        p_sec_id    section.section_id%TYPE
    ) RETURN course.description%TYPE IS
    v_desc course.description%TYPE;
BEGIN

    SELECT description INTO v_desc
        FROM course
        WHERE course_no = (
        
            SELECT course_no
                FROM section
                WHERE section_id = p_sec_id
        
        );

    RETURN 'Course Description for Section Id ' || p_sec_id || ' is ' || v_desc;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'There is NO such Section id: ' || p_sec_id;
        
END get_descr;
/

VARIABLE course_desc CHAR;

EXECUTE :course_desc := get_descr(150);
PRINT course_desc;

EXECUTE :course_desc := get_descr(999);
PRINT course_desc;

/*
Output:
Case 1 (get_descr(150)): 

PL/SQL procedure successfully completed.


COURSE_DESC
--------------------------------------------------------------------------------
Course Description for Section Id 150 is Intro to Java Programming



Case 2 (get_descr(999)):

PL/SQL procedure successfully completed.


COURSE_DESC
--------------------------------------------------------------------------------
There is NO such Section id: 999
*/

------------------
-- Question 2
------------------

CREATE OR REPLACE PROCEDURE show_bizdays (
        p_start_date DATE := sysdate,
        p_num_days PLS_INTEGER := 21
    ) IS
    
    c_work_days CONSTANT PLS_INTEGER := 5;
    c_weekend_days CONSTANT PLS_INTEGER := 2;
    
    i PLS_INTEGER := 1;
    v_day_count PLS_INTEGER := 0;
    v_curr_date DATE := p_start_date;
    
    TYPE tab_date_type IS TABLE OF
        DATE
        INDEX BY PLS_INTEGER;
        
    date_tab tab_date_type;
BEGIN
    
    IF to_char(v_curr_date, 'fmDAY') IN ('SATURDAY', 'SUNDAY') THEN 
            v_curr_date := next_day(v_curr_date, 'MONDAY');
    END IF;
    
    v_day_count := next_day(v_curr_date, 'FRIDAY') - v_curr_date;
    
    WHILE i <= p_num_days LOOP
        date_tab(i) := v_curr_date;
        DBMS_OUTPUT.PUT_LINE('The index is : ' || i || ' and the table value is: ' || to_char(date_tab(i), 'dd-MON-yy'));
        IF v_day_count != 0 THEN
            v_day_count := v_day_count - 1;
        ELSE 
            v_day_count := c_work_days - 1;
            v_curr_date := v_curr_date + c_weekend_days;
        END IF;
        v_curr_date := v_curr_date + 1;
        i := i + 1;
    END LOOP;
    
END show_bizdays;
/

EXECUTE show_bizdays;

EXECUTE show_bizdays(sysdate + 7, 10);

/*
Output
Case 1 (show_bizdays):
The index is : 1 and the table value is: 25-JUN-20
The index is : 2 and the table value is: 26-JUN-20
The index is : 3 and the table value is: 29-JUN-20
The index is : 4 and the table value is: 30-JUN-20
The index is : 5 and the table value is: 01-JUL-20
The index is : 6 and the table value is: 02-JUL-20
The index is : 7 and the table value is: 03-JUL-20
The index is : 8 and the table value is: 06-JUL-20
The index is : 9 and the table value is: 07-JUL-20
The index is : 10 and the table value is: 08-JUL-20
The index is : 11 and the table value is: 09-JUL-20
The index is : 12 and the table value is: 10-JUL-20
The index is : 13 and the table value is: 13-JUL-20
The index is : 14 and the table value is: 14-JUL-20
The index is : 15 and the table value is: 15-JUL-20
The index is : 16 and the table value is: 16-JUL-20
The index is : 17 and the table value is: 17-JUL-20
The index is : 18 and the table value is: 20-JUL-20
The index is : 19 and the table value is: 21-JUL-20
The index is : 20 and the table value is: 22-JUL-20
The index is : 21 and the table value is: 23-JUL-20


PL/SQL procedure successfully completed.



Case 2 (show_bizdays(sysdate + 7, 10)):
The index is : 1 and the table value is: 02-JUL-20
The index is : 2 and the table value is: 03-JUL-20
The index is : 3 and the table value is: 06-JUL-20
The index is : 4 and the table value is: 07-JUL-20
The index is : 5 and the table value is: 08-JUL-20
The index is : 6 and the table value is: 09-JUL-20
The index is : 7 and the table value is: 10-JUL-20
The index is : 8 and the table value is: 13-JUL-20
The index is : 9 and the table value is: 14-JUL-20
The index is : 10 and the table value is: 15-JUL-20


PL/SQL procedure successfully completed.
*/

------------------
-- Question 3
------------------

CREATE OR REPLACE PACKAGE lab5 IS
    FUNCTION get_descr(p_sec_id section.section_id%TYPE) RETURN course.description%TYPE;
    PROCEDURE show_bizdays(p_start_date DATE := sysdate, p_num_days PLS_INTEGER := 21);
END lab5;
/

CREATE OR REPLACE PACKAGE BODY lab5 IS

    FUNCTION get_descr (
            p_sec_id    section.section_id%TYPE
        ) RETURN course.description%TYPE IS
        v_desc course.description%TYPE;
    BEGIN
    
        SELECT description INTO v_desc
            FROM course
            WHERE course_no = (
            
                SELECT course_no
                    FROM section
                    WHERE section_id = p_sec_id
            
            );
    
        RETURN 'Course Description for Section Id ' || p_sec_id || ' is ' || v_desc;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN 'There is NO such Section id: ' || p_sec_id;
            
    END get_descr;


    PROCEDURE show_bizdays (
            p_start_date DATE := sysdate,
            p_num_days PLS_INTEGER := 21
        ) IS
        
        c_work_days CONSTANT PLS_INTEGER := 5;
        c_weekend_days CONSTANT PLS_INTEGER := 2;
        
        i PLS_INTEGER := 1;
        v_day_count PLS_INTEGER := 0;
        v_curr_date DATE := p_start_date;
        
        TYPE tab_date_type IS TABLE OF
            DATE
            INDEX BY PLS_INTEGER;
            
        date_tab tab_date_type;
    BEGIN
        
        IF to_char(v_curr_date, 'fmDAY') IN ('SATURDAY', 'SUNDAY') THEN 
                v_curr_date := next_day(v_curr_date, 'MONDAY');
        END IF;
        
        v_day_count := next_day(v_curr_date, 'FRIDAY') - v_curr_date;
        
        WHILE i <= p_num_days LOOP
            date_tab(i) := v_curr_date;
            DBMS_OUTPUT.PUT_LINE('The index is : ' || i || ' and the table value is: ' || to_char(date_tab(i), 'dd-MON-yy'));
            IF v_day_count != 0 THEN
                v_day_count := v_day_count - 1;
            ELSE 
                v_day_count := c_work_days - 1;
                v_curr_date := v_curr_date + c_weekend_days;
            END IF;
            v_curr_date := v_curr_date + 1;
            i := i + 1;
        END LOOP;
        
    END show_bizdays;
        
END;
/


VARIABLE course_desc CHAR;

EXECUTE :course_desc := lab5.get_descr(150);
PRINT course_desc;

EXECUTE :course_desc := lab5.get_descr(999);
PRINT course_desc;


EXECUTE lab5.show_bizdays;

EXECUTE lab5.show_bizdays(sysdate + 7, 10);

/*
Output 1 Testing lab5.get_descr

Case 1 (lab5.get_descr(150)): 

PL/SQL procedure successfully completed.


COURSE_DESC
--------------------------------------------------------------------------------
Course Description for Section Id 150 is Intro to Java Programming



Case 2 (lab5.get_descr(999)):

PL/SQL procedure successfully completed.


COURSE_DESC
--------------------------------------------------------------------------------
There is NO such Section id: 999



Output 2 Testing lab5.show_bizdays
Case 1 (lab5.show_bizdays):
The index is : 1 and the table value is: 25-JUN-20
The index is : 2 and the table value is: 26-JUN-20
The index is : 3 and the table value is: 29-JUN-20
The index is : 4 and the table value is: 30-JUN-20
The index is : 5 and the table value is: 01-JUL-20
The index is : 6 and the table value is: 02-JUL-20
The index is : 7 and the table value is: 03-JUL-20
The index is : 8 and the table value is: 06-JUL-20
The index is : 9 and the table value is: 07-JUL-20
The index is : 10 and the table value is: 08-JUL-20
The index is : 11 and the table value is: 09-JUL-20
The index is : 12 and the table value is: 10-JUL-20
The index is : 13 and the table value is: 13-JUL-20
The index is : 14 and the table value is: 14-JUL-20
The index is : 15 and the table value is: 15-JUL-20
The index is : 16 and the table value is: 16-JUL-20
The index is : 17 and the table value is: 17-JUL-20
The index is : 18 and the table value is: 20-JUL-20
The index is : 19 and the table value is: 21-JUL-20
The index is : 20 and the table value is: 22-JUL-20
The index is : 21 and the table value is: 23-JUL-20


PL/SQL procedure successfully completed.



Case 2 (lab5.show_bizdays(sysdate + 7, 10)):
The index is : 1 and the table value is: 02-JUL-20
The index is : 2 and the table value is: 03-JUL-20
The index is : 3 and the table value is: 06-JUL-20
The index is : 4 and the table value is: 07-JUL-20
The index is : 5 and the table value is: 08-JUL-20
The index is : 6 and the table value is: 09-JUL-20
The index is : 7 and the table value is: 10-JUL-20
The index is : 8 and the table value is: 13-JUL-20
The index is : 9 and the table value is: 14-JUL-20
The index is : 10 and the table value is: 15-JUL-20


PL/SQL procedure successfully completed.
*/

------------------
-- Question 4
------------------

CREATE OR REPLACE PACKAGE lab5 IS
    FUNCTION get_descr(p_sec_id section.section_id%TYPE) RETURN course.description%TYPE;
    PROCEDURE show_bizdays(p_start_date DATE := sysdate, p_num_days PLS_INTEGER := 21);
    PROCEDURE show_bizdays(p_date_start DATE := sysdate);
END lab5;
/

CREATE OR REPLACE PACKAGE BODY lab5 IS

    FUNCTION get_descr (
            p_sec_id    section.section_id%TYPE
        ) RETURN course.description%TYPE IS
        v_desc course.description%TYPE;
    BEGIN
    
        SELECT description INTO v_desc
            FROM course
            WHERE course_no = (
            
                SELECT course_no
                    FROM section
                    WHERE section_id = p_sec_id
            
            );
    
        RETURN 'Course Description for Section Id ' || p_sec_id || ' is ' || v_desc;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN 'There is NO such Section id: ' || p_sec_id;
            
    END get_descr;


    PROCEDURE show_bizdays (
            p_start_date DATE := sysdate,
            p_num_days PLS_INTEGER := 21
        ) IS
        
        c_work_days CONSTANT PLS_INTEGER := 5;
        c_weekend_days CONSTANT PLS_INTEGER := 2;
        
        i PLS_INTEGER := 1;
        v_day_count PLS_INTEGER := 0;
        v_curr_date DATE := p_start_date;
        
        TYPE tab_date_type IS TABLE OF
            DATE
            INDEX BY PLS_INTEGER;
            
        date_tab tab_date_type;
    BEGIN
        
        IF to_char(v_curr_date, 'fmDAY') IN ('SATURDAY', 'SUNDAY') THEN 
                v_curr_date := next_day(v_curr_date, 'MONDAY');
        END IF;
        
        v_day_count := next_day(v_curr_date, 'FRIDAY') - v_curr_date;
        
        WHILE i <= p_num_days LOOP
            date_tab(i) := v_curr_date;
            DBMS_OUTPUT.PUT_LINE('The index is : ' || i || ' and the table value is: ' || to_char(date_tab(i), 'dd-MON-yy'));
            IF v_day_count != 0 THEN
                v_day_count := v_day_count - 1;
            ELSE 
                v_day_count := c_work_days - 1;
                v_curr_date := v_curr_date + c_weekend_days;
            END IF;
            v_curr_date := v_curr_date + 1;
            i := i + 1;
        END LOOP;
        
    END show_bizdays;
    
    
    PROCEDURE show_bizdays (
        p_date_start DATE := sysdate
    ) IS
    
        c_work_days CONSTANT PLS_INTEGER := 5;
        c_weekend_days CONSTANT PLS_INTEGER := 2;
        
        i PLS_INTEGER := 1;
        v_day_count PLS_INTEGER := 0;
        v_curr_date DATE := p_date_start;
        
        TYPE tab_date_type IS TABLE OF
            DATE
            INDEX BY PLS_INTEGER;
            
        date_tab tab_date_type;
    BEGIN
        
        IF to_char(v_curr_date, 'fmDAY') IN ('SATURDAY', 'SUNDAY') THEN 
                v_curr_date := next_day(v_curr_date, 'MONDAY');
        END IF;
        
        v_day_count := next_day(v_curr_date, 'FRIDAY') - v_curr_date;
        
        WHILE i <= &num_days LOOP
            date_tab(i) := v_curr_date;
            DBMS_OUTPUT.PUT_LINE('The index is : ' || i || ' and the table value is: ' || to_char(date_tab(i), 'dd-MON-yy'));
            IF v_day_count != 0 THEN
                v_day_count := v_day_count - 1;
            ELSE 
                v_day_count := c_work_days - 1;
                v_curr_date := v_curr_date + c_weekend_days;
            END IF;
            v_curr_date := v_curr_date + 1;
            i := i + 1;
        END LOOP;
        
    END show_bizdays;
    
END;
/


VARIABLE course_desc CHAR;

EXECUTE :course_desc := lab5.get_descr(150);
PRINT course_desc;

EXECUTE :course_desc := lab5.get_descr(999);
PRINT course_desc;


/*
EXECUTE lab5.show_bizdays; -- or
EXECUTE lab5.show_bizdays(sysdate);

... calls can no longer be done since the first 
parameter for both procedures are dates (and has
a default value) and the second parameter for the 
first procedure has a default value

*/

-- named notation can be used to resolve possible
-- ambiguities as the parameters have have different
-- identifiers
EXECUTE lab5.show_bizdays(p_start_date => sysdate);

EXECUTE lab5.show_bizdays(sysdate + 7, 10);


-- calling the overloaded show_bizdays procedure
EXECUTE lab5.show_bizdays(p_date_start => sysdate);


/*
Output 1 Testing lab5.get_descr

Case 1 (lab5.get_descr(150)): 

PL/SQL procedure successfully completed.


COURSE_DESC
--------------------------------------------------------------------------------
Course Description for Section Id 150 is Intro to Java Programming



Case 2 (lab5.get_descr(999)):

PL/SQL procedure successfully completed.


COURSE_DESC
--------------------------------------------------------------------------------
There is NO such Section id: 999



Output 2 Testing lab5.show_bizdays
Case 1 (lab5.show_bizdays(p_start_date => sysdate)):
The index is : 1 and the table value is: 25-JUN-20
The index is : 2 and the table value is: 26-JUN-20
The index is : 3 and the table value is: 29-JUN-20
The index is : 4 and the table value is: 30-JUN-20
The index is : 5 and the table value is: 01-JUL-20
The index is : 6 and the table value is: 02-JUL-20
The index is : 7 and the table value is: 03-JUL-20
The index is : 8 and the table value is: 06-JUL-20
The index is : 9 and the table value is: 07-JUL-20
The index is : 10 and the table value is: 08-JUL-20
The index is : 11 and the table value is: 09-JUL-20
The index is : 12 and the table value is: 10-JUL-20
The index is : 13 and the table value is: 13-JUL-20
The index is : 14 and the table value is: 14-JUL-20
The index is : 15 and the table value is: 15-JUL-20
The index is : 16 and the table value is: 16-JUL-20
The index is : 17 and the table value is: 17-JUL-20
The index is : 18 and the table value is: 20-JUL-20
The index is : 19 and the table value is: 21-JUL-20
The index is : 20 and the table value is: 22-JUL-20
The index is : 21 and the table value is: 23-JUL-20


PL/SQL procedure successfully completed.



Case 2 (lab5.show_bizdays(sysdate + 7, 10)):
The index is : 1 and the table value is: 02-JUL-20
The index is : 2 and the table value is: 03-JUL-20
The index is : 3 and the table value is: 06-JUL-20
The index is : 4 and the table value is: 07-JUL-20
The index is : 5 and the table value is: 08-JUL-20
The index is : 6 and the table value is: 09-JUL-20
The index is : 7 and the table value is: 10-JUL-20
The index is : 8 and the table value is: 13-JUL-20
The index is : 9 and the table value is: 14-JUL-20
The index is : 10 and the table value is: 15-JUL-20


PL/SQL procedure successfully completed.


Case 3 (lab5.show_bizdays(p_date_start => sysdate)) (NOTE: 15 was inputted for the substitution variable num_days upon compiling q4's lab5 package body):
The index is : 1 and the table value is: 25-JUN-20
The index is : 2 and the table value is: 26-JUN-20
The index is : 3 and the table value is: 29-JUN-20
The index is : 4 and the table value is: 30-JUN-20
The index is : 5 and the table value is: 01-JUL-20
The index is : 6 and the table value is: 02-JUL-20
The index is : 7 and the table value is: 03-JUL-20
The index is : 8 and the table value is: 06-JUL-20
The index is : 9 and the table value is: 07-JUL-20
The index is : 10 and the table value is: 08-JUL-20
The index is : 11 and the table value is: 09-JUL-20
The index is : 12 and the table value is: 10-JUL-20
The index is : 13 and the table value is: 13-JUL-20
The index is : 14 and the table value is: 14-JUL-20
The index is : 15 and the table value is: 15-JUL-20


PL/SQL procedure successfully completed.
*/
