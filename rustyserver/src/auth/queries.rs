pub const NEW_SESSION_QUERY: &str = "
    INSERT INTO Sessions 
    (ssid, id_user, creation_date) VALUES
    ($1, $2, CURRENT_DATE)
";

pub const CHECK_SESSION: &str = "
   SELECT
        S.SSID
    FROM 
        Sessions S LEFT JOIN LATERAL
        GeneralParams P ON true
    WHERE 
        S.SSID = $1 AND U.active = true
    AND CURRENT_DATE <= S.creation_date + P.session_duration   
    LIMIT 1
";


pub const CHECK_USER_QUERY: &str = "
    SELECT
        U.id_user,
        S.SSID
    FROM 
        Users U LEFT JOIN
        Sessions S ON U.id_utente = S.id_utente LEFT JOIN LATERAL
        GeneralParams P ON true
    WHERE 
        U.email = $1 AND U.password = $2 AND U.active = true
    AND CURRENT_DATE <= S.creation_date + P.session_duration   
    LIMIT 1
";


