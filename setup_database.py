import mysql.connector

# --- CONFIGURATION ---
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '',  # Leave empty for XAMPP
    'database': 'movie_rec_system'
}

def create_tables(cursor):
    print("... Creating tables if they don't exist")

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Users (
            UserID    INT AUTO_INCREMENT PRIMARY KEY,
            Name      VARCHAR(100) NOT NULL,
            Email     VARCHAR(150) NOT NULL UNIQUE,
            Password  VARCHAR(255) NOT NULL
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Admins (
            AdminID   INT AUTO_INCREMENT PRIMARY KEY,
            Name      VARCHAR(100) NOT NULL,
            Email     VARCHAR(150) NOT NULL UNIQUE,
            Password  VARCHAR(255) NOT NULL
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Genres (
            GenreID   INT AUTO_INCREMENT PRIMARY KEY,
            GenreName VARCHAR(50) NOT NULL UNIQUE
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Movies (
            MovieID     INT AUTO_INCREMENT PRIMARY KEY,
            Title       VARCHAR(200) NOT NULL,
            Description TEXT,
            ReleaseYear INT,
            poster_url  VARCHAR(500)
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS MovieGenres (
            MovieID  INT NOT NULL,
            GenreID  INT NOT NULL,
            PRIMARY KEY (MovieID, GenreID),
            FOREIGN KEY (MovieID) REFERENCES Movies(MovieID) ON DELETE CASCADE,
            FOREIGN KEY (GenreID) REFERENCES Genres(GenreID) ON DELETE CASCADE
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Ratings (
            RatingID    INT AUTO_INCREMENT PRIMARY KEY,
            UserID      INT NOT NULL,
            MovieID     INT NOT NULL,
            RatingValue INT CHECK (RatingValue BETWEEN 1 AND 10),
            Review      TEXT,
            ReviewDate  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY unique_review (UserID, MovieID),
            FOREIGN KEY (UserID)  REFERENCES Users(UserID)  ON DELETE CASCADE,
            FOREIGN KEY (MovieID) REFERENCES Movies(MovieID) ON DELETE CASCADE
        )
    """)

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Watchlists (
            WatchlistID INT AUTO_INCREMENT PRIMARY KEY,
            UserID      INT NOT NULL,
            MovieID     INT NOT NULL,
            DateAdded   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY unique_watchlist (UserID, MovieID),
            FOREIGN KEY (UserID)  REFERENCES Users(UserID)  ON DELETE CASCADE,
            FOREIGN KEY (MovieID) REFERENCES Movies(MovieID) ON DELETE CASCADE
        )
    """)

    print("✅ All tables ready!")


def populate_data():
    try:
        conn   = mysql.connector.connect(**db_config)
        cursor = conn.cursor()
        print("✅ Connected to database successfully!")

        # Step 1: Create tables
        create_tables(cursor)
        conn.commit()

        # Step 2: Insert Genres
        genres = ['Action', 'Sci-Fi', 'Drama', 'Comedy', 'Horror', 'Romance']
        print("... Inserting Genres")
        for g in genres:
            try:
                cursor.execute("INSERT INTO Genres (GenreName) VALUES (%s)", (g,))
            except mysql.connector.Error:
                pass  # Already exists, skip

        # Step 3: Insert Movies
        movies = [
            ("Inception",         "A thief who steals corporate secrets through dream-sharing technology.",                                                                                   2010, "https://image.tmdb.org/t/p/w500/9gk7admal4zl1h5c42825687.jpg"),
            ("Interstellar",      "A team of explorers travel through a wormhole in space.",                                                                                                  2014, "https://image.tmdb.org/t/p/w500/gEU2QniL6E77NI6lCU6MxlNBvIx.jpg"),
            ("The Dark Knight",   "Batman raises the stakes in his war on crime.",                                                                                                            2008, "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg"),
            ("Avengers: Endgame", "After the devastating events of Infinity War, the universe is in ruins.",                                                                                  2019, "https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg"),
            ("Parasite",          "Greed and class discrimination threaten the relationship between the Park family and the Kim clan.",                                                        2019, "https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg"),
            ("The Hangover",      "Three buddies wake up from a bachelor party in Las Vegas with no memory of the previous night.",                                                            2009, "https://image.tmdb.org/t/p/w500/ulNghV0zb40XgGZ00C16l6n945y.jpg"),
            ("Superbad",          "Two co-dependent high school seniors deal with separation as they go off to college.",                                                                      2007, "https://image.tmdb.org/t/p/w500/ek8e8txUyUwd2BNqj6lFEerJfbq.jpg"),
            ("The Conjuring",     "Paranormal investigators help a family terrorized by a dark presence in their farmhouse.",                                                                  2013, "https://image.tmdb.org/t/p/w500/wVYREutTvI2tmxr6rz00CIV0rPR.jpg"),
            ("It",                "In 1989, a group of bullied kids band together to destroy a shape-shifting monster.",                                                                       2017, "https://image.tmdb.org/t/p/w500/9E2y5Q7WlCVNEhP5GiVTJhEhx1o.jpg"),
            ("Titanic",           "A young aristocrat falls in love with a poor artist aboard the ill-fated R.M.S. Titanic.",                                                                 1997, "https://image.tmdb.org/t/p/w500/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg"),
            ("The Notebook",      "A passionate young man falls in love with a rich young woman, giving her a sense of freedom.",                                                             2004, "https://image.tmdb.org/t/p/w500/rNzQy5GMpenMJkc54yYahYY1OST.jpg"),
            ("Gladiator",         "A former Roman General seeks vengeance against the corrupt emperor who murdered his family.",                                                               2000, "https://image.tmdb.org/t/p/w500/ty8TGRuvJLPUmAR1H1nRIsgwvim.jpg"),
            ("Joker",             "A failed stand-up comedian is driven insane and turns to a life of crime and chaos.",                                                                       2019, "https://image.tmdb.org/t/p/w500/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg"),
            ("La La Land",        "A pianist and an actress fall in love while navigating their careers in Los Angeles.",                                                                     2016, "https://image.tmdb.org/t/p/w500/uDO8zWDhfWzEXp54PkkkBenxSOA.jpg"),
            ("Get Out",           "A young man visits his girlfriend's parents for the weekend, where his uneasiness reaches a boiling point.",                                               2017, "https://image.tmdb.org/t/p/w500/tFXcEccSQMf3lfhfXKSU9iRBpa3.jpg"),
        ]

        print("... Inserting Movies")
        for m in movies:
            cursor.execute("SELECT MovieID FROM Movies WHERE Title = %s", (m[0],))
            if not cursor.fetchone():
                cursor.execute(
                    "INSERT INTO Movies (Title, Description, ReleaseYear, poster_url) VALUES (%s, %s, %s, %s)", m
                )
                print(f"   + Added: {m[0]}")
            else:
                print(f"   - Skipped: {m[0]} (already exists)")

        # Step 4: Link Movies to Genres
        movie_genres = {
            "Inception":         ["Action", "Sci-Fi"],
            "Interstellar":      ["Sci-Fi", "Drama"],
            "The Dark Knight":   ["Action", "Drama"],
            "Avengers: Endgame": ["Action", "Sci-Fi"],
            "Parasite":          ["Drama", "Comedy"],
            "The Hangover":      ["Comedy"],
            "Superbad":          ["Comedy"],
            "The Conjuring":     ["Horror"],
            "It":                ["Horror"],
            "Titanic":           ["Romance", "Drama"],
            "The Notebook":      ["Romance", "Drama"],
            "Gladiator":         ["Action", "Drama"],
            "Joker":             ["Drama"],
            "La La Land":        ["Romance", "Drama"],
            "Get Out":           ["Horror", "Drama"],
        }

        print("... Linking Movies to Genres")
        for movie_title, genre_list in movie_genres.items():
            cursor.execute("SELECT MovieID FROM Movies WHERE Title = %s", (movie_title,))
            m_row = cursor.fetchone()
            if not m_row:
                continue
            m_id = m_row[0]

            for g_name in genre_list:
                cursor.execute("SELECT GenreID FROM Genres WHERE GenreName = %s", (g_name,))
                g_row = cursor.fetchone()
                if not g_row:
                    continue
                g_id = g_row[0]
                try:
                    cursor.execute(
                        "INSERT INTO MovieGenres (MovieID, GenreID) VALUES (%s, %s)", (m_id, g_id)
                    )
                except mysql.connector.Error:
                    pass  # Already linked, skip

        conn.commit()
        print("✅ Data population complete!")

    except mysql.connector.Error as err:
        print(f"❌ Error: {err}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()


if __name__ == "__main__":
    populate_data()