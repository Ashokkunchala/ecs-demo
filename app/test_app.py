from app import app

def test_health():
    c=app.test_client(); r=c.get('/health')
    assert r.status_code==200
    assert r.json['status']=='healthy'

def test_root():
    c=app.test_client(); r=c.get('/')
    assert r.status_code==200
    assert r.json['service']=='ecs-demo'
