from fastapi import FastAPI
from v1.routers import router
from mangum import Mangum

app = FastAPI(title='Test API',
              description='Testing FAST API deployment on Lambda with Terraform',
              root_path="/staging",)
app.include_router(router, prefix="/v1")


@app.get("/")
def read_root():
    return {"Hello and Good evening": "We're live"}


# to make it work with Amazon Lambda, we create a handler object
handler = Mangum(app=app)
