import httpx
import json
import random

BASE_URL = 'http://127.0.0.1:8000'

def test_flow():
    f_phone = f'+919999{random.randint(100000, 999999)}'
    r = httpx.post(f'{BASE_URL}/api/v1/auth/request-otp', json={'phone_number': f_phone, 'role': 'farmer'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/verify-otp', json={'phone_number': f_phone, 'otp': '123456'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/register', json={'phone_number': f_phone, 'name': 'Farmer Joe', 'role': 'farmer', 'password': 'test'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/request-otp', json={'phone_number': f_phone, 'role': 'farmer'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/verify-otp', json={'phone_number': f_phone, 'otp': '123456'})
    farmer_token = r.json()['access_token']

    headers_farmer = {'Authorization': f'Bearer {farmer_token}'}
    prod_data = {'title': 'Test Tomato', 'crop': 'Tomato', 'category': 'Vegetable', 'description': 'Fresh', 'quality_grade': 'A', 'price': 50.0, 'unit': 'kg', 'quantity': 100.0, 'location': 'Pune', 'is_available': True}
    r = httpx.post(f'{BASE_URL}/api/v1/products', json=prod_data, headers=headers_farmer)
    product = r.json()
    print('Product Created:', product.get('id', product))

    c_phone = f'+919999{random.randint(100000, 999999)}'
    r = httpx.post(f'{BASE_URL}/api/v1/auth/request-otp', json={'phone_number': c_phone, 'role': 'retail_buyer'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/verify-otp', json={'phone_number': c_phone, 'otp': '123456'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/register', json={'phone_number': c_phone, 'name': 'Buyer Bob', 'role': 'retail_buyer', 'password': 'test'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/request-otp', json={'phone_number': c_phone, 'role': 'retail_buyer'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/verify-otp', json={'phone_number': c_phone, 'otp': '123456'})
    customer_token = r.json()['access_token']
    headers_customer = {'Authorization': f'Bearer {customer_token}'}

    print('\n--- 5. Marketplace / Get Product ---')
    r = httpx.get(f'{BASE_URL}/api/v1/products', headers=headers_customer)
    products = r.json()
    print('Found Products:', len(products))
    assert any(p['id'] == product['id'] for p in products)

    print('\n--- 8. Checkout Order ---')
    order_data = {'items': [{'product_id': product['id'], 'quantity': 5.0}]}
    r = httpx.post(f'{BASE_URL}/api/v1/orders', json=order_data, headers=headers_customer)
    order = r.json()
    print('Order Created:', order.get('id', order))

    print('\n--- 9. Customer My Orders ---')
    r = httpx.get(f'{BASE_URL}/api/v1/orders', headers=headers_customer)
    orders_c = r.json()
    print('Customer Orders:', len(orders_c))
    assert any(o['id'] == order['id'] for o in orders_c)

    print('\n--- 10. Farmer My Orders ---')
    r = httpx.get(f'{BASE_URL}/api/v1/orders', headers=headers_farmer)
    orders_f = r.json()
    print('Farmer Orders:', len(orders_f))
    assert any(o['id'] == order['id'] for o in orders_f)

    print('\n--- 11. Unrelated Farmer Orders ---')
    f2_phone = f'+919999{random.randint(100000, 999999)}'
    r = httpx.post(f'{BASE_URL}/api/v1/auth/request-otp', json={'phone_number': f2_phone, 'role': 'farmer'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/verify-otp', json={'phone_number': f2_phone, 'otp': '123456'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/register', json={'phone_number': f2_phone, 'name': 'Farmer 2', 'role': 'farmer', 'password': 'test'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/request-otp', json={'phone_number': f2_phone, 'role': 'farmer'})
    r = httpx.post(f'{BASE_URL}/api/v1/auth/verify-otp', json={'phone_number': f2_phone, 'otp': '123456'})
    f2_token = r.json()['access_token']
    r = httpx.get(f'{BASE_URL}/api/v1/orders', headers={'Authorization': f'Bearer {f2_token}'})
    orders_f2 = r.json()
    print('Unrelated Farmer Orders:', len(orders_f2))
    assert not any(o['id'] == order['id'] for o in orders_f2)

    print('\n--- 12. AI Request (English) ---')
    ai_req = {'text': 'I want to buy 10kg potatoes', 'language': 'en', 'context': {}, 'history': []}
    r = httpx.post(f'{BASE_URL}/api/v1/ai/chat', json=ai_req, headers=headers_customer)
    print('AI Res (EN):', r.json())

    print('\n--- 12. AI Request (Hindi) ---')
    ai_req2 = {'text': 'मुझे 50 किलो टमाटर बेचने हैं', 'language': 'hi', 'context': {}, 'history': []}
    r = httpx.post(f'{BASE_URL}/api/v1/ai/chat', json=ai_req2, headers=headers_farmer)
    print('AI Res (HI):', r.json())

test_flow()
