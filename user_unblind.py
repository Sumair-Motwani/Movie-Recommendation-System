from Crypto.Util.number import inverse

# Load saved data
with open("user_data.txt", "r") as f:
    m, r, m_blinded = map(int, f.read().split(","))

n = 3233
e = 17

# Input signed blinded value (HEX)
s_blinded = int(input("Enter signed blinded value (hex): "), 16)

# Unblind
r_inv = inverse(r, n)
s = (s_blinded * r_inv) % n

print("Final Signature:", s)

# Verify
m_verified = pow(s, e, n)

print("Verified Message:", m_verified)

if m_verified == m:
    print("✅ Signature VALID")
else:
    print("❌ Signature INVALID")