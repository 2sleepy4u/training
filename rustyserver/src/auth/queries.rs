pub const NEW_SESSION_QUERY: &str = "
    INSERT INTO Sessions
    (ssid, id_user, creation_date) VALUES
    ($1, $2, CURRENT_DATE)
";

pub const CHECK_SESSION: &str = "
   SELECT
        U.id_user,
        SS.SSID
    FROM
        Users U LEFT JOIN (
                Sessions S INNER JOIN
                GeneralParams P ON CURRENT_DATE <= S.creation_date + P.session_duration
                ) SS ON U.id_user = SS.id_user
    WHERE
        SS.SSID = $1 AND U.active = true
    LIMIT 1
";


pub const CHECK_USER_QUERY: &str = "
   SELECT
        U.id_user,
        SS.SSID
    FROM
        Users U LEFT JOIN (
                Sessions S INNER JOIN
                GeneralParams P ON CURRENT_DATE <= S.creation_date + P.session_duration
                ) SS ON U.id_user = SS.id_user
    WHERE
        U.email = $1 AND U.password = $2 AND U.active = true

        ORDER BY SS.creation_date DESC
   LIMIT 1

";


