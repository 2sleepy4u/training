use rocket::http::Status;
use rocket::serde::json::Json;
use rocket_db_pools::Connection;
use rocket_db_pools::sqlx::{self, Row};
use rocket::serde::{Deserialize, Serialize};

use chrono::Datelike;
use crate::auth::routes::Training;
use crate::auth::types::isAuth;

#[derive(Deserialize)]
#[serde(crate = "rocket::serde")]
pub struct Execution {
    pub id_plan: i32,
    pub reps: Vec<i32>,
    pub weight: i32,
    pub note: String
}


#[derive(sqlx::FromRow, Serialize, Deserialize)]
#[serde(crate = "rocket::serde")]
pub struct Plan {
    pub id_plan: i32,
    pub name: String,
    pub description: String,
    pub min_reps: i32,
    pub max_reps: i32,
    pub min_sets: i32,
    pub max_sets: i32,
    pub min_weight: i32,
    pub weight_step: i32,
    pub weekday: Vec<String>,
    pub active: bool
}

#[derive(sqlx::FromRow, Serialize)]
#[serde(crate = "rocket::serde")]
pub struct Exercise {
    pub id_plan: i32,
    pub name: String,
    pub description: String,
    pub reps: i32,
    pub sets: i32,
    pub weight: i32,
    pub is_done: bool,
    pub done_reps: Vec<i32>,
    pub note: String,  
}

#[derive(Serialize)]
#[serde(crate = "rocket::serde")]
pub struct Daily {
    pub weekday: String,
    pub exercises: Vec<Exercise>
}

fn get_current_weekday() -> String {
    let current_time = chrono::offset::Local::now();
    let weekday = current_time.date_naive().weekday();
    let weekday = match weekday {
        chrono::Weekday::Sun => "Sunday",
        chrono::Weekday::Mon => "Monday",
        chrono::Weekday::Tue => "Tuesday",
        chrono::Weekday::Wed => "Wednesday",
        chrono::Weekday::Thu => "Thursday",
        chrono::Weekday::Fri => "Friday",
        chrono::Weekday::Sat => "Saturday",
    };
    weekday.to_string()
}

#[get("/get_daily", format = "json")]
pub async fn get_daily(
    auth: isAuth,
    mut db: Connection<Training>
) -> Result<Json<Daily>, Status> {
    let query = include_str!("./../postgresql/queries/get_daily.sql");
    let result = sqlx::query_as::<_, Exercise>(query)
        .bind(&auth.ssid)
        .fetch_all(&mut **db)
        .await;

    match result {
        Ok(exercises) => {
            let weekday = get_current_weekday();
            let daily = Daily { weekday, exercises};
            Result::Ok(Json(daily))
        },
        Err(e) =>  {
            error!("Error while retriving daily exercises: {}", e);
            Result::Err(Status::InternalServerError)
        }
    }
}

#[post("/get_plan_list", format = "json")]
pub async fn get_plan_list(
    auth: isAuth,
    mut db: Connection<Training>
) -> Result<Json<Vec<Plan>>, Status> {
    let result = sqlx::query_as::<_, Plan>(GET_LIST)
        .bind(&auth.ssid)
        .fetch_all(&mut **db)
        .await;

    match result {
        Ok(result) => Result::Ok(Json(result)),
        Err(e) =>  {
            error!("Error while retriving plan list: {}", e);
            Result::Err(Status::InternalServerError)
        }
    }
}

#[post("/update_plan", format = "json", data = "<payload>")]
pub async fn update_plan(
    payload: Json<Plan>, 
    auth: isAuth,
    mut db: Connection<Training>
) -> Status {
    let result = sqlx::query(UPDATE_PLAN)
        .bind(&payload.name)
        .bind(&payload.description)
        .bind(&payload.min_reps)
        .bind(&payload.max_reps)
        .bind(&payload.min_sets)
        .bind(&payload.max_sets)
        .bind(&payload.min_weight)
        .bind(&payload.weight_step)
        .bind(&payload.weekday)
        .bind(&payload.active)
        .bind(&auth.ssid)
        .execute(&mut **db)
        .await;

    if let Err(e) = result {
        error!("Error while inserting plan: {}", e);
        return Status::InternalServerError
    }
    
    Status::Ok
}

#[post("/insert_plan", format = "json", data = "<payload>")]
pub async fn insert_plan(
    payload: Json<Plan>, 
    auth: isAuth,
    mut db: Connection<Training>
) -> Status {
    let result = sqlx::query(INSERT_PLAN)
        .bind(auth.id_user)
        .bind(&payload.name)
        .bind(&payload.description)
        .bind(&payload.min_reps)
        .bind(&payload.max_reps)
        .bind(&payload.min_sets)
        .bind(&payload.max_sets)
        .bind(&payload.min_weight)
        .bind(&payload.weight_step)
        .bind(&payload.weekday)
        .execute(&mut **db)
        .await;

    if let Err(e) = result {
        error!("Error while inserting plan: {}", e);
        return Status::InternalServerError
    }
    
    Status::Ok
}

#[post("/insert_execution", format = "json", data = "<payload>")]
pub async fn insert_execution (
    payload: Json<Execution>, 
    mut db: Connection<Training>,
    _auth: isAuth
) -> Status {
    let result =  
        sqlx::query_as::<_, (i32,)>(INSERT_EXECUTION)
            .bind(&payload.id_plan)
            .bind(&payload.note)
            .fetch_one(&mut **db)
            .await;

    let id = 
        match result {
            Ok(res) => res.0,
            Err(e) => panic!("{}", e)
        };

        for (i, reps) in payload.reps.iter().enumerate() {
           let result = sqlx::query(INSERT_EXECUTION_ROW)
               .bind(id)
               .bind(i as i32)
               .bind(reps)
               .bind(&payload.weight)
               .execute(&mut **db)
               .await;

           if let Err(e) = result {
                panic!("{}", e);
           };
        }
        Status::Ok
}

pub const INSERT_PLAN: &str = "
    INSERT INTO ExercisePlan 
    (id_user, name, description, min_sets, max_sets, min_reps, max_reps, min_weight, weight_step, weekday) VALUES
    ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10::Weekday[])
";
pub const UPDATE_PLAN: &str = "
    UPDATE ExercisePlan 
    SET
        description = $1,
        min_sets = $2,
        max_sets = $3, 
        min_reps = $4, 
        max_reps = $5, 
        min_weight = $6, 
        weight_step = $7,
        weekday = $8,
        active = $9
    WHERE
        id_user = $10 AND name = $11

";
pub const GET_DAILY: &str = "
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
      --COALESCE(EE.note, '') AS note
      '' AS note
    FROM
      ExercisePlan EP INNER JOIN
      Sessions S ON S.id_user = EP.id_user LEFT JOIN
      ExerciseExecution EE ON EE.id_exercise_plan = EP.id_exercise_plan LEFT JOIN LATERAL
      get_exercise_level(EP.id_exercise_plan) EL ON true   
    WHERE
      S.SSID = $1
    --AND EP.weekday = TRIM(To_Char(CURRENT_DATE, 'Day'))::Weekday
";

pub const INSERT_EXECUTION_ROW: &str = "
    INSERT INTO ExerciseRow
    (id_exercise_execution, row_number, reps, weight) VALUES
    ($1, $2, $3, $4)
";

pub const GET_LIST: &str = "
";
pub const INSERT_EXECUTION: &str = "
    INSERT INTO ExerciseExecution 
        (id_exercise_plan, note, execution_date) VALUES
        ($1, $2, CURRENT_DATE)
    RETURNING id_exercise_execution
";

