import requests
import json
import os

BASE_URL = "http://127.0.0.1:8000/api/v1"

def test_flow():
    phone = "+19998887778"
    
    res = requests.post(f"{BASE_URL}/auth/request-otp", json={"phone_number": phone})
    dev_otp = res.json().get("dev_otp")
    
    res = requests.post(f"{BASE_URL}/auth/verify-otp", json={"phone_number": phone, "otp": dev_otp})
    tokens = res.json()
    access_token = tokens["access_token"]
    
    headers = {"Authorization": f"Bearer {access_token}"}
    res = requests.get(f"{BASE_URL}/auth/me", headers=headers)
    print("User payload:", res.json())

if __name__ == '__main__':
    test_flow()
