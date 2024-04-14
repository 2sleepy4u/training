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
