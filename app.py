from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
import hashlib
import os
import re
from functools import wraps

app = Flask(__name__)

# ============================================================
# SECURE CONFIGURATION
# ============================================================
# SECRET KEY: Use a strong random key (never hardcode in production)
app.secret_key = os.environ.get('SECRET_KEY', os.urandom(32))

# Secure session cookie settings
app.config['SESSION_COOKIE_HTTPONLY'] = True   # JS cannot access the cookie
app.config['SESSION_COOKIE_SAMESITE'] = 'Lax'  # CSRF protection
# app.config['SESSION_COOKIE_SECURE'] = True    # Uncomment when using HTTPS

db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'movie_rec_system'
}

# ============================================================
# PASSWORD SECURITY UTILITIES
# ============================================================

def hash_password(password: str) -> str:
    """
    Hash a password using SHA-256 with a random salt.
    Returns: 'salt$hashed_password' as a single string to store in DB.
    """
    salt = os.urandom(16).hex()                        # 16-byte random salt
    hashed = hashlib.sha256((salt + password).encode()).hexdigest()
    return f"{salt}${hashed}"


def verify_password(password: str, stored: str) -> bool:
    """
    Verify a plain-text password against a stored 'salt$hash' string.
    """
    try:
        salt, hashed = stored.split('$', 1)
        return hashlib.sha256((salt + password).encode()).hexdigest() == hashed
    except Exception:
        return False


def validate_password(password: str) -> list[str]:
    """
    Enforce password policy. Returns a list of error messages.
    An empty list means the password is valid.

    Rules:
      - At least 8 characters long
      - At least one uppercase letter
      - At least one lowercase letter
      - At least one digit (0–9)
      - At least one special character (!@#$%^&*...)
      - At least 5 UNIQUE characters
    """
    errors = []

    if len(password) < 8:
        errors.append("Password must be at least 8 characters long.")

    if not re.search(r'[A-Z]', password):
        errors.append("Password must contain at least one uppercase letter.")

    if not re.search(r'[a-z]', password):
        errors.append("Password must contain at least one lowercase letter.")

    if not re.search(r'\d', password):
        errors.append("Password must contain at least one number (0–9).")

    if not re.search(r'[!@#$%^&*()\-_=+\[\]{};:\'",.<>?/\\|`~]', password):
        errors.append("Password must contain at least one special character (e.g. !@#$%).")

    unique_chars = set(password)
    if len(unique_chars) < 5:
        errors.append("Password must contain at least 5 unique characters.")

    return errors


def sanitize_input(value: str, max_length: int = 255) -> str:
    """Basic input sanitization: strip whitespace and limit length."""
    return str(value).strip()[:max_length]

# ============================================================
# DATABASE HELPER
# ============================================================

def get_db_connection():
    return mysql.connector.connect(**db_config)

# ============================================================
# DECORATORS
# ============================================================

def login_required(f):
    """Redirect to login if the user is not authenticated."""
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user_id' not in session:
            flash('Please login to continue.', 'danger')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated


def admin_required(f):
    """Redirect to admin login if the session has no admin flag."""
    @wraps(f)
    def decorated(*args, **kwargs):
        if not session.get('is_admin'):
            return redirect(url_for('admin_login'))
        return f(*args, **kwargs)
    return decorated

# ============================================================
# ROUTES
# ============================================================

@app.route('/')
def home():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Movies ORDER BY ReleaseYear DESC")
    movies = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('home.html', movies=movies)


