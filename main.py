from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    """
    健康檢查接口，位於根路徑。
    """
    return {"status": "ok"}

@app.get("/health")
def health_check():
    return {"status": "ok"}