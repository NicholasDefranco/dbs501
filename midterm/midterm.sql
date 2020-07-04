-- Question 1:
-- If you were to enter 0 for the student Id prompt, what would it output?
SET SERVEROUTPUT ON;
SET  VERIFY  OFF;
             
ACCEPT studnum PROMPT 'Enter Student Id';
DECLARE       
    v_id          student.student_id%TYPE := &studnum;
    e_invalid     EXCEPTION;
BEGIN

    BEGIN
        IF v_id <=0 THEN
            RAISE e_invalid;
        END IF;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Student with Id : ' || v_id || ' does NOT exist.');
            WHEN  E_INVALID THEN
                NULL;
    END;
    
    DBMS_OUTPUT.PUT_LINE('Great');
        
    EXCEPTION
        WHEN  E_INVALID THEN
            DBMS_OUTPUT.PUT_LINE('Student  Id  must be a positive integer');
END;
/


-- Question 2: 
-- If you were to enter 'Ku' for the prompt asking for the first two letters, what would it output?
SET SERVEROUTPUT ON;
SET VERIFY OFF;

ACCEPT  let PROMPT  'Enter first two letters of the last name: ';

DECLARE

   CURSOR c1 IS
       SELECT zip, city, last_name
           FROM student JOIN zipcode USING (zip)
           WHERE last_name LIKE '&&let%'
           AND student_id < 121
           ORDER BY 1;

   TYPE zip_type IS RECORD (
      zip_code      zipcode.zip%TYPE,
      v_city        zipcode.city%TYPE,
      v_name        VARCHAR2(20) 
    );

    zip_rec         ZIP_TYPE;
    total           INTEGER := 0;

BEGIN

    OPEN c1;
    LOOP     
        FETCH  c1 INTO zip_rec;                 
        EXIT  WHEN  c1%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Zip code  : ' || zip_rec.zip_code || ' has student  ' || zip_rec.v_name  || ' who lives in  '  || zip_rec.v_city);
        total := c1%ROWCOUNT;
    END LOOP;
    CLOSE  c1;
    
    IF  total = 0 then
        DBMS_OUTPUT.PUT_LINE('These letters are student empty. Please, try again. ');
    ELSE       
        DBMS_OUTPUT.PUT_LINE('************************************');
        DBMS_OUTPUT.PUT_LINE('Total # of students  under ' || '&let'  || ' is ' ||  total);
    END  IF;                            
END;
/


SELECT * FROM instructor;

-- Question 3: Coding question
-- test case was if instructor id was 108

/*
Output:
There are 6 students for section ID 86
There are 2 students for section ID 100
There are 2 students for section ID 108
There are many students for section Id 116
There are 2 students for section ID 132
There are many students for section Id 147
There are 5 students for section ID 155
=================================================
There are 7 non-empty sections for instructor Id of 108
There are 33 students enrolled for this instructor altogether.
*/

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- NOTE: the declare section was given to us
ACCEPT inst PROMPT 'Enter a valid Instructor Id ';
DECLARE
    CURSOR c1 IS
        SELECT section_id
            FROM section
            WHERE instructor_id = &inst
            ORDER BY 1;
            
   v_flag           CHAR;
   sec_rec          c1%ROWTYPE; 
   v_enrol          NUMBER(3);
   counter          NUMBER(3) := 0;
   tot#             NUMBER(3) := 0;
   e_many_students  EXCEPTION;

BEGIN
        
    SELECT 'Y' INTO v_flag 
        FROM Instructor
        WHERE instructor_id = &inst;

    OPEN c1;
    FETCH c1 INTO sec_rec;
    IF c1%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('This instructor with the Id of ' || &inst || ' does NOT have any section scheduled. ');
        CLOSE c1;
    ELSE
        CLOSE c1;
        
        FOR rec IN c1 LOOP
            BEGIN
                SELECT count(student_id)
                    INTO v_enrol
                    FROM enrollment
                    WHERE section_id = rec.section_id;
                    
                tot# := tot# + v_enrol;
                IF v_enrol >= 8 THEN
                    counter := counter + 1;
                    RAISE e_many_students;
                ELSIF v_enrol > 0 THEN
                    DBMS_OUTPUT.PUT_LINE('There are ' || v_enrol || ' students for section ID ' || rec.section_id);
                    counter := counter + 1;
                END IF;
                
                EXCEPTION
                    WHEN e_many_students THEN
                        DBMS_OUTPUT.PUT_LINE('There are many students for section Id ' || rec.section_id);
                                    
            END;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('=================================================');
        DBMS_OUTPUT.PUT_LINE('There are ' || counter || ' non-empty sections for instructor Id of ' || &inst);
        DBMS_OUTPUT.PUT_LINE('There are ' || tot# || ' students enrolled for this instructor altogether.');
    END IF;
    
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('There is NO instructor with the Id of ' || &inst);
    
END;
/