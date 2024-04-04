#[macro_use] extern crate rocket;
use rocket::Request;
use rocket::fairing::AdHoc;
use rocket::http::{Cookie, Header};
use rocket_db_pools::Database;

mod auth;
mod exercises;
use auth::routes::*;
use exercises::*;


#[options("/<_..>")]
fn request_roll_preflight() {}

#[catch(401)]
fn unauthorized(req: &Request) -> String {
    req.cookies().remove(Cookie::from("SSID"));
    "Ops Not Authorized".to_owned()
}

#[launch]
fn rocket() -> _ {
    println!("Starting server...");

    rocket::build()
        .attach(AdHoc::on_response("Add CORS", |_req, response| Box::pin(async move {
            response.set_header(Header::new("Access-Control-Allow-Origin", "*"));
            response.set_header(Header::new("Access-Control-Allow-Methods", "POST, GET, PATCH, OPTIONS"));
            response.set_header(Header::new("Access-Control-Allow-Headers", "*"));
            response.set_header(Header::new("Access-Control-Allow-Credentials", "true"));

        })))
        .attach(Training::init())
        .mount("/", routes![
               request_roll_preflight,
               get_new_session,
               insert_plan,
               insert_execution,
               get_daily
        ])
        .register("/", catchers![unauthorized])
            
}

