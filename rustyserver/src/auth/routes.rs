use rocket::http::{CookieJar, Cookie, Status};
use rocket::serde::json::Json;
use rocket_db_pools::{Database, Connection};
use rocket_db_pools::sqlx::{self, Row};

use uuid::Uuid;

use super::types::*;
use super::queries::*;

#[derive(sqlx::FromRow)]
struct User {
    id_user: i32,
    ssid: Option<String>
}

#[derive(Database)]
#[database("training")]
pub struct Training(sqlx::PgPool);



#[post("/get_new_session", format = "json", data = "<payload>")]
pub async fn get_new_session(
    payload: Json<UserCredentials>, 
    cookies: &CookieJar<'_>,
    mut db: Connection<Training>
) -> Status 
{
    let email = &payload.email;
    let password = &payload.password;
    let result = sqlx::query_as::<_, User>(CHECK_USER_QUERY)
        .bind(email)
        .bind(password)
        .fetch_optional(&mut **db)
        .await;

    let user: User = 
        if let Ok(Some(row)) = result {
            row
        } else {
            panic!("No user found or wrong credential");
        };

    let token = 
        if let Some(ssid) = user.ssid {
            ssid
        } else {
            let token = Uuid::new_v4().to_string();
            let result = sqlx::query(NEW_SESSION_QUERY)
                .bind(&token)
                .bind(user.id_user)
                .execute(&mut **db)
                .await;

            if let Err(e) = result {
                panic!("Errore nella creazione della nuova sessione: {}", e);
            };
            token
        };
    let ssid = Cookie::build(("SSID", token))
        .http_only(true);

    cookies.add(ssid);

    Status::Ok
}
