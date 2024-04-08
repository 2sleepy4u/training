#[macro_use] extern crate rocket;
use rocket::Request;
use rocket::fairing::AdHoc;
use rocket::http::{Cookie, Header};
use rocket_db_pools::Database;
use rocket::fs::{FileServer, relative};

mod auth;
mod exercises;
use auth::routes::*;
use exercises::*;


#[get("/ping")]
fn ping() -> String {
    "pong".to_string()
}

#[options("/<_..>")]
fn request_roll_preflight() {}

#[catch(401)]
fn unauthorized(req: &Request) -> String {
    req.cookies().remove(Cookie::from("SSID"));
    "Ops Not Authorized".to_owned()
}

const ALLOWED_ORIGINS: &str = "http://192.168.0.149:4173";
#[launch]
fn rocket() -> _ {
    println!("Starting server...");
    rocket::build()
        .attach(AdHoc::on_response("Add CORS", |_req, response| Box::pin(async move {
            response.set_header(Header::new("Access-Control-Allow-Origin", ALLOWED_ORIGINS));
            response.set_header(Header::new("Access-Control-Allow-Methods", "POST, GET, PATCH, OPTIONS"));
            response.set_header(Header::new("Access-Control-Allow-Headers", "*"));
            response.set_header(Header::new("Access-Control-Allow-Credentials", "true"));

        })))
        .attach(Training::init())
        .mount("/", routes![
               ping,
               request_roll_preflight,
               get_new_session,
               insert_plan,
               insert_execution,
               get_daily
        ])
        .mount("/", FileServer::from(relative!("build/")))
        .register("/", catchers![unauthorized])
            
}

