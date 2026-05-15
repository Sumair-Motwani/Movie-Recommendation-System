import binascii

data = '{"text":"899"}'  

hex_data = binascii.hexlify(data.encode()).decode()

print(hex_data)