import requests

res = requests.post("http://127.0.0.1:8000/api/v1/auth/refresh", json={"refresh_token": "some_dummy_token_to_check_logs_maybe"})
print(res.status_code, res.text)
