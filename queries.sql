USE game_tracker;
-- 1. Database dashboard — counts across all major tables
SELECT
    (SELECT COUNT(*) FROM `User`) AS total_users,
    (SELECT COUNT(*) FROM Game) AS total_games,
    (SELECT COUNT(*) FROM Achievement) AS total_achievements,
    (SELECT COUNT(*) FROM Review) AS total_reviews,
    (SELECT COUNT(*) FROM Gaming_Session) AS total_sessions;
-- 2. Complete game catalog with developers, publishers, and genres
SELECT
    g.appid,
    g.name AS game_name,
    GROUP_CONCAT(DISTINCT d.developer_name) AS developers,
    GROUP_CONCAT(DISTINCT p.publisher_name) AS publishers,
    GROUP_CONCAT(DISTINCT ge.genre_name) AS genres
FROM Game g
LEFT JOIN Game_Developer gd ON g.appid = gd.appid
LEFT JOIN Developer d ON gd.developer_id = d.developer_id
LEFT JOIN Game_Publisher gp ON g.appid = gp.appid
LEFT JOIN Publisher p ON gp.publisher_id = p.publisher_id
LEFT JOIN Game_Genre gg ON g.appid = gg.appid
LEFT JOIN Genre ge ON gg.genre_id = ge.genre_id
GROUP BY g.appid, g.name
ORDER BY g.name;
-- 3. Top 10 games by number of owners
SELECT
    g.name AS game_name,
    SUM(ug.ownership_status = 'owned') AS owners,
    SUM(ug.ownership_status = 'borrowed') AS borrowed,
    SUM(ug.ownership_status = 'wishlist') AS wishlisted
FROM Game g
JOIN User_Game ug ON g.appid = ug.appid
GROUP BY g.appid, g.name
ORDER BY owners DESC
LIMIT 10;
-- 4. Top 10 games by total playtime
SELECT
    g.name AS game_name,
    ROUND(SUM(ug.playtime_forever) / 60, 2)
        AS total_playtime_hours,
    COUNT(DISTINCT ug.user_id) AS players
FROM Game g
JOIN User_Game ug ON g.appid = ug.appid
GROUP BY g.appid, g.name
ORDER BY total_playtime_hours DESC
LIMIT 10;
-- 5. Top 10 most active gamers
SELECT
    u.user_id,
    u.username,
    COUNT(DISTINCT ug.appid) AS game_records,
    ROUND(SUM(ug.playtime_forever) / 60, 2)
        AS total_playtime_hours
FROM `User` u
JOIN User_Game ug ON u.user_id = ug.user_id
GROUP BY u.user_id, u.username
ORDER BY total_playtime_hours DESC
LIMIT 10;
-- 6. Genre-wise popularity and playtime
SELECT
    ge.genre_name,
    COUNT(DISTINCT ug.user_id) AS unique_players,
    ROUND(SUM(ug.playtime_forever) / 60, 2)
        AS total_playtime_hours
FROM Genre ge
JOIN Game_Genre gg ON ge.genre_id = gg.genre_id
JOIN User_Game ug ON gg.appid = ug.appid
GROUP BY ge.genre_id, ge.genre_name
ORDER BY total_playtime_hours DESC;
-- 7. Achievement completion rate by game
SELECT
    g.name AS game_name,
    COUNT(ua.achievement_id) AS tracked_records,
    SUM(ua.is_unlocked = 1) AS unlocked_records,
    ROUND(
        100.0 * SUM(ua.is_unlocked = 1)
        / NULLIF(COUNT(ua.achievement_id), 0),
        2
    ) AS completion_percent
FROM Game g
JOIN Achievement a ON g.appid = a.appid
LEFT JOIN User_Achievement ua
    ON a.achievement_id = ua.achievement_id
GROUP BY g.appid, g.name
ORDER BY completion_percent DESC;
-- 8. Review and recommendation analysis
SELECT
    g.name AS game_name,
    COUNT(r.review_id) AS total_reviews,
    ROUND(
        100.0 * AVG(r.recommended = 1), 2
    ) AS recommendation_percent
FROM Game g
LEFT JOIN Review r ON g.appid = r.appid
GROUP BY g.appid, g.name
HAVING COUNT(r.review_id) >= 1
ORDER BY recommendation_percent DESC, total_reviews DESC;
-- 9. Player gaming-session activity
SELECT
    u.username,
    COUNT(gs.session_id) AS total_sessions,
    ROUND(SUM(gs.duration) / 60, 2) AS total_session_hours,
    ROUND(AVG(gs.duration), 2) AS average_session_minutes
FROM `User` u
JOIN Gaming_Session gs ON u.user_id = gs.user_id
GROUP BY u.user_id, u.username
HAVING COUNT(gs.session_id) >= 2
ORDER BY total_session_hours DESC
LIMIT 10;
