   SELECT 
      EP.id_exercise_plan AS id_plan,
      EP.name,
      EP.description,
      COALESCE(EL.reps, EP.min_reps) AS reps,
      COALESCE(EL.sets, EP.min_sets) AS sets,
      COALESCE(EL.weight, EP.min_weight) AS weight,
      COALESCE(EL.minutes, 0) AS minutes,
      EXISTS ( 
          SELECT *
          FROM ExerciseExecution EE
          WHERE EE.execution_date = CURRENT_DATE
          AND EE.id_exercise_plan = EP.id_exercise_plan
      ) AS is_done,
      CASE
        WHEN ARRAY_LENGTH(ARRAY(   
            SELECT 
              ER.reps
            FROM 
              ExerciseExecution EE INNER JOIN
              ExerciseRow ER ON EE.id_exercise_execution = ER.id_exercise_execution
            WHERE 
              EE.execution_date = CURRENT_DATE
            AND EE.id_exercise_plan = EP.id_exercise_plan
        ),1) IS NULL
        THEN ARRAY(select 0 as num from generate_series(1, COALESCE(EL.sets, EP.min_sets)))
        ELSE ARRAY(
          SELECT 
            ER.reps
          FROM 
            ExerciseExecution EE INNER JOIN
            ExerciseRow ER ON EE.id_exercise_execution = ER.id_exercise_execution
          WHERE 
            EE.execution_date = CURRENT_DATE
          AND EE.id_exercise_plan = EP.id_exercise_plan
      ) END AS done_reps,
        '' as note
      --COALESCE(EE.note, '') AS note
    FROM
      ExercisePlan EP INNER JOIN
      Sessions S ON S.id_user = EP.id_user LEFT JOIN
      ExerciseExecution EE ON EE.id_exercise_plan = EP.id_exercise_plan LEFT JOIN LATERAL
      get_exercise_level(EP.id_exercise_plan) EL ON true   
    WHERE
      S.SSID = $1
    AND TRIM(To_Char(CURRENT_DATE, 'Day'))::Weekday = any(EP.weekday)
