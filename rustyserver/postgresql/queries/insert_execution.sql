    INSERT INTO ExerciseExecution 
        (id_exercise_plan, note, execution_date) VALUES
        ($1, $2, CURRENT_DATE)
    RETURNING id_exercise_execution
