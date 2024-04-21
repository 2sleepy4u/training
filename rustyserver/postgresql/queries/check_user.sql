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


