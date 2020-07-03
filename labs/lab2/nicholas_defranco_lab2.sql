/*
Name: Nicholas Defranco
Student ID: 106732183
*/

SET VERIFY OFF;
SET SERVEROUTPUT ON;

--------------------
-- Question 1
--------------------

ACCEPT iscale PROMPT 'Enter your input scale (C or F) for temperature: ';
ACCEPT temperature PROMPT 'Enter your temperature value to be converted: ';
DECLARE
    v_scale     CHAR := upper('&iscale');
    v_temp      BINARY_DOUBLE := &temperature;
BEGIN
    IF v_scale = 'F' THEN
        DBMS_OUTPUT.PUT_LINE('Your converted temparature in C is exactly: ' || 
            round((v_temp - 32) * (5 / 9), 1));
    ELSIF v_scale = 'C' THEN
        DBMS_OUTPUT.PUT_LINE('Your converted temparature in F is exactly: ' || 
            round(((v_temp * (9 / 5)) + 32), 1));
    ELSE
        DBMS_OUTPUT.PUT_LINE('This is NOT a valid scale. Must be C or F.');    
    END IF;
END;
/

/*
Output:

Output 1 (input scale is A and temperature to be converted is 30):

This is NOT a valid scale. Must be C or F.


PL/SQL procedure successfully completed.



Output 2 (input scale is C and temperature to be converted is 30):

Your converted temparature in F is exactly: 86


PL/SQL procedure successfully completed.



Output 3 (input scale is F and temperature to be converted is -25):

Your converted temparature in C is exactly: -31.7


PL/SQL procedure successfully completed.
*/


--------------------
-- Question 2
--------------------

ACCEPT instructor PROMPT 'Please enter the Instructor Id: ';
DECLARE
    v_id                instructor.instructor_id%TYPE := &instructor;
    
    TYPE instructor_rec IS RECORD (
    
        v_first         instructor.first_name%TYPE,
        v_last          instructor.last_name%TYPE,
        v_amt_taught    PLS_INTEGER := 0
        
    );
    v_instructor_info instructor_rec;
    
