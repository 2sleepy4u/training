use std::str::FromStr;

use rocket_db_pools::{sqlx::Row, Connection};
use rocket::request::{FromRequest, Outcome, Request};
use rocket::http::Status;
use rocket::serde::{Deserialize, Serialize};
use uuid::Uuid;

use super::queries::*;
use super::routes::*;

#[derive(Deserialize)]
#[serde(crate = "rocket::serde")]
pub struct UserCredentials {
    pub email: String,
    pub password: String
}

#[derive(sqlx::FromRow, Debug)]
pub struct isAuth {
    pub id_user: i32,
    pub ssid: Uuid
}

#[derive(Debug)]
pub enum AuthStatus {
    Unauthorized,
    Authorized
}


#[rocket::async_trait]
impl<'r> FromRequest<'r> for isAuth {
    type Error = AuthStatus;

    async fn from_request(req: &'r Request<'_>) -> Outcome<Self, Self::Error> {
        let ssid: &str = req.cookies().get("SSID")
            .map_or("", |cookie| cookie.value());

        debug!("AUTH SSID is {}", ssid);

        if ssid.is_empty() {
            return Outcome::Error((Status::Unauthorized, AuthStatus::Unauthorized));
        }

        let ssid = 
            match Uuid::from_str(ssid) {
                Ok(value) => value,
                Err(e) => panic!("{}", e)
            };
        let mut db: Connection<Training> = match req.guard::<Connection<Training>>().await {
            rocket::outcome::Outcome::Success(a) => a,
            _ => panic!("Cannot retrive Connection Pool to Training dataBase from authentication middleware")
        };

        let row = sqlx::query_as::<_, isAuth>(CHECK_SESSION)
            .bind(ssid)
            .fetch_optional(&mut **db)
            .await;

        warn!("{:?}", row);
        if let Ok(Some(is_auth)) = row {
            Outcome::Success(is_auth)
        } else {
            Outcome::Error((Status::Unauthorized, AuthStatus::Unauthorized))
        }

    }
}
