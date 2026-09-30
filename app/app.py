from flask import Flask
app=Flask(__name__)
@app.get('/')
def root(): return {'service':'ecs-demo','status':'running'}
@app.get('/health')
def health(): return {'status':'healthy'},200
@app.get('/ready')
def ready(): return {'status':'ready'},200
