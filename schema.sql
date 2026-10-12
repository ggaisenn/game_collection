CREATE DATABASE IF NOT EXISTS game_tracker;
USE game_tracker;
-- 1. USER
CREATE TABLE User (
    user_id BIGINT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    profile_url VARCHAR(500),
    user_level INT DEFAULT 0,
    CHECK (user_level >= 0)
);

-- 2. GAME
CREATE TABLE Game (
    appid INT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    release_date DATE,
    type VARCHAR(50) DEFAULT 'game',
    is_free BOOLEAN DEFAULT FALSE,
    required_age INT DEFAULT 0,
    CHECK (required_age >= 0)
);

-- 3. DEVELOPER
CREATE TABLE Developer (
    developer_id INT AUTO_INCREMENT PRIMARY KEY,
    developer_name VARCHAR(200) NOT NULL UNIQUE
);

-- 4. PUBLISHER
CREATE TABLE Publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(200) NOT NULL UNIQUE
);

-- 5. GENRE
CREATE TABLE Genre (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(100) NOT NULL UNIQUE
);

-- 6. CATEGORY
CREATE TABLE Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- 7. PLATFORM
CREATE TABLE Platform (
    platform_id INT AUTO_INCREMENT PRIMARY KEY,
    platform_name VARCHAR(50) NOT NULL UNIQUE
);
-- 8. GAME_DEVELOPER
CREATE TABLE Game_Developer (
    appid INT NOT NULL,
    developer_id INT NOT NULL,
    PRIMARY KEY (appid, developer_id),
    FOREIGN KEY (appid) REFERENCES Game(appid),
    FOREIGN KEY (developer_id) REFERENCES Developer(developer_id)
);

-- 9. GAME_PUBLISHER
CREATE TABLE Game_Publisher (
    appid INT NOT NULL,
    publisher_id INT NOT NULL,
    PRIMARY KEY (appid, publisher_id),
    FOREIGN KEY (appid) REFERENCES Game(appid),
    FOREIGN KEY (publisher_id) REFERENCES Publisher(publisher_id)
);

-- 10. GAME_GENRE
CREATE TABLE Game_Genre (
    appid INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (appid, genre_id),
    FOREIGN KEY (appid) REFERENCES Game(appid),
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);

-- 11. GAME_CATEGORY
CREATE TABLE Game_Category (
    appid INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (appid, category_id),
    FOREIGN KEY (appid) REFERENCES Game(appid),
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- 12. GAME_PLATFORM
CREATE TABLE Game_Platform (
    appid INT NOT NULL,
    platform_id INT NOT NULL,
    PRIMARY KEY (appid, platform_id),
    FOREIGN KEY (appid) REFERENCES Game(appid),
    FOREIGN KEY (platform_id) REFERENCES Platform(platform_id)
);
-- 13. USER_GAME
CREATE TABLE User_Game (
    user_id BIGINT NOT NULL,
    appid INT NOT NULL,
    playtime_forever INT DEFAULT 0,
    playtime_2weeks INT DEFAULT 0,
    last_played DATETIME,
    ownership_status VARCHAR(30) DEFAULT 'owned',

    PRIMARY KEY (user_id, appid),

    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (appid) REFERENCES Game(appid),

    CHECK (playtime_forever >= 0),
    CHECK (playtime_2weeks >= 0),
    CHECK (
        ownership_status IN
        ('owned', 'borrowed', 'wishlist', 'removed')
    )
);

-- 14. ACHIEVEMENT
CREATE TABLE Achievement (
    achievement_id INT AUTO_INCREMENT PRIMARY KEY,
    appid INT NOT NULL,
    achievement_name VARCHAR(200) NOT NULL,
    description TEXT,
    points INT DEFAULT 0,
    hidden BOOLEAN DEFAULT FALSE,

    FOREIGN KEY (appid) REFERENCES Game(appid),
    UNIQUE (appid, achievement_name),
    CHECK (points >= 0)
);

-- 15. USER_ACHIEVEMENT
CREATE TABLE User_Achievement (
    user_id BIGINT NOT NULL,
    achievement_id INT NOT NULL,
    is_unlocked BOOLEAN DEFAULT FALSE,
    unlock_time DATETIME,

    PRIMARY KEY (user_id, achievement_id),

    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (achievement_id)
        REFERENCES Achievement(achievement_id)
);
-- 16. REVIEW
CREATE TABLE Review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    appid INT NOT NULL,
    review_text TEXT,
    recommended BOOLEAN NOT NULL,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    playtime_at_review INT DEFAULT 0,

    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (appid) REFERENCES Game(appid),

    CHECK (playtime_at_review >= 0)
);

-- 17. GAMING_SESSION
CREATE TABLE Gaming_Session (
    session_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    appid INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    duration INT,

    FOREIGN KEY (user_id) REFERENCES User(user_id),
    FOREIGN KEY (appid) REFERENCES Game(appid),

    CHECK (duration IS NULL OR duration >= 0),
    CHECK (end_time IS NULL OR end_time >= start_time)
);