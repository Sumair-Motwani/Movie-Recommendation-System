USE movie_rec_system;

-- 1. DISABLE SAFE UPDATE MODE (The Magic Fix)
SET SQL_SAFE_UPDATES = 0;

-- 2. RUN THE FIXES AGAIN
-- Horror
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/bSh1f9qSDoVuaInJHxnWuzx4yAt.jpg' WHERE Title = 'Halloween';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/pparEGTCE56duUIYAPBrZ35qlb.jpg' WHERE Title = 'Saw';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/ux2dU8j92vp4TCTlE2D3j9.jpg' WHERE Title = 'Us';

-- Comedy
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/9G0vW6Q633W8347446.jpg' WHERE Title = 'Mean Girls';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/4LdpB6nw6n9z304iM4.jpg' WHERE Title = 'Dumb and Dumber';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/5x00yQZ3Mcz7k4zO7.jpg' WHERE Title = 'Anchorman';

-- Romance
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/5M7oN3sznp99hETk.jpg' WHERE Title = 'Pride & Prejudice';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/oo2Q3Y8JUJ16.jpg' WHERE Title = 'Me Before You';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/iZf0KyP4GNCPcf.jpg' WHERE Title = 'About Time';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/1H1y94PGN.jpg' WHERE Title = 'Crazy Rich Asians';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/c1BaOXC8bo5ACFYk.jpg' WHERE Title = 'The Fault in Our Stars';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/f9r33d6eO.jpg' WHERE Title = '500 Days of Summer';

-- Animation
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/sM33TURpFW6B7pYe.jpg' WHERE Title = 'Zootopia';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/kgBjGuT2P5MkNO.jpg' WHERE Title = 'Frozen';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/2LqaLgk4Z226K.jpg' WHERE Title = 'The Incredibles';
UPDATE Movies SET poster_url = 'https://image.tmdb.org/t/p/w500/sghe8j1tC2qHa.jpg' WHERE Title = 'Monsters, Inc.';

-- 3. RE-ENABLE SAFE UPDATES (Good Practice)
SET SQL_SAFE_UPDATES = 1;