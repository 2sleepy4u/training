#[macro_use] extern crate rocket;
use rocket::Request;
use rocket::fairing::AdHoc;
use rocket::http::{Cookie, Header};
use rocket_db_pools::Database;

mod auth;
use auth::routes::*;


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
               get_new_session
        ])
        .register("/", catchers![unauthorized])
            
}

/*
 #[derive(Database)]
#[database("m2m")]
struct M2M(sqlx::MySqlPool);



#[get("/get_new_session")]
async fn get_new_session(mut db: Connection<M2M>) -> Option<String> {
    sqlx::query("SELECT 'ciao' as testo")
        .fetch_one(&mut **db).await
        .and_then(|r| Ok(r.try_get("testo")?))
        .ok()
}
*/
