from fastapi import FastAPI
from routes.routers import router
from mangum import Mangum

app = FastAPI(title='Test API',
              description='Testing FAST API deployment on Lambda with Terraform')
app.include_router(router)


@app.get("/")
def read_root():
    return {"Welcome to the dance": "We're live"}


# to make it work with Amazon Lambda, we create a handler object
handler = Mangum(app=app)
