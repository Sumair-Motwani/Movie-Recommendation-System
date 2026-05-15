-- ==========================================
-- STEP 1: RESET & SCHEMA CREATION
-- ==========================================
DROP DATABASE IF EXISTS movie_rec_system;
CREATE DATABASE movie_rec_system;
USE movie_rec_system;

-- 1. Users Table
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Preferences TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Admins Table
CREATE TABLE Admins (
    AdminID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL
);

-- 3. Genres Table
CREATE TABLE Genres (
    GenreID INT AUTO_INCREMENT PRIMARY KEY,
    GenreName VARCHAR(50) UNIQUE NOT NULL
);

-- 4. Movies Table
CREATE TABLE Movies (
    MovieID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Description TEXT,
    ReleaseYear INT,
    poster_url VARCHAR(255)
);

-- 5. MovieGenres Table (Bridge Table)
CREATE TABLE MovieGenres (
    MovieGenreID INT AUTO_INCREMENT PRIMARY KEY,
    MovieID INT NOT NULL,
    GenreID INT NOT NULL,
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID) ON DELETE CASCADE,
    FOREIGN KEY (GenreID) REFERENCES Genres(GenreID) ON DELETE CASCADE
);

-- 6. Ratings Table
CREATE TABLE Ratings (
    RatingID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    MovieID INT NOT NULL,
    RatingValue DECIMAL(2, 1) NOT NULL,
    Review TEXT,
    ReviewDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID) ON DELETE CASCADE
);

-- 7. Watchlists Table
CREATE TABLE Watchlists (
    WatchlistID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    MovieID INT NOT NULL,
    DateAdded TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID) ON DELETE CASCADE
);

-- 8. RecommendationHistory Table
CREATE TABLE RecommendationHistory (
    HistoryID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    MovieID INT NOT NULL,
    DateRecommended TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (MovieID) REFERENCES Movies(MovieID) ON DELETE CASCADE
);

-- ==========================================
-- STEP 2: INSERT ADMIN & GENRES
-- ==========================================

-- Insert Admin (Email: admin@test.com, Pass: admin123)
INSERT INTO Admins (Name, Email, Password) VALUES ('Super Admin', 'admin@sumair.com', 'admin123');

-- Insert Genres
INSERT INTO Genres (GenreName) VALUES 
('Action'), ('Sci-Fi'), ('Drama'), ('Comedy'), ('Horror'), 
('Romance'), ('Animation'), ('Thriller'), ('Adventure'), ('Crime');

-- ==========================================
-- STEP 3: INSERT 70 MOVIES
-- ==========================================

