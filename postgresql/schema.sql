--Authentication

CREATE TABLE Users (
    id_user SERIAL PRIMARY KEY,
    email VARCHAR(50),
    password VARCHAR(255),
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE Sessions (
    ssid UUID PRIMARY KEY,
    id_user INT, 
    creation_date DATE,

    CONSTRAINT fk_id_user
        FOREIGN KEY(id_user)
        REFERENCES Users(id_user)
);

CREATE TABLE GeneralParams (
    session_duration INT DEFAULT 30
);

CREATE TYPE Weekday AS ENUM (
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
);


CREATE TABLE ExercisePlan (
    id_exercise_plan SERIAL PRIMARY KEY,
    id_user INT,
    name VARCHAR(20) UNIQUE,
    description VARCHAR(255),

    min_sets INT DEFAULT 3,
    max_sets INT DEFAULT 4,

    min_reps INT DEFAULT 8,
    max_reps INT DEFAULT 12,

    min_weight INT DEFAULT 0,
    weight_step INT,

    minutes INT,

    weekday Weekday,
    active BOOLEAN,

    CONSTRAINT fk_id_user_exercise_plan
        FOREIGN KEY(id_user)
        REFERENCES Users(id_user)
);

CREATE TABLE ExerciseExecution (
    id_exercise_execution SERIAL PRIMARY KEY,
    id_exercise_plan INT,
    execution_date TIMESTAMP,

    CONSTRAINT fk_exercise_plan
        FOREIGN KEY(id_exercise_plan)
        REFERENCES ExercisePlan(id_exercise_plan)
);

CREATE TABLE ExerciseRow (
  id_row SERIAL PRIMARY KEY,
  id_exercise_execution INT,
  row_number INT,
  reps INT NOT NULL,
  weight INT DEFAULT 0,
  seconds INT,

  CONSTRAINT fk_exercise_execution
    FOREIGN KEY(id_exercise_execution)
    REFERENCES ExerciseExecution(id_exercise_execution)
);

CREATE FUNCTION calculate_exercise_level (

)
RETURNS TABLE (
  reps INT,
  weight INT,
)  
LANGUAGE plpgsql 
AS $$
DECLARE
  avg_reps INT;
  max_weight INT;
BEGIN
    
END
$$;



--Derive Level

CREATE FUNCTION get_exercise_level (
   input_id_plan INT
) 
RETURNS TABLE (
  reps INT,
  sets INT,
  weight INT,
  minutes INT
)  
LANGUAGE plpgsql 
AS $$
DECLARE
  _avg_reps INT;
  _max_weight INT;
  _max_sets INT;
  potential_set BOOLEAN;
  potential_rep BOOLEAN;
  potential_wieght BOOLEAN;

BEGIN
  SELECT 
    COUNT(*), 
    SUM(ER.reps) / COUNT(*), 
    MAX(ER.weight) 
    INTO 
    _max_sets, 
    _avg_reps, 
    _max_weight
  FROM  
    ExercisePlan EP INNER JOIN
    ExerciseExecution EE ON EP.id_exercise_plan = EE.id_exercise_plan INNER JOIN
    ExerciseRow ER ON ER.id_exercise_execution = EE.id_exercise_execution
  WHERE
    EP.id_exercise_plan = input_id_plan
    AND EE.execution_date < CURRENT_DATE
  GROUP BY EE.id_exercise_execution
  ORDER BY 
    EE.execution_date DESC
  LIMIT 1;

  SELECT 
    CASE
      WHEN EP.min_reps <= _avg_reps AND _avg_reps < EP.max_reps THEN true
      ELSE false
    END CASE,
    CASE
      WHEN EP.min_sets <= _max_sets 
          AND _max_sets < EP.max_sets 
          AND _avg_reps = EP.max_reps 
      THEN true
      ELSE false
    END CASE,
    CASE
      WHEN EP.min_weight <= _max_weight 
          AND _max_sets = EP.max_sets   
      THEN true
      ELSE false
    END CASE 
    INTO potential_rep, potential_set, potential_wieght
  FROM
    ExercisePlan EP 
  WHERE
    EP.id_exercise_plan = input_id_plan
  LIMIT 1;


  RETURN QUERY
   SELECT
    CASE
      WHEN potential_rep THEN _avg_reps + 1
      WHEN (NOT potential_rep AND potential_set) 
        OR (NOT potential_rep AND NOT potential_set AND potential_wieght)
      THEN EP.min_reps
      ELSE GREATEST(_avg_reps, EP.min_reps)
    END AS reps,
    CASE
      WHEN NOT potential_rep AND potential_set THEN _max_sets + 1 
      WHEN NOT potential_rep AND NOT potential_set THEN EP.min_sets
      ELSE GREATEST(_max_sets, EP.min_sets)
    END AS sets,
    CASE
      WHEN NOT potential_rep AND NOT potential_set AND potential_wieght THEN _max_weight + EP.weight_step 
      ELSE _max_weight
    END AS weight,
    0 AS minutes
  FROM  
    ExercisePlan EP INNER JOIN
    ExerciseExecution EE ON EP.id_exercise_plan = EE.id_exercise_plan INNER JOIN
    ExerciseRow ER ON ER.id_exercise_execution = EE.id_exercise_execution
  WHERE
    EP.id_exercise_plan = input_id_plan
    AND EE.execution_date < CURRENT_DATE
  ORDER BY 
    EE.execution_date
  LIMIT 1;

END
$$;




