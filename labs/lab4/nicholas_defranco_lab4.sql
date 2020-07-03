/*
Name: Nicholas Defranco
Student ID: 106732183
*/

SET VERIFY OFF;
SET SERVEROUTPUT ON;

----------------
-- Question 1
----------------

CREATE OR REPLACE PROCEDURE mine (
        p_expiry    CHAR,
        p_obj_type  CHAR
    ) IS
    v_num_type      PLS_INTEGER;
    v_type          VARCHAR2(16);
    e_invalid_type  EXCEPTION;
    e_invalid_date  EXCEPTION;
    PRAGMA          EXCEPTION_INIT(e_invalid_date, -01843);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Last day of the month ' || p_expiry 
        || ' is ' || to_char(last_day(to_date(p_expiry, 'MM/YY')), 'Day'));
    
    v_type := upper(p_obj_type);
    
    IF v_type = 'P' THEN
        v_type := 'PROCEDURE';
    ELSIF v_type = 'F' THEN
        v_type := 'FUNCTION';
    ELSIF v_type = 'B' THEN
        v_type := 'PACKAGE BODY';
    ELSE
        RAISE e_invalid_type;
    END IF;
    
    SELECT count(*) INTO v_num_type
        FROM user_objects
        WHERE upper(object_type) = v_type;
    
    DBMS_OUTPUT.PUT_LINE('Number of stored objects of type ' || upper(p_obj_type) || ' is ' || v_num_type);

    EXCEPTION
        WHEN e_invalid_type THEN
            DBMS_OUTPUT.PUT_LINE('You have entered an Invalid letter for the stored object. Try P, F or B.');
        WHEN e_invalid_date THEN
            DBMS_OUTPUT.PUT_LINE('You have entered an Invalid FORMAT for the MONTH and YEAR. Try MM/YY.');
END;
/

EXECUTE mine(p_expiry => '11/09', p_obj_type => 'P');
EXECUTE mine(p_expiry => '12/09', p_obj_type => 'f');
EXECUTE mine(p_expiry => '01/10', p_obj_type => 'T');
EXECUTE mine(p_expiry => '13/09', p_obj_type => 'P');

/*
Output
Case 1 (EXECUTE mine(p_expiry => '11/09', p_obj_type => 'P');):

Last day of the month 11/09 is Monday   
Number of stored objects of type P is 12


PL/SQL procedure successfully completed.



Case 2 (EXECUTE mine(p_expiry => '12/09', p_obj_type => 'f');):

Last day of the month 12/09 is Thursday 
Number of stored objects of type F is 3


PL/SQL procedure successfully completed.



Case 3 (EXECUTE mine(p_expiry => '01/10', p_obj_type => 'T');):



Last day of the month 01/10 is Sunday   
You have entered an Invalid letter for the stored object. Try P, F or B.


PL/SQL procedure successfully completed.



Case 4 (EXECUTE mine(p_expiry => '13/09', p_obj_type => 'P');):

You have entered an Invalid FORMAT for the MONTH and YEAR. Try MM/YY.


PL/SQL procedure successfully completed.
*/

----------------
-- Question 2
----------------

CREATE OR REPLACE PROCEDURE add_zip (
        p_zip       zipcode.zip%TYPE,
        p_city      zipcode.city%TYPE,
        p_state     zipcode.state%TYPE,
        p_status    OUT NOCOPY CHAR,
        p_num       OUT NOCOPY NUMBER
    ) IS
BEGIN
    BEGIN
        SELECT 'FAILURE' INTO p_status
            FROM zipcode
            WHERE zip = p_zip;
            
        DBMS_OUTPUT.PUT_LINE('This ZIPCODE ' || p_zip || ' is already in the Database. Try again. ');
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_status := 'SUCCESS';
                INSERT INTO zipcode
                    VALUES(p_zip, initcap(p_city), upper(p_state), user, sysdate, user, sysdate);
    END;
    
    SELECT count(*) INTO p_num
        FROM zipcode
        WHERE upper(state) = upper(p_state);
        