BEGIN
        
    SELECT first_name, last_name
        INTO v_instructor_info.v_first, 
            v_instructor_info.v_last
        FROM instructor
        WHERE instructor_id = v_id;
        
    SELECT count(section_id)
        INTO v_instructor_info.v_amt_taught
        FROM section
        WHERE instructor_id = v_id;

    /*
    Another possible query that I came up with to collect the 
    same information as the two queries above collect.
    
    SELECT first_name, last_name, NVL(sections, 0)
        INTO v_instructor_info
        FROM instructor LEFT JOIN (
                        SELECT instructor_id, count(section_id) AS sections
                            FROM section 
                            WHERE instructor_id = v_id 
                            GROUP BY instructor_id
                    ) USING(instructor_id)
        WHERE instructor_id = v_id;
    */

    DBMS_OUTPUT.PUT_LINE('Instructor, ' || v_instructor_info.v_first || ' ' || 
        v_instructor_info.v_last || ', teaches ' || v_instructor_info.v_amt_taught || 
        ' section(s)');
        
    DBMS_OUTPUT.PUT('This instructor ');
    
    CASE
        WHEN v_instructor_info.v_amt_taught > 9 THEN
            DBMS_OUTPUT.PUT_LINE('needs to rest in the next term.');
        WHEN v_instructor_info.v_amt_taught > 4 THEN
            DBMS_OUTPUT.PUT_LINE('teaches enough sections.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('may teach more sections.');
    END CASE;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('This is not a valid instructor');
END;
/

/*
Output

Output 1 (instructor id is 999):

This is not a valid instructor


PL/SQL procedure successfully completed.



Output 2 (instructor id is 102):

Instructor, Tom Wojick, teaches 10 section(s)
This instructor needs to rest in the next term.


PL/SQL procedure successfully completed.



Output 3 (instructor id is 101):

Instructor, Fernand Hanks, teaches 9 section(s)
This instructor teaches enough sections.


PL/SQL procedure successfully completed.



Output 4 (instructor id is 109):

Instructor, Rick Chow, teaches 0 section(s)
This instructor may teach more sections.


PL/SQL procedure successfully completed.
*/

--------------------
-- Question 3
--------------------

ACCEPT ivalue PROMPT 'Please enter a Positive Integer';
DECLARE
    v_num               PLS_INTEGER := &ivalue;
    v_amt               PLS_INTEGER := 0;
    i                   PLS_INTEGER := v_num MOD 2;
    e_invalid_value     EXCEPTION;
BEGIN
    IF v_num <= 0 THEN
        RAISE e_invalid_value;
    END IF;

    DBMS_OUTPUT.PUT('The sum of ');
    
    IF i = 0 THEN
        DBMS_OUTPUT.PUT('Even');
        i := i + 2; -- no purpose in entering the while loop with the value of 0
    ELSE
        DBMS_OUTPUT.PUT('Odd');
    END IF;
    
    WHILE i <= v_num LOOP
        v_amt := v_amt + i;
        i := i + 2;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(' integers between 1 and ' || v_num || 
        ' is ' || v_amt);
    
    EXCEPTION
        WHEN e_invalid_value THEN
            DBMS_OUTPUT.PUT_LINE('Invalid integer input, only positive values are accepted');
    
END;
/

/*
Output:

Output 1 (positive integer is 12):

The sum of Even integers between 1 and 12 is 42


PL/SQL procedure successfully completed.



Output 2 (positive integer is 901):

The sum of Odd integers between 1 and 901 is 203401


PL/SQL procedure successfully completed.
*/

--------------------
-- Question 4
--------------------


-- Note: This PL/SQL block will output nothing if the 
-- location id is invalid

ACCEPT location_id PROMPT 'Enter valid Location Id: ';
DECLARE
    v_loc_id      locations.location_id%TYPE := &location_id;
    v_amt_dept    PLS_INTEGER := 0;
    v_amt_emp     PLS_INTEGER := 0;
BEGIN

    UPDATE departments
        SET location_id = 1400
        WHERE department_id IN (40, 70);
        
    -- used to verify that 2 rows have been updated
    -- DBMS_OUTPUT.PUT_LINE('Updated ' || SQL%ROWCOUNT || ' rows');
    
    -- Amount of departments.
    SELECT count(department_id)
        INTO v_amt_dept
        FROM departments
        WHERE location_id = v_loc_id;
    
    -- Total number of employees that work in the departments 
    -- that share the same location.
    SELECT count(employee_id)
            INTO v_amt_emp
            FROM employees
            WHERE department_id IN (
            
                SELECT department_id
                    FROM departments
                    WHERE location_id = v_loc_id
            
            );
    
    FOR i IN 1..v_amt_dept LOOP
        DBMS_OUTPUT.PUT_LINE('Outer Loop: Department #' || i);
        FOR j IN 1..v_amt_emp LOOP
            DBMS_OUTPUT.PUT_LINE('Inner Loop: Employee #' || j);        
        END LOOP;
    END LOOP;
    
END;
/

ROLLBACK;

/*
Output:

Output 1 (location id is 1800):

Outer Loop: Department #1
Inner Loop: Employee #1
Inner Loop: Employee #2


PL/SQL procedure successfully completed.


Rollback complete.



Output 2 (location id is 1400):

Outer Loop: Department #1
Inner Loop: Employee #1
Inner Loop: Employee #2
Inner Loop: Employee #3
Inner Loop: Employee #4
Inner Loop: Employee #5
Inner Loop: Employee #6
Inner Loop: Employee #7
Outer Loop: Department #2
Inner Loop: Employee #1
Inner Loop: Employee #2
Inner Loop: Employee #3
Inner Loop: Employee #4
Inner Loop: Employee #5
Inner Loop: Employee #6
Inner Loop: Employee #7
Outer Loop: Department #3
Inner Loop: Employee #1
Inner Loop: Employee #2
Inner Loop: Employee #3
Inner Loop: Employee #4
Inner Loop: Employee #5
Inner Loop: Employee #6
Inner Loop: Employee #7


PL/SQL procedure successfully completed.


Rollback complete.
*/
