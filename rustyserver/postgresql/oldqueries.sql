--get ssid
SELECT TOP(1)
    S.SSID
FROM 
    Users U INNER JOIN
    Sessions S ON U.id_utente = S.id_utente LEFT JOIN LATERAL
    GeneralParams P ON true
WHERE 
    U.email = $1 AND U.password = $2 AND U.active = true
AND CURRENT_DATE <= S.creation_date + P.session_duration   

;


--insert session
INSERT INTO Sessions 
(ssid, id_user, creation_date) VALUES
($1, $2, CURRENT_DATE)

;

--delete old sessions
DELETE 
FROM 
    Sessions S LEFT JOIN LATERAL 
    GeneralParams P ON true
WHERE 
    S.creation_date + P.session_duration < CURRENT_DATE
;
--insert user
INSERT INTO Users (email, password) VALUES ($1, $2);

;

--insert plan
INSERT INTO ExercisePlan 
(id_user, name, description, min_sets, max_sets, min_resp, max_resp, min_weight, weight_step, weekday) VALUES
($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)

;

--update plan
UPDATE ExercisePlan 
SET
    description = COALESCE($1, description),
    max_sets = COALESCE($2, max_sets),
    max_reps = COALESCE($3, max_reps),
    weekday = COALESCE($4, weekday)
WHERE
    name = $5

;
--insert execution
INSERT INTO ExerciseExecution 
    (id_exercise_plan, id_user, sets, reps, weight, execution_date) VALUES
    (P.id_exercise_plan, $1, $2, $3, $4, CURRENT_DATE)
FROM 
    ExercisePlan P 
WHERE 
    P.name = $5

;

-- get executions 
SELECT
    *
FROM 
    ExerciseExecution EE
WHERE
    EE.execution_date > COALESCE($1, CURRENT_DATE - 30) AND EE.execution_date < COALESCE($2, CURRENT_DATE)
    AND EE.id_exercise_plan = COALESCE($3, EE.id_exercise_plan)


;

CREATE FUNCTION get_valid_user_from_session (SSID UUID) RETURNS INT
AS $$
DECLARE
    result INT;
BEGIN
    SELECT 
        S.SSID INTO result
    FROM 
        Users U INNER JOIN
        Sessions S ON U.id_utente = S.id_utente LEFT JOIN LATERAL
        GeneralParams P ON true
    WHERE 
        U.email = $1 AND U.password = $2 AND U.active = true
    AND CURRENT_DATE <= S.creation_date + P.session_duration   
    LIMIT 1;

    RETURN result;
END;
$$
LANGUAGE plpgsql;



--Get Daily

SELECT 
  EP.name,
  EP.description,
  EL.reps,
  EL.sets,
  EL.weight,
  EL.minutes
FROM
  ExercisePlan EP INNER JOIN
  Sessions S ON S.id_user = EP.id_user LEFT JOIN LATERAL
  get_exercise_level(EP.id_exercise_plan) EL ON true
WHERE
  S.SSID = $1
  EP.weekday = TRIM(To_Char(CURRENT_DATE, 'Day'))::Weekday
;