INSERT INTO Movies (Title, Description, ReleaseYear, poster_url) VALUES 
-- ACTION / SCI-FI / ADVENTURE
('Inception', 'A thief who steals corporate secrets through the use of dream-sharing technology.', 2010, 'https://image.tmdb.org/t/p/w500/9gk7admal4zl1h5c42825687.jpg'),
('The Dark Knight', 'Batman raises the stakes in his war on crime.', 2008, 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg'),
('Interstellar', 'A team of explorers travel through a wormhole in space.', 2014, 'https://image.tmdb.org/t/p/w500/gEU2QniL6E77NI6lCU6MxlNBvIx.jpg'),
('Avengers: Endgame', 'After the devastating events of Infinity War, the universe is in ruins.', 2019, 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg'),
('Avatar', 'A paraplegic Marine dispatched to the moon Pandora on a unique mission.', 2009, 'https://image.tmdb.org/t/p/w500/6EiRUJzFC98kpgiXl1JSPzUTlxd.jpg'),
('The Matrix', 'A computer hacker learns from mysterious rebels about the true nature of his reality.', 1999, 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg'),
('Gladiator', 'A former Roman General sets out to exact vengeance against the corrupt emperor.', 2000, 'https://image.tmdb.org/t/p/w500/ty8TGRuvJLPUmAR1H1nRIsgwvim.jpg'),
('Mad Max: Fury Road', 'In a post-apocalyptic wasteland, a woman rebels against a tyrannical ruler.', 2015, 'https://image.tmdb.org/t/p/w500/8tZYtuWezp8JbcsvHYO0O46tFbo.jpg'),
('Dune', 'Paul Atreides must travel to the most dangerous planet in the universe.', 2021, 'https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg'),
('Top Gun: Maverick', 'After thirty years, Maverick is still pushing the envelope as a top naval aviator.', 2022, 'https://image.tmdb.org/t/p/w500/62HCnUTziyWcpDaBO2i1DX17ljH.jpg'),
('Black Panther', 'TChalla, heir to the hidden but advanced kingdom of Wakanda, must step forward.', 2018, 'https://image.tmdb.org/t/p/w500/uxzzxijgPIY7slzFvMotPv8wjKA.jpg'),
('Spider-Man: No Way Home', 'Peter Parker seeks Doctor Stranges help to make people forget his identity.', 2021, 'https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg'),
('Iron Man', 'After being held captive in an Afghan cave, billionaire engineer Tony Stark creates a unique weaponized suit of armor to fight evil.', 2008, 'https://image.tmdb.org/t/p/w500/78lPtwv72eTNqFW9COBYI0dWDJa.jpg'),
('Logan', 'In a near future, a weary Logan cares for an ailing Professor X in a hide out on the Mexican border.', 2017, 'https://image.tmdb.org/t/p/w500/fnbjc3lwFSPodNoDckemr06t4.jpg'),
('Jurassic Park', 'A pragmatic paleontologist touring an almost complete theme park on an island in Central America is tasked with protecting a couple of kids after a power failure causes the parks cloned dinosaurs to run loose.', 1993, 'https://image.tmdb.org/t/p/w500/9i3plLl89DHMz7mahksDaAo7HIS.jpg'),

-- DRAMA / CRIME
('The Godfather', 'The aging patriarch of an organized crime dynasty transfers control to his reluctant son.', 1972, 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg'),
('Pulp Fiction', 'The lives of two mob hitmen, a boxer, and a pair of diner bandits intertwine.', 1994, 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg'),
('The Shawshank Redemption', 'Two imprisoned men bond over a number of years, finding solace and eventual redemption.', 1994, 'https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg'),
('Fight Club', 'An insomniac office worker and a devil-may-care soapmaker form an underground fight club.', 1999, 'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg'),
('Forrest Gump', 'The presidencies of Kennedy and Johnson, the Vietnam War, and other events unfold through the perspective of an Alabama man.', 1994, 'https://image.tmdb.org/t/p/w500/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg'),
('Joker', 'During the 1980s, a failed stand-up comedian is driven insane and turns to a life of crime.', 2019, 'https://image.tmdb.org/t/p/w500/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg'),
('Parasite', 'Greed and class discrimination threaten the relationship between the Park family and the Kim clan.', 2019, 'https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg'),
('Goodfellas', 'The story of Henry Hill and his life in the mob, covering his relationship with his wife and his partners in crime.', 1990, 'https://image.tmdb.org/t/p/w500/aKuFiU82s5ISJpGZp7YkIr3kCUd.jpg'),
('Scarface', 'In 1980 Miami, a determined Cuban immigrant takes over a drug cartel and succumbs to greed.', 1983, 'https://image.tmdb.org/t/p/w500/7pEe538G2skQ6rR3ccaqMecl0wB.jpg'),
('Breaking Bad: El Camino', 'Fugitive Jesse Pinkman runs from his captors, the law, and his past.', 2019, 'https://image.tmdb.org/t/p/w500/ePXuKdXZuJx8hHMNr2yM4jY2L7Z.jpg'),
('The Wolf of Wall Street', 'Based on the true story of Jordan Belfort, from his rise to a wealthy stock-broker to his fall involving crime.', 2013, 'https://image.tmdb.org/t/p/w500/pWHf4khOloNVfCxscsXFGH3jjg6.jpg'),
('Whiplash', 'A promising young drummer enrolls at a cut-throat music conservatory where his dreams of greatness are mentored by an instructor who will stop at nothing to realize a students potential.', 2014, 'https://image.tmdb.org/t/p/w500/6uSPcdGNA2A6vJmCag50lwudS6s.jpg'),

-- HORROR / THRILLER
('The Conjuring', 'Paranormal investigators work to help a family terrorized by a dark presence.', 2013, 'https://image.tmdb.org/t/p/w500/wVYREutTvI2tmxr6rz00CIV0rPR.jpg'),
('It', 'In the summer of 1989, a group of bullied kids band together to destroy a shape-shifting monster.', 2017, 'https://image.tmdb.org/t/p/w500/9E2y5Q7WlCVNEhP5GiVTJhEhx1o.jpg'),
('Get Out', 'A young African-American visits his white girlfriends parents and uncovers a dark secret.', 2017, 'https://image.tmdb.org/t/p/w500/tFXcEccSQMf3lfhfXKSU9iRBpa3.jpg'),
('A Quiet Place', 'In a post-apocalyptic world, a family is forced to live in silence while hiding from monsters with ultra-sensitive hearing.', 2018, 'https://image.tmdb.org/t/p/w500/nJDqeD2nB16l2d85uM0x90K014.jpg'),
('Hereditary', 'After the family matriarch passes away, a grieving family is haunted by tragic and disturbing occurrences.', 2018, 'https://image.tmdb.org/t/p/w500/p9fopC3CqS5932yKzVp4j1414.jpg'),
('The Shining', 'A family heads to an isolated hotel for the winter where a sinister presence influences the father into violence.', 1980, 'https://image.tmdb.org/t/p/w500/b4gYVcl8pParX8AjkN6023.jpg'),
('Psycho', 'A Phoenix secretary embezzles $40,000 from her employers client, goes on the run, and checks into a remote motel run by a young man under the domination of his mother.', 1960, 'https://image.tmdb.org/t/p/w500/81d8oyEFgjHmX0p1M4f0n0f13.jpg'),
('Us', 'A familys serene beach vacation turns to chaos when their doppelgängers appear and begin to terrorize them.', 2019, 'https://image.tmdb.org/t/p/w500/ux2dU8j92vp4TCTlE2D3j1414.jpg'),
('Halloween', 'Laurie Strode confronts her long-time foe Michael Myers, the masked figure who has haunted her since she narrowly escaped his killing spree on Halloween night four decades ago.', 2018, 'https://image.tmdb.org/t/p/w500/bBd1737141414.jpg'),
('Saw', 'Two strangers awaken in a room with no recollection of how they got there, and soon discover they are pawns in a deadly game.', 2004, 'https://image.tmdb.org/t/p/w500/d8d1414141414.jpg'),

-- COMEDY
('The Hangover', 'Three buddies wake up from a bachelor party in Las Vegas, with no memory of the previous night.', 2009, 'https://image.tmdb.org/t/p/w500/ulNghV0zb40XgGZ00C16l6n945y.jpg'),
('Superbad', 'Two co-dependent high school seniors are forced to deal with separation as they go off to college.', 2007, 'https://image.tmdb.org/t/p/w500/ek8e8txUyUwd2BNqj6lFEerJfbq.jpg'),
('Deadpool', 'A wisecracking mercenary gets experimented on and becomes immortal but ugly.', 2016, 'https://image.tmdb.org/t/p/w500/fSRb7vyIP8rQpL0I47P3qUsEKX3.jpg'),
('Step Brothers', 'Two middle-aged, lazy men are forced to live together when their parents marry.', 2008, 'https://image.tmdb.org/t/p/w500/rX14141414.jpg'),
('Mean Girls', 'Cady Heron is a hit with The Plastics, the A-list girl clique at her new school.', 2004, 'https://image.tmdb.org/t/p/w500/fX14141414.jpg'),
('Dumb and Dumber', 'The cross-country adventures of two good-hearted but incredibly stupid friends.', 1994, 'https://image.tmdb.org/t/p/w500/4L14141414.jpg'),
('Anchorman', 'Ron Burgundy is San Diegos top-rated newsman in the male-dominated broadcasting of the 1970s.', 2004, 'https://image.tmdb.org/t/p/w500/a14141414.jpg'),
('The Grand Budapest Hotel', 'A writer encounters the owner of an aging high-class hotel, who tells him of his early years serving as a lobby boy in the hotels glorious years under an exceptional concierge.', 2014, 'https://image.tmdb.org/t/p/w500/eWdyYQreja6JGCzqHWXpGlKzgMz.jpg'),
('Knives Out', 'A detective investigates the death of a patriarch of an eccentric, combative family.', 2019, 'https://image.tmdb.org/t/p/w500/pThyQovXQrw2m0s9x82twj48lq.jpg'),
('Free Guy', 'A bank teller discovers that he is actually a background player in an open-world video game.', 2021, 'https://image.tmdb.org/t/p/w500/xmbU4XBJasKy8yjiLFhRQub6y.jpg'),

-- ROMANCE
('Titanic', 'A seventeen-year-old aristocrat falls in love with a kind but poor artist.', 1997, 'https://image.tmdb.org/t/p/w500/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg'),
('The Notebook', 'A poor yet passionate young man falls in love with a rich young woman.', 2004, 'https://image.tmdb.org/t/p/w500/rNzQy5GMpenMJkc54yYahYY1OST.jpg'),
('La La Land', 'A pianist and an actress fall in love while attempting to reconcile their aspirations.', 2016, 'https://image.tmdb.org/t/p/w500/uDO8zWDhfWzEXp54PkkkBenxSOA.jpg'),
('Pride & Prejudice', 'Sparks fly when spirited Elizabeth Bennet meets single, rich, and proud Mr. Darcy.', 2005, 'https://image.tmdb.org/t/p/w500/zm14141414.jpg'),
('A Star Is Born', 'A musician helps a young singer find fame as age and alcoholism send his own career into a downward spiral.', 2018, 'https://image.tmdb.org/t/p/w500/wrFpXMNBRj2PBiN4Z5kix51XaIZ.jpg'),
('Me Before You', 'A girl in a small town forms an unlikely bond with a recently-paralyzed man she is taking care of.', 2016, 'https://image.tmdb.org/t/p/w500/o14141414.jpg'),
('About Time', 'At the age of 21, Tim discovers he can travel in time and change what happens and has happened in his own life.', 2013, 'https://image.tmdb.org/t/p/w500/i14141414.jpg'),
('Crazy Rich Asians', 'This contemporary romantic comedy based on a global bestseller follows native New Yorker Rachel Chu to Singapore to meet her boyfriends family.', 2018, 'https://image.tmdb.org/t/p/w500/1H14141414.jpg'),
('The Fault in Our Stars', 'Two teenage cancer patients begin a life-affirming journey to visit a reclusive author in Amsterdam.', 2014, 'https://image.tmdb.org/t/p/w500/c14141414.jpg'),
('500 Days of Summer', 'An offbeat romantic comedy about a woman who doesnt believe true love exists, and the young man who falls for her.', 2009, 'https://image.tmdb.org/t/p/w500/f14141414.jpg'),

-- ANIMATION
('The Lion King', 'Lion prince Simba and his father are targeted by his bitter uncle, who wants to ascend the throne himself.', 1994, 'https://image.tmdb.org/t/p/w500/sKCr78MXSLixwmZ8DyJLrpMsd15.jpg'),
('Toy Story', 'A cowboy doll is profoundly threatened and jealous when a new spaceman figure supplants him as top toy in a boys room.', 1995, 'https://image.tmdb.org/t/p/w500/uXDfjJbdP4ijW5hWSBrPrlKpxab.jpg'),
('Spirited Away', 'A sullen ten-year-old girl wanders into a world ruled by gods, witches, and spirits.', 2001, 'https://image.tmdb.org/t/p/w500/39wmItIWsg5sZMyRuqK6cuTL5.jpg'),
('Spider-Man: Into the Spider-Verse', 'Teen Miles Morales becomes the Spider-Man of his universe, and must join with five spider-powered individuals from other dimensions.', 2018, 'https://image.tmdb.org/t/p/w500/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg'),
('Up', '78-year-old Carl Fredricksen travels to Paradise Falls in his house equipped with balloons, inadvertently taking a young stowaway.', 2009, 'https://image.tmdb.org/t/p/w500/vpbaStTMt8qqXaEgnOR2EE4DNJk.jpg'),
('Coco', 'Aspiring musician Miguel, confronted with his familys ancestral ban on music, enters the Land of the Dead to find his great-great-grandfather.', 2017, 'https://image.tmdb.org/t/p/w500/gGEsBPAijhVUFoiNpgZXqRVWJt2.jpg'),
('Inside Out', 'After young Riley is uprooted from her Midwest life and moved to San Francisco, her emotions - Joy, Fear, Anger, Disgust and Sadness - conflict on how best to navigate a new city, house, and school.', 2015, 'https://image.tmdb.org/t/p/w500/lRHE0vzf3oYJrhbsHXjIkF4yWilson.jpg'),
('Shrek', 'A mean lord exiles fairytale creatures to the swamp of a grumpy ogre, who must go on a quest and rescue a princess for the lord in order to get his land back.', 2001, 'https://image.tmdb.org/t/p/w500/dyhaB19AICF7TO7CK2aD6KfYznQ.jpg'),
('Finding Nemo', 'After his son is captured in the Great Barrier Reef and taken to Sydney, a timid clownfish sets out on a journey to bring him home.', 2003, 'https://image.tmdb.org/t/p/w500/ggQ6o8X5F8qLfMs96XpBC.jpg'),
('Ratatouille', 'A rat who can cook makes an unusual alliance with a young kitchen worker at a famous restaurant.', 2007, 'https://image.tmdb.org/t/p/w500/npHNjldbeTHdKKw28bJKs7lzqzj.jpg'),
('Zootopia', 'In a city of anthropomorphic animals, a rookie bunny cop and a cynical con artist fox must work together to uncover a conspiracy.', 2016, 'https://image.tmdb.org/t/p/w500/sM33TURpFW6B7p1414.jpg'),
('Frozen', 'When the newly crowned Queen Elsa accidentally uses her power to turn things into ice to curse her home in infinite winter, her sister Anna teams up with a mountain man, his playful reindeer, and a snowman to change the weather condition.', 2013, 'https://image.tmdb.org/t/p/w500/kgBjGuT141414.jpg'),
('The Incredibles', 'A family of undercover superheroes, while trying to live the quiet suburban life, are forced into action to save the world.', 2004, 'https://image.tmdb.org/t/p/w500/2LqaL141414.jpg'),
('Monsters, Inc.', 'In order to power the city, monsters have to scare children so that they scream. However, the children are toxic to the monsters, and after a child gets through, two monsters realize things may not be what they think.', 2001, 'https://image.tmdb.org/t/p/w500/sghe8j141414.jpg');


-- ==========================================
-- STEP 4: LINK MOVIES TO GENRES
-- ==========================================

-- We link movies by Title to Genres by Name (Many-to-Many)
-- ACTION / SCI-FI / ADVENTURE Group
INSERT INTO MovieGenres (MovieID, GenreID)
SELECT m.MovieID, g.GenreID FROM Movies m, Genres g 
WHERE m.Title IN ('Inception', 'The Dark Knight', 'Interstellar', 'Avengers: Endgame', 'Avatar', 'The Matrix', 'Gladiator', 'Mad Max: Fury Road', 'Dune', 'Top Gun: Maverick', 'Black Panther', 'Spider-Man: No Way Home', 'Iron Man', 'Logan', 'Jurassic Park')
AND g.GenreName IN ('Action', 'Sci-Fi', 'Adventure');

-- DRAMA / CRIME Group
INSERT INTO MovieGenres (MovieID, GenreID)
SELECT m.MovieID, g.GenreID FROM Movies m, Genres g 
WHERE m.Title IN ('The Godfather', 'Pulp Fiction', 'The Shawshank Redemption', 'Fight Club', 'Forrest Gump', 'Joker', 'Parasite', 'Goodfellas', 'Scarface', 'Breaking Bad: El Camino', 'The Wolf of Wall Street', 'Whiplash')
AND g.GenreName IN ('Drama', 'Crime');

-- HORROR / THRILLER Group
INSERT INTO MovieGenres (MovieID, GenreID)
SELECT m.MovieID, g.GenreID FROM Movies m, Genres g 
WHERE m.Title IN ('The Conjuring', 'It', 'Get Out', 'A Quiet Place', 'Hereditary', 'The Shining', 'Psycho', 'Us', 'Halloween', 'Saw')
AND g.GenreName IN ('Horror', 'Thriller');

-- COMEDY Group
INSERT INTO MovieGenres (MovieID, GenreID)
SELECT m.MovieID, g.GenreID FROM Movies m, Genres g 
WHERE m.Title IN ('The Hangover', 'Superbad', 'Deadpool', 'Step Brothers', 'Mean Girls', 'Dumb and Dumber', 'Anchorman', 'The Grand Budapest Hotel', 'Knives Out', 'Free Guy')
AND g.GenreName IN ('Comedy');

-- ROMANCE Group
INSERT INTO MovieGenres (MovieID, GenreID)
SELECT m.MovieID, g.GenreID FROM Movies m, Genres g 
WHERE m.Title IN ('Titanic', 'The Notebook', 'La La Land', 'Pride & Prejudice', 'A Star Is Born', 'Me Before You', 'About Time', 'Crazy Rich Asians', 'The Fault in Our Stars', '500 Days of Summer')
AND g.GenreName IN ('Romance', 'Drama');

-- ANIMATION Group
INSERT INTO MovieGenres (MovieID, GenreID)
SELECT m.MovieID, g.GenreID FROM Movies m, Genres g 
WHERE m.Title IN ('The Lion King', 'Toy Story', 'Spirited Away', 'Spider-Man: Into the Spider-Verse', 'Up', 'Coco', 'Inside Out', 'Shrek', 'Finding Nemo', 'Ratatouille', 'Zootopia', 'Frozen', 'The Incredibles', 'Monsters, Inc.')
AND g.GenreName IN ('Animation', 'Adventure', 'Comedy');