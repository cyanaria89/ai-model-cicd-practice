FROM python:3.10
RUN pip install fastapi uvicorn scikit-learn joblib numpy pandas seaborn matplotlib
COPY app.py /app/app.py
COPY model.pkl /app/model.pkl
WORKDIR /app
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