@app.route('/movie/<int:movie_id>', methods=['GET', 'POST'])
def movie_details(movie_id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        if 'user_id' not in session:
            flash('Please login to rate.', 'danger')
            return redirect(url_for('login'))

        # Validate rating range
        try:
            rating = int(request.form.get('rating', 0))
            if not (1 <= rating <= 10):
                flash('Rating must be between 1 and 10.', 'warning')
                return redirect(url_for('movie_details', movie_id=movie_id))
        except ValueError:
            flash('Invalid rating value.', 'danger')
            return redirect(url_for('movie_details', movie_id=movie_id))

        review = sanitize_input(request.form.get('review', ''), max_length=1000)
        user_id = session['user_id']

        try:
            # Parameterized query — safe from SQL injection
            cursor.execute(
                "INSERT INTO Ratings (UserID, MovieID, RatingValue, Review) VALUES (%s, %s, %s, %s)",
                (user_id, movie_id, rating, review)
            )
            conn.commit()
            flash('Review submitted!', 'success')
            return redirect(url_for('movie_details', movie_id=movie_id))
        except mysql.connector.IntegrityError:
            flash('You have already reviewed this movie.', 'warning')
        except mysql.connector.Error:
            flash('An error occurred. Please try again.', 'danger')

    # Parameterized queries throughout — safe from SQL injection
    cursor.execute("SELECT * FROM Movies WHERE MovieID = %s", (movie_id,))
    movie = cursor.fetchone()

    if not movie:
        flash('Movie not found.', 'danger')
        return redirect(url_for('home'))

    cursor.execute("""
        SELECT r.RatingValue AS rating, r.Review AS review_text,
               r.ReviewDate AS date, u.Name AS user_name
        FROM Ratings r JOIN Users u ON r.UserID = u.UserID
        WHERE r.MovieID = %s ORDER BY r.ReviewDate DESC
    """, (movie_id,))
    reviews = cursor.fetchall()

    cursor.execute("""
        SELECT DISTINCT m.* FROM Movies m
        JOIN MovieGenres mg ON m.MovieID = mg.MovieID
        WHERE mg.GenreID IN (SELECT GenreID FROM MovieGenres WHERE MovieID = %s)
        AND m.MovieID != %s ORDER BY RAND() LIMIT 4
    """, (movie_id, movie_id))
    recommendations = cursor.fetchall()

    cursor.close()
    conn.close()
    return render_template('movie_details.html', movie=movie, reviews=reviews, recommendations=recommendations)


@app.route('/watchlist')
@login_required
def watchlist():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT w.WatchlistID, m.* FROM Watchlists w
        JOIN Movies m ON w.MovieID = m.MovieID
        WHERE w.UserID = %s
        ORDER BY w.DateAdded DESC
    """, (session['user_id'],))
    saved_movies = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('watchlist.html', movies=saved_movies)


@app.route('/add_to_watchlist/<int:movie_id>')
@login_required
def add_to_watchlist(movie_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        "SELECT * FROM Watchlists WHERE UserID = %s AND MovieID = %s",
        (session['user_id'], movie_id)
    )
    if cursor.fetchone():
        flash('This movie is already in your Watchlist!', 'warning')
    else:
        cursor.execute(
            "INSERT INTO Watchlists (UserID, MovieID) VALUES (%s, %s)",
            (session['user_id'], movie_id)
        )
        conn.commit()
        flash('Added to Watchlist!', 'success')

    cursor.close()
    conn.close()
    return redirect(url_for('movie_details', movie_id=movie_id))


@app.route('/remove_watchlist/<int:watchlist_id>')
@login_required
def remove_watchlist(watchlist_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    # SECURITY FIX: Verify the watchlist entry belongs to the logged-in user
    # (prevents one user deleting another user's watchlist items)
    cursor.execute(
        "DELETE FROM Watchlists WHERE WatchlistID = %s AND UserID = %s",
        (watchlist_id, session['user_id'])
    )
    conn.commit()
    cursor.close()
    conn.close()
    flash('Movie removed from watchlist.', 'info')
    return redirect(url_for('watchlist'))


@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    if request.method == 'POST':
        email    = sanitize_input(request.form.get('email', ''))
        password = request.form.get('password', '')

        conn   = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # SECURITY FIX: Fetch by email only, then verify password hash
        # (never compare plaintext passwords in SQL)
        cursor.execute("SELECT * FROM Admins WHERE Email = %s", (email,))
        admin = cursor.fetchone()
        cursor.close()
        conn.close()

        if admin and verify_password(password, admin['Password']):
            session['is_admin']   = True
            session['admin_name'] = admin['Name']
            return redirect(url_for('add_movie'))
        else:
            flash('Invalid Admin Credentials.', 'danger')

    return render_template('admin_login.html')


@app.route('/admin/add_movie', methods=['GET', 'POST'])
@admin_required
def add_movie():
    conn   = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        title    = sanitize_input(request.form.get('title', ''))
        desc     = sanitize_input(request.form.get('description', ''), max_length=2000)
        poster   = sanitize_input(request.form.get('poster', ''))
        genre_id = request.form.get('genre_id')

        # Validate year is a real integer
        try:
            year = int(request.form.get('year', 0))
            if not (1888 <= year <= 2100):
                raise ValueError
        except ValueError:
            flash('Please enter a valid release year.', 'danger')
            cursor.execute("SELECT * FROM Genres")
            genres = cursor.fetchall()
            return render_template('add_movie.html', genres=genres)

        if not title:
            flash('Movie title is required.', 'danger')
        else:
            cursor.execute(
                "INSERT INTO Movies (Title, Description, ReleaseYear, poster_url) VALUES (%s, %s, %s, %s)",
                (title, desc, year, poster)
            )
            movie_id = cursor.lastrowid
            cursor.execute(
                "INSERT INTO MovieGenres (MovieID, GenreID) VALUES (%s, %s)",
                (movie_id, genre_id)
            )
            conn.commit()
            flash(f'Movie "{title}" added successfully!', 'success')

    cursor.execute("SELECT * FROM Genres")
    genres = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('add_movie.html', genres=genres)


@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name     = sanitize_input(request.form.get('name', ''))
        email    = sanitize_input(request.form.get('email', '').lower())
        password = request.form.get('password', '')

        # --- SECURE CODING: Validate email format ---
        if not re.match(r'^[\w.\-+]+@[\w\-]+\.[a-zA-Z]{2,}$', email):
            flash('Please enter a valid email address.', 'danger')
            return render_template('register.html')

        # --- SECURE CODING: Enforce password policy ---
        errors = validate_password(password)
        if errors:
            for err in errors:
                flash(err, 'danger')
            return render_template('register.html')

        # --- SECURE CODING: Hash password before storing ---
        hashed_password = hash_password(password)

        conn   = get_db_connection()
        cursor = conn.cursor()
        try:
            cursor.execute(
                "INSERT INTO Users (Name, Email, Password) VALUES (%s, %s, %s)",
                (name, email, hashed_password)
            )
            conn.commit()
            flash('Registered successfully! Please login.', 'success')
            return redirect(url_for('login'))
        except mysql.connector.IntegrityError:
            flash('An account with this email already exists.', 'danger')
        except mysql.connector.Error:
            flash('Registration failed. Please try again.', 'danger')
        finally:
            cursor.close()
            conn.close()

    return render_template('register.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email    = sanitize_input(request.form.get('email', '').lower())
        password = request.form.get('password', '')

        conn   = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # SECURITY FIX: Fetch by email only, verify hash separately
        # (avoids timing attacks and plaintext password comparison in SQL)
        cursor.execute("SELECT * FROM Users WHERE Email = %s", (email,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user and verify_password(password, user['Password']):
            session['user_id']   = user['UserID']
            session['user_name'] = user['Name']
            return redirect(url_for('home'))
        else:
            # Generic message — do NOT reveal whether email exists
            flash('Invalid email or password.', 'danger')

    return render_template('login.html')


@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('home'))


if __name__ == '__main__':
    # SECURITY: Never run debug=True in production
    app.run(debug=False)