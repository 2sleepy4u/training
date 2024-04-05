use rocket::http::Status;
use rocket::serde::json::Json;
use rocket_db_pools::Connection;
use rocket_db_pools::sqlx::{self, Row};

use rocket::serde::{Deserialize, Serialize};
use crate::auth::routes::Training;
use crate::auth::types::isAuth;

#[derive(Deserialize)]
#[serde(crate = "rocket::serde")]
pub struct Execution {
    pub id_plan: i32,
    pub reps: Vec<i32>,
    pub weight: f32,
    pub note: String
}


#[derive(Deserialize)]
#[serde(crate = "rocket::serde")]
pub struct Plan {
    pub name: String,
    pub description: String,
    pub min_reps: i32,
    pub max_reps: i32,
    pub min_sets: i32,
    pub max_sets: i32,
    pub min_weight: i32,
    pub weight_step: f32,
    pub weekday: String,
    pub active: bool
}

#[derive(sqlx::FromRow, Serialize)]
#[serde(crate = "rocket::serde")]
pub struct Exercise {
    pub name: String,
    pub description: String,
    pub reps: i32,
    pub sets: i32,
    pub weight: f32,
    pub is_done: bool
}

#[derive(Serialize)]
#[serde(crate = "rocket::serde")]
pub struct Daily {
    pub weekday: String,
    pub exercises: Vec<Exercise>
}

#[post("/get_daily", format = "json")]
pub async fn get_daily(
    auth: isAuth,
    mut db: Connection<Training>
) -> Result<Json<Vec<Exercise>>, Status> {
    let result = sqlx::query_as::<_, Exercise>(GET_DAILY)
        .bind(&auth.token)
        .fetch_all(&mut **db)
        .await;

    match result {
        Ok(result) => Result::Ok(Json(result)),
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
) -> Result<Json<Vec<Exercise>>, Status> {
    let result = sqlx::query_as::<_, Exercise>(GET_LIST)
        .bind(&auth.token)
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
        .bind(&auth.token)
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
        .bind(&payload.name)
        .bind(&payload.description)
        .bind(&payload.min_reps)
        .bind(&payload.max_reps)
        .bind(&payload.min_sets)
        .bind(&payload.max_sets)
        .bind(&payload.min_weight)
        .bind(&payload.weight_step)
        .bind(&payload.weekday)
        .bind(&auth.token)
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
    auth: isAuth
) -> Status {
    sqlx::query(INSERT_EXECUTION)
        .bind(&payload.id_plan)
        .bind(&payload.reps)
        .bind(&payload.weight)
        .bind(&payload.note)
        .bind(&auth.token)
        .execute(&mut **db)
        .await
        .map_or_else(
            |e| {
                error!("Error while registering the execution: {}", e);
                Status::InternalServerError
            },
            |_| {Status::Ok}
            )

}

pub const INSERT_PLAN: &str = "
    INSERT INTO ExercisePlan 
    (id_user, name, description, min_sets, max_sets, min_resp, max_resp, min_weight, weight_step, weekday) VALUES
    ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
";
pub const UPDATE_PLAN: &str = "
    UPDATE ExercisePlan 
    SET
        description = $1,
        min_sets = $2,
        max_sets = $3, 
        min_resp = $4, 
        max_resp = $5, 
        min_weight = $6, 
        weight_step = $7,
        weekday = $8,
        active = $9
    WHERE
        id_user = $10 AND name = $11

";
pub const GET_DAILY: &str = "";
pub const GET_LIST: &str = "";
pub const INSERT_EXECUTION: &str = "";

