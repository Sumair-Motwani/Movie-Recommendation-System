import random
from math import gcd

# Public key from Authority (fixed for lab)
n = 3233
e = 17

# Original message
m = 123

# Choose random r such that gcd(r, n) = 1
while True:
    r = random.randint(2, n-1)
    if gcd(r, n) == 1:
        break

# Blind message
m_blinded = (m * pow(r, e, n)) % n

print("Original Message:", m)
print("Blinding factor r:", r)
print("Blinded Message:", m_blinded)

# Save values for later
with open("user_data.txt", "w") as f:
    f.write(f"{m},{r},{m_blinded}")