END;
/

ACCEPT s_zip PROMPT 'Enter a zip code: ';
ACCEPT s_city PROMPT 'Enter a city: ';
ACCEPT s_state PROMPT 'Enter a state: ';

VARIABLE b_num NUMBER;
VARIABLE b_flag CHAR(7);

-- && -> used to ensure that the user is only prompted once for s_state
-- and not twice (as it appears twice in this tester script).
EXECUTE add_zip('&s_zip', '&s_city', '&&s_state', :b_flag, :b_num);

PRINT b_flag;
PRINT b_num;

SELECT *
    FROM zipcode
    WHERE upper(state) = upper('&s_state');

-- Only ROLLBACK on success...
EXECUTE IF :b_flag = 'SUCCESS' THEN ROLLBACK; END IF;

/*
Output:
Case 1:
Enter a zip code: 18104
Enter a city: Chicago
Enter a state: MI

PL/SQL procedure successfully completed.


B_FLAG
--------------------------------------------------------------------------------
SUCCESS


     B_NUM
----------
         2
         
ZIP     CITY        STATE   CREATED_BY      CREATED_DATE    MODIFIED_BY     MODIFIED_DATE
48104	Ann Arbor	MI	    AMORRISO	    99-08-03	    ARISCHER	    99-11-24
18104	Chicago	    MI	    DBS501_202A06	20-06-17	    DBS501_202A06	20-06-17

PL/SQL procedure successfully completed.

Case 2:
Enter a zip code: 48104
Enter a city: Chicago
Enter a state: MI

This ZIPCODE 48104 is already in the Database. Try again. 


PL/SQL procedure successfully completed.


B_FLAG
--------------------------------------------------------------------------------
FAILURE


     B_NUM
----------
         1

ZIP     CITY        STATE   CREATED_BY      CREATED_DATE    MODIFIED_BY     MODIFIED_DATE
48104	Ann Arbor	MI	    AMORRISO	    99-08-03	    ARISCHER	    99-11-24

PL/SQL procedure successfully completed.
*/

----------------
-- Question 3
----------------

CREATE OR REPLACE FUNCTION exist_zip (
        p_zip   zipcode.zip%TYPE
    ) RETURN BOOLEAN IS
    v_flag      PLS_INTEGER;
BEGIN
    BEGIN
        SELECT 1 INTO v_flag
            FROM zipcode
            WHERE zip = p_zip;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_flag := 0;
    END;
    
    RETURN v_flag = 1;
        
END;
/

CREATE OR REPLACE PROCEDURE add_zip2 (
        p_zip       zipcode.zip%TYPE,
        p_city      zipcode.city%TYPE,
        p_state     zipcode.state%TYPE,
        p_status    OUT NOCOPY CHAR,
        p_num       OUT NOCOPY NUMBER
    ) IS
BEGIN
    
    IF exist_zip(p_zip => p_zip) THEN
        DBMS_OUTPUT.PUT_LINE('This ZIPCODE ' || p_zip || ' is already in the Database. Try again. ');
        p_status := 'FAILURE';
    ELSE
        INSERT INTO zipcode
            VALUES(p_zip, initcap(p_city), upper(p_state), user, sysdate, user, sysdate);
        p_status := 'SUCCESS';
    END IF;
    
    SELECT count(*) INTO p_num
        FROM zipcode
        WHERE upper(state) = upper(p_state);
END;
/

ACCEPT s_zip PROMPT 'Enter a zip code: ';
ACCEPT s_city PROMPT 'Enter a city: ';
ACCEPT s_state PROMPT 'Enter a state: ';

VARIABLE b_num NUMBER;
VARIABLE b_flag CHAR(7);

EXECUTE add_zip2('&s_zip', '&s_city', '&&s_state', :b_flag, :b_num);

PRINT b_flag;
PRINT b_num;

SELECT *
    FROM zipcode
    WHERE upper(state) = upper('&s_state');

-- Only ROLLBACK on success...
EXECUTE IF :b_flag = 'SUCCESS' THEN ROLLBACK; END IF;

