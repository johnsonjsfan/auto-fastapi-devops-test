# =================================================================
# Stage 1: Builder - 安裝依賴
# 使用 slim 基礎映像，並安裝編譯工具
# =================================================================
FROM python:3.10-slim AS builder

# 設置工作目錄
WORKDIR /app

# 安裝必要的系統依賴 (例如：用於某些 Python 庫的編譯器)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 複製依賴文件並安裝
COPY requirements.txt .
# 使用 --user 安裝，將依賴安裝到 /root/.local/lib
RUN pip install --user -r requirements.txt

# =================================================================
# Stage 2: Runner - 運行環境
# 僅複製運行所需的內容，確保最小體積和安全性
# =================================================================
FROM python:3.10-slim AS runner

# 設置工作目錄
WORKDIR /app

# 設置非 root 用戶 (最佳實踐)
# 雖然本例中為了簡化，我們仍使用 root 執行，但建議在實際生產環境中創建並切換用戶
# RUN useradd --user appuser
# USER appuser

# 複製 Stage 1 的依賴庫到 /root/.local
# 這是最關鍵的步驟，確保運行環境擁有所有已編譯的庫
COPY --from=builder /root/.local /root/.local

# 複製專案原始碼
COPY main.py .

# 設置環境變數，確保輸出流即時顯示
ENV PYTHONUNBUFFERED=1
# 確保系統知道去哪裡找 Python 庫
ENV PATH="/root/.local/bin:$PATH"

# 暴露應用程式端口
EXPOSE 8000

# 啟動 Uvicorn 服務
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]