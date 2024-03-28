use rocket_db_pools::{sqlx::Row, Connection};
use rocket::request::{FromRequest, Outcome, Request};
use rocket::http::Status;
use rocket::serde::{Deserialize, Serialize};

use super::queries::*;
use super::routes::*;

#[derive(Deserialize)]
#[serde(crate = "rocket::serde")]
pub struct UserCredentials {
    pub email: String,
    pub password: String
}

#[derive(Serialize)]
#[serde(crate = "rocket::serde")]
struct Token {
    token: String
}

pub struct isAuth(pub String);

#[derive(Debug)]
pub enum AuthStatus {
    Unauthorized,
    Authorized
}


#[rocket::async_trait]
impl<'r> FromRequest<'r> for isAuth {
    type Error = AuthStatus;

    async fn from_request(req: &'r Request<'_>) -> Outcome<Self, Self::Error> {

        async fn is_valid(mut db: Connection<Training>, ssid: &str) -> bool {
            if ssid.is_empty() {
                return false;
            }

           let row = sqlx::query(CHECK_USER_QUERY)
                .bind(ssid)
                .fetch_optional(&mut **db)
                .await;
           let result =
               if let Ok(Some(row)) = row {
                   let t: Result<String, _> = row.try_get("SSID");
                   t.is_ok()
               } else {
                   false
               };

            result
        }

        let ssid: &str = match req.cookies().get("SSID") {
            Some(cookie) => cookie.value(),
            None =>  ""
        };
        let db: Connection<Training> = match req.guard::<Connection<Training>>().await {
            rocket::outcome::Outcome::Success(a) => a,
            _ => panic!("Cannot retrive Connection Pool to Training dataBase from authentication middleware")
        };

        if is_valid(db, ssid).await {
            Outcome::Success(isAuth(ssid.to_string()))
        } else {
            Outcome::Error((Status::Unauthorized, AuthStatus::Unauthorized))
        }
    }
}
