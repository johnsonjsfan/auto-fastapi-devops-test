# =================================================================
# Stage 1: Builder - 安裝依賴
# 使用 slim 基礎映像，並安裝編譯工具
# =================================================================
FROM python:3.10-slim AS builder

# 設置工作目錄
WORKDIR /app

# 安裝必要的系統依賴 (例如：用於 wheel 構建的 gcc)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 複製依賴文件並安裝
COPY requirements.txt .
# 使用 --user 安裝到 /root/.local，避免權限問題
RUN pip install --user -r requirements.txt

# =================================================================
# Stage 2: Runner - 運行環境
# 僅複製運行所需的內容，確保最小體積和安全性
# =================================================================
FROM python:3.10-slim AS runner

# 設置工作目錄
WORKDIR /app

# 設置環境變數，確保 Python 能夠找到 Stage 1 安裝的依賴
ENV PATH="/root/.local/bin:$PATH"
ENV PYTHONPATH="/root/.local/lib/python3.10/site-packages:$PYTHONPATH"

# 複製 Stage 1 的依賴庫
COPY --from=builder /root/.local /root/.local

# 複製專案原始碼
COPY main.py .

# 暴露應用程式監聽的端口
EXPOSE 8000

# 啟動 Uvicorn 服務
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]