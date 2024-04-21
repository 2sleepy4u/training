#[macro_use] extern crate rocket;
use std::path::{PathBuf, Path};

use auth::types::isAuth;
use rocket::Request;
use rocket::fairing::AdHoc;
use rocket::form::validate::Contains;
use rocket::http::{Cookie, Header};
use rocket::response::Redirect;
use rocket_db_pools::Database;
use rocket::fs::{FileServer, relative, NamedFile};

mod auth;
mod exercises;
use auth::routes::*;
use exercises::*;


#[get("/ping")]
fn ping() -> String {
    "pong".to_string()
}
#[get("/<path..>")]
pub async fn file_serve(path: PathBuf) -> Option<NamedFile> {
    if path.to_str().contains(".") {
        let path = Path::new(relative!("static/")).join(path);
        NamedFile::open(path).await.ok()
    } else {
        let mut path = Path::new(relative!("static/")).join("");
        path.push("index.html");

        NamedFile::open(path).await.ok()
    }
}
#[options("/<_..>")]
fn request_roll_preflight() {}

#[catch(401)]
fn unauthorized(req: &Request) -> Redirect {
    req.cookies().remove(Cookie::from("SSID"));
    Redirect::to(uri!("/login"))
}

const ALLOWED_ORIGINS: &str = "http://192.168.0.194:8090";
#[launch]
fn rocket() -> _ {
    println!("Starting server...");
    rocket::build()
        .attach(AdHoc::on_response("Add CORS", |_req, response| Box::pin(async move {
            response.set_header(Header::new("Access-Control-Allow-Origin", ALLOWED_ORIGINS));
            response.set_header(Header::new("Access-Control-Allow-Methods", "POST, GET, PATCH, OPTIONS"));
            response.set_header(Header::new("Access-Control-Allow-Headers", "Content-Type"));
            response.set_header(Header::new("Access-Control-Allow-Credentials", "true"));

        })))
        .attach(Training::init())
        .mount("/", routes![
               ping,
               request_roll_preflight,
               get_new_session,
               insert_plan,
               insert_execution,
               get_daily,
               file_serve 
        ])
        .register("/", catchers![unauthorized])
            
}

