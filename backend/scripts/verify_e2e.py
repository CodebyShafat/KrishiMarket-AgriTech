import requests
import json
import os
import random

BASE_URL = "http://127.0.0.1:8000/api/v1"

def print_step(msg):
    print(f"\n---> {msg}")

def test_flow():
    phone = f"+1999{random.randint(100000, 999999)}"
    
    print_step("1. Request OTP")
    res = requests.post(f"{BASE_URL}/auth/request-otp", json={"phone_number": phone})
    assert res.status_code == 200
    dev_otp = res.json().get("dev_otp")
    assert dev_otp is not None
    print(f"Got dev_otp: {dev_otp}")
    
    print_step("2. Verify OTP for NEW user")
    res = requests.post(f"{BASE_URL}/auth/verify-otp", json={"phone_number": phone, "otp": dev_otp})
    assert res.status_code == 200, res.text
    tokens = res.json()
    access_token = tokens["access_token"]
    refresh_token = tokens["refresh_token"]
    print("Got tokens!")
    
    print_step("3. Profile / ME (Incomplete profile)")
    headers = {"Authorization": f"Bearer {access_token}"}
    res = requests.get(f"{BASE_URL}/auth/me", headers=headers)
    assert res.status_code == 200
    user = res.json()
    assert user["name"] == ""
    print("User is incomplete as expected.")
    
    print_step("4. Complete Profile via /register (which now updates)")
    res = requests.post(f"{BASE_URL}/auth/register", json={
        "phone_number": phone,
        "name": "Jane Doe",
        "role": "FARMER"
    })
    assert res.status_code == 201
    user = res.json()
    assert user["name"] == "Jane Doe"
    print("Profile updated successfully.")
    
    print_step("5. Profile / ME (Complete profile)")
    res = requests.get(f"{BASE_URL}/auth/me", headers=headers)
    assert res.status_code == 200
    assert res.json()["name"] == "Jane Doe"
    print("Profile is complete.")
    
    print_step("6. Refresh Token Rotation")
    res = requests.post(f"{BASE_URL}/auth/refresh", json={"refresh_token": refresh_token})
    assert res.status_code == 200
    new_tokens = res.json()
    new_access_token = new_tokens["access_token"]
    new_refresh_token = new_tokens["refresh_token"]
    assert new_refresh_token != refresh_token
    print("Tokens rotated.")
    
    print_step("7. Replaying old refresh token should fail")
    res = requests.post(f"{BASE_URL}/auth/refresh", json={"refresh_token": refresh_token})
    assert res.status_code == 401
    print("Old token rejected properly.")
    
    print_step("8. Verify Production Mode denies 123456 logic (implied by OTP generation)")
    # Request OTP with fake
    res = requests.post(f"{BASE_URL}/auth/verify-otp", json={"phone_number": phone, "otp": "123456"})
    assert res.status_code == 401
    print("Fake OTP 123456 rejected.")
    
    print_step("9. Logout")
    res = requests.post(f"{BASE_URL}/auth/logout", json={"refresh_token": new_refresh_token})
    assert res.status_code == 200
    print("Logout successful.")
    
    print_step("10. Attempt refresh after logout")
    res = requests.post(f"{BASE_URL}/auth/refresh", json={"refresh_token": new_refresh_token})
    assert res.status_code == 401
    print("Refresh after logout rejected.")

    print_step("ALL E2E BACKEND TESTS PASSED")

if __name__ == '__main__':
    test_flow()