/*
Output:
Case 1:
Enter a zip code: 18104
Enter a city: Chicago
Enter a state: MI

PL/SQL procedure successfully completed.


B_FLAG
--------------------------------------------------------------------------------
SUCCESS


     B_NUM
----------
         2
         
ZIP     CITY        STATE   CREATED_BY      CREATED_DATE    MODIFIED_BY     MODIFIED_DATE
48104	Ann Arbor	MI	    AMORRISO	    99-08-03	    ARISCHER	    99-11-24
18104	Chicago	    MI	    DBS501_202A06	20-06-17	    DBS501_202A06	20-06-17

PL/SQL procedure successfully completed.

Case 2:
Enter a zip code: 48104
Enter a city: Chicago
Enter a state: MI

This ZIPCODE 48104 is already in the Database. Try again. 


PL/SQL procedure successfully completed.


B_FLAG
--------------------------------------------------------------------------------
FAILURE


     B_NUM
----------
         1

ZIP     CITY        STATE   CREATED_BY      CREATED_DATE    MODIFIED_BY     MODIFIED_DATE
48104	Ann Arbor	MI	    AMORRISO	    99-08-03	    ARISCHER	    99-11-24

PL/SQL procedure successfully completed.
*/

----------------
-- Question 4
----------------

CREATE OR REPLACE FUNCTION instruct_status (
        p_first     instructor.first_name%TYPE,
        p_last      instructor.last_name%TYPE
    ) RETURN CHAR IS
    v_id            instructor.instructor_id%TYPE;
    v_num_section   PLS_INTEGER;
BEGIN

    SELECT instructor_id INTO v_id
        FROM instructor
        WHERE upper(first_name) = upper(p_first)
            AND upper(last_name) = upper(p_last);
    
    SELECT count(section_id) INTO v_num_section
        FROM section
        WHERE instructor_id = v_id;
        
    RETURN (
        CASE
            WHEN v_num_section >= 10 THEN
                'This Instructor will teach ' || v_num_section || ' courses and needs a vacation.'
            WHEN v_num_section > 0 THEN
                'This Instructor will teach ' || v_num_section || ' courses.'
            ELSE
                'This Instructor is NOT scheduled to teach.'
        END
    );
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'There is NO such instructor.';
        WHEN TOO_MANY_ROWS THEN
            RETURN 'There are multiple matches.';
END;
/

SELECT last_name, instruct_status(p_first => first_name, p_last => last_name) AS "Instructor Status"
    FROM instructor
    ORDER BY last_name;


VARIABLE b_result CHAR; 

EXECUTE :b_result := instruct_status(p_first => 'PETER', p_last => 'PAN');
PRINT b_result;

EXECUTE :b_result := instruct_status(p_first => 'IRENE', p_last => 'WILLIG');
PRINT b_result;

/*
Output:
SELECT statement output:

LAST_NAME   Instructor Status
Chow	    This Instructor is NOT scheduled to teach.
Frantzen	This Instructor will teach 10 courses and needs a vacation.
Hanks	    This Instructor will teach 9 courses.
Lowry	    This Instructor will teach 9 courses.
Morris	    This Instructor will teach 10 courses and needs a vacation.
Pertez	    This Instructor will teach 10 courses and needs a vacation.
Schorin	    This Instructor will teach 10 courses and needs a vacation.
Smythe	    This Instructor will teach 10 courses and needs a vacation.
Willig	    This Instructor is NOT scheduled to teach.


Bind variable tests:
Case 1 (EXECUTE :b_result := instruct_status(p_first => 'PETER', p_last => 'PAN');):

PL/SQL procedure successfully completed.


B_RESULT
--------------------------------------------------------------------------------
There is NO such instructor.



Case 2 (EXECUTE :b_result := instruct_status(p_first => 'IRENE', p_last => 'WILLIG');):

PL/SQL procedure successfully completed.


B_RESULT
--------------------------------------------------------------------------------
This Instructor is NOT scheduled to teach.

*/