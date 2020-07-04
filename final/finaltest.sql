-- Question 1
-- NOTE: There were errors in the version we recieved on the test. This version has all the corrected changes.
CREATE OR REPLACE PACKAGE com_pack IS
    FUNCTION validate_com(p_com IN employees.commission_pct%type) RETURN  BOOLEAN;
    PROCEDURE modify_com(p_com IN employees.commission_pct%type);
END;
/

CREATE OR REPLACE PACKAGE BODY com_pack  IS
    FUNCTION validate_com (p_com IN employees.commission_pct%type) RETURN BOOLEAN IS
        v_min employees.commission_pct%type;
        v_max employees.commission_pct%type;
    BEGIN    
        SELECT MIN(commission_pct), MAX(commission_pct)
            INTO v_min, v_max
            FROM employees;
    
        IF  p_com < v_min THEN
            RETURN FALSE;
        ELSIF p_com > v_max THEN
            RETURN NULL;
        ELSE
            RETURN TRUE;
        END IF;
    
    END validate_com;
    
    PROCEDURE modify_com(p_com IN employees.commission_pct%type) IS 
    BEGIN
        IF validate_com(p_com) THEN
            DBMS_OUTPUT.PUT_LINE('Good Commission input.');
        ELSIF validate_com(p_com) = NULL THEN -- Note the = NULL comparision, that's the trick of the question.
            DBMS_OUTPUT.PUT_LINE('Invalid Commission input.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Commission must be higher than entered.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('There is NO data.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Some error has happened');
    END modify_com;
END com_pack;
/



/*
If distinct values of commission_pct column in a table Employees are:

MIN
 |
\_/

0.1   0.15   0.2   0.25   0.3   0.35   0.4  
                                        _
                                       / \
                                        |
                                       MAX
then provide the test statement and test result when parameter values are:
*/

-- a) 0

EXECUTE com_pack.modify_com(0);

-- Output: 
-- Commission must be higher than entered.


-- b) 0.12 

EXECUTE com_pack.modify_com(0.12);

-- Output:
-- Good Commission input.

-- c) 0.5

EXECUTE com_pack.modify_com(0.5);

-- Output:
-- Commission must be higher than entered.



/*
Question 2:
Create a stored function called get_sec_num to retrieve the total number of sections that are enrolled by 
students coming from a provided string (which means the beginning of the city name). The function should accept one parameter to hold that string.
Use Cursor For Loop, and do not try to resolve this problem by having a multiple row Subquery with joins in both main query and subquery,
Finally test your function by using DBMS_OUTPUT package for cities that start on Mon  and the output will be:

Number of sections is 6
*/

SET SERVEROUTPUT ON;
SET VERIFY OFF;

CREATE OR REPLACE FUNCTION get_sec_num (
        p_city zipcode.city%TYPE
    ) RETURN NUMBER IS   
           
    CURSOR cur_stud_zip IS
        SELECT student_id
            FROM zipcode JOIN student USING(zip)
            WHERE upper(city) LIKE upper(p_city) || '%';
         
    v_count NUMBER;
    v_tot   NUMBER := 0;
BEGIN
    FOR rec_stud IN cur_stud_zip LOOP
        SELECT count(section_id) INTO v_count
            FROM enrollment
            WHERE student_id = rec_stud.student_id;
        v_tot := v_tot + v_count;
    END LOOP;
    RETURN v_tot;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('Number of sections is ' || get_sec_num('Mon'));   
END;
/


/*
Question 3:
Write a Row Trigger called Remove_Emp_Trig that will prevent (disallow) employee removal from table EMPLOYEES during
weekday business hours (from 8am to 5pm), but only if  the person to be removed is Sales Representative or Sales Manager (job_id begins on SA).

Be careful when performing date/time conversion.

Then perform the testing situation for this trigger by providing the SQL statement and date/time of its execution attempt 
(trigger should fire). 

*/

CREATE OR REPLACE TRIGGER remove_emp_trig
BEFORE DELETE ON employees
FOR EACH ROW
WHEN (OLD.job_id = 'SA_MAN' OR OLD.job_id = 'SA_REP')
BEGIN
    DBMS_OUTPUT.PUT_LINE('Deleting an SA_MAN or SA_REP...');
    DBMS_OUTPUT.PUT_LINE('Time is: ' || to_char(sysdate, 'DY HH24:MI'));
    
    IF (to_char(sysdate, 'DY') IN ('SAT', 'SUN')) OR 
        (to_char(sysdate, 'HH24:MI')) NOT BETWEEN '08:00' AND '17:00' THEN
        
        RAISE_APPLICATION_ERROR(-20101, 'You may only remove an employee from the employees table during business hours.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('During business hours, proceding to delete statment...');
    END IF;
END;
/

-- sysdate = Friday, 10:50AM

DELETE FROM employees
    WHERE employee_id = 202; -- has a job_id of 'MK_REP, thus, trigger body will not execute

DELETE FROM employees
    WHERE employee_id = 153; -- has a job_id of 'SA_REP'. trigger body will execute
    
DELETE FROM employees
    WHERE employee_id = 145; -- has a job_id of 'SA_MAN'. trigger body will execute. Note, there will be an integrity constrint error.
    
ROLLBACK;
