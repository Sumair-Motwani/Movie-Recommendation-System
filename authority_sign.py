# Private key
d = 2753
n = 3233

# Input from stream
m_blinded = int(input("Enter blinded message: "))

# Sign it
s_blinded = pow(m_blinded, d, n)

print("Blinded Signature:", s_blinded)