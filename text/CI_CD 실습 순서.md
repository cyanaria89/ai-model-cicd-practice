# 1. 모델 파일 생성 → Docker 이미지 생성 → Docker Compose 실행

1-1. 실습 폴더 생성

```bash
mkdir -p /home/리눅스계정/practice
cd /home/리눅스계정/practice
```

---

1-2. train.py 생성

```python
import numpy as np
import pickle
from sklearn.ensemble import RandomForestClassifier

X = np.random.randn(200, 1)
y = (X[:, 0] > 0).astype(int)

model = RandomForestClassifier()
model.fit(X, y)

with open("model.pkl", "wb") as f:
    pickle.dump(model, f)

np.save("reference.npy", X)

print("model.pkl, reference.npy 생성 완료")
```

---

1-3. app.py 생성

```python
from fastapi import FastAPI
import pickle
import numpy as np

app = FastAPI()

with open("model.pkl", "rb") as f:
    model = pickle.load(f)

@app.get("/")
def home():
    return {"message": "AI Model API is running"}

@app.get("/predict")
def predict(value: float):
    X = np.array([[value]])
    pred = model.predict(X)[0]
    return {
        "input": value,
        "prediction": int(pred)
    }
```

---

1-4. requirements.txt 생성

```Plain text
fastapi
uvicorn
scikit-learn
numpy
joblib
pandas
seaborn
matplotlib
```

---

1-5. Dockerfile 생성

```Dockerfile
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

1-6. Docker 이미지 생성

```bash
$ docker build -t ai-model-api:latest .

# Docker Hub 이름으로 태그 변경:
$ docker tag ai-model-api:latest 도커계정/레포지토리_docker:latest

# 확인
$ docker images
```

---

1-7. Docker Hub 로그인 및 Push

# Docker Hub에 Repository 생성:
: https://hub.docker.com  로그인  (웹, 터미널 모두 연결 필요)

# 웹에서…도커 허브에 Repositories 생성
→ Create repository
→ Repository Name: 레포지토리_docker
→ Visibility: Public 또는 Private
→ Create

# 터미널에서 로그인

```bash
$ docker login
--> Your one-time device confirmation code is: 생성된 코드
```

위 코드 https://login.docker.com/activate 입력하여 승인
+ 웹에서 로그인 했을 경우 바로 Login Successed 되는 경우도 있음

```bash
$ docker info | grep Username      # 로그인 확인 
```
예) Username: bliss009
+ 나오지 않는 경우도 있음

# 도커 푸시

```bash
$ docker push 도커계정/레포지토리_docker:latest
```

---

1-8. docker-compose.yml 생성

```yaml
services:
  ai-model-api:
    image: bliss009/bliss_docker:latest
    container_name: ai-model-api
    ports:
      - "8000:8000"
    restart: always
```

---

1-9. 실행

```bash
# 기존 컨테이너가 있으면 삭제:
$ docker rm -f ai-model-api || true

# 실행
$ docker compose up -d
$ docker ps

# 모델 동작 결과 확인
$ curl http://localhost:8000/
$ curl http://localhost:8000/predict?value=1.5

# 컨테이너 중지 / 삭제
$ docker stop ai-model-api
$ docker rmi ai-model-api:latest또는 docker rmi ID
$ docker rm -f ai-model-api || true
```