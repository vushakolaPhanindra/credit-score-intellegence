# 💳 Credit Score Intelligence — AI-Powered Financial Risk Assessment

Credit Score Intelligence is an advanced AI/ML platform that predicts credit scores, explains ML decisions using SHAP, and generates natural-language reasoning using LLMs.  
It includes a FastAPI backend, a Streamlit frontend, and a production-ready Docker + Nginx deployment.

---

## 🚀 Overview

This project predicts credit score categories:

- 🟢 **Good**
- 🟡 **Standard**
- 🔴 **Poor**

It offers:

- Real-time ML predictions  
- SHAP explainability  
- LLM-based reasoning  
- Professional UI  
- Fully containerized deployment  

---

## 🌟 Features

### 🔮 ML-Based Credit Score Prediction
- Robust Random Forest classifier  
- Uses 14+ financial features  
- High accuracy  

### 🧠 Explainable AI (XAI)
- SHAP value graphs  
- Feature-level contribution  
- Transparent “Why this score?”  

### 🤖 LLM-Based Natural Language Rationale
Generates human-like explanations such as:  
> “Your score is Good because your credit utilization is low and income is stable.”

### 🖥️ Streamlit Dashboard
- Quick prediction  
- Detailed explainability  
- API health indicator  

### ⚡ FastAPI Backend
- `/predict`, `/explain`, `/health`  
- Interactive Swagger docs  

### 🐳 Docker + Nginx Deployment
- Fast deployment  
- Reverse proxy  
- HTTPS-ready  

---

## 🧬 Architecture

```
               ┌────────────────────────┐
               │       User (Web)       │
               └────────────┬───────────┘
                            │
                            ▼
                  ┌──────────────────┐
                  │      NGINX       │
                  │ (Reverse Proxy)  │
                  └───────┬──────────┘
       ┌───────────────────┼─
       │                   │                   
       ▼                   ▼                   
┌─────────────┐    ┌─────────────┐             
│ Streamlit UI│    │ FastAPI API │             
│ Port: 8501  │    │ Port: 8000  │             
└──────┬──────┘    └──────┬──────┘             
       │                  │                    
       └──────────┬───────┘                    
                  ▼                            
         ┌──────────────────┐                  
         │ ML Model (.pkl)  │                  
         │ SHAP Explainer   │                  
         └──────────────────┘
```

---

## 🛠️ Tech Stack

### 🧩 Backend
[![FastAPI](https://img.shields.io/badge/FastAPI-Framework-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
![Uvicorn](https://img.shields.io/badge/Uvicorn-ASGI_Server-4B8BBE?logo=python&logoColor=white)
![scikit-learn](https://img.shields.io/badge/scikit--learn-ML_Library-F7931E?logo=scikitlearn&logoColor=white)
![SHAP](https://img.shields.io/badge/SHAP-Explainable_AI-red)
![joblib](https://img.shields.io/badge/joblib-Model_Serialization-00A6D6)
![LangChain](https://img.shields.io/badge/LangChain-LLM_Framework-1E90FF)
![OpenAI](https://img.shields.io/badge/OpenAI-GPT_Model-412991?logo=openai&logoColor=white)

---

### 🎨 Frontend
![Streamlit](https://img.shields.io/badge/Streamlit-Web_App-FF4B4B?logo=streamlit&logoColor=white)
![Plotly](https://img.shields.io/badge/Plotly-Interactive_Charts-3F4F75?logo=plotly&logoColor=white)
![Matplotlib](https://img.shields.io/badge/Matplotlib-Data_Visualization-013243?logo=python&logoColor=white)

---

### 🏗 Infrastructure
![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED?logo=docker&logoColor=white)
![Docker Compose](https://img.shields.io/badge/Docker_Compose-Orchestration-2496ED?logo=docker&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-Reverse_Proxy-009639?logo=nginx&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-VPS_Server-E95420?logo=ubuntu&logoColor=white)



---

## ⚡ Quick Start

### Prerequisites
- Python **3.11+**  
- pip  
- Docker (optional, recommended)  

---

## 🧩 Local Installation

```bash
git clone https://github.com/vushakolaPhanindra/credit-score-intellegence
cd credit-score-intellegence
pip install -r requirements.txt
export OPENAI_API_KEY="your-api-key"
```

### Run the backend:

```bash
cd src
uvicorn api:app --host 0.0.0.0 --port 8000 --reload
```

### Run the frontend:

```bash
cd ui
streamlit run app.py
```

---

## 🐳 Docker Deployment (Recommended)

```bash
docker compose build
docker compose up -d
```

View logs:

```bash
docker compose logs -f
```

Access:

- **Streamlit UI:** http://localhost:8501  
- **API Docs:** http://localhost:8000/docs  

---

## ☁️ Cloud Deployment (Vultr / AWS / Azure)

### Complete Deployment Guides
📘 **VULTR_DEPLOYMENT.md**  
📋 **DEPLOYMENT_CHECKLIST.md**  
🔐 **SECRETS_MANAGEMENT.md**

### Quick Deployment on Vultr

```bash
ssh root@YOUR_SERVER_IP
nano /opt/credit-score-intellegence/.env
docker compose restart
```

Or use automatic installer:

```bash
bash <(curl -s https://raw.githubusercontent.com/vushakolaPhanindra/credit-score-intellegence/main/deploy.sh)
```

---

## 📁 Project Structure

```
credit-score-intelligence/
├── src/
│   ├── api.py
│   ├── preprocess.py
│   ├── train_model.py
│   ├── explain_model.py
│   ├── generate_rationale.py
│   └── utils.py
├── ui/
│   └── app.py
├── data/
│   ├── credit_score.csv
│   └── processed_credit.csv
├── models/
│   └── credit_model.pkl
├── outputs/
│   ├── plots/
│   ├── shap_summaries/
│   └── rationales/
├── notebooks/
│   └── exploration.ipynb
├── docker-compose.yml
├── nginx/
│   └── nginx.conf
└── README.md
```

---

## 📡 Sample API Response

```json
{
  "category": "Good",
  "confidence": 0.847,
  "feature_importance": {
    "Income": 0.156,
    "Credit_Utilization_Ratio": 0.134
  },
  "rationale": "Your credit score is predicted to be Good due to high income and low utilization."
}
```

---
---

## 🏆 Built for Hack This Fall 2025 — And Beyond

This project is more than just a credit score predictor — it is a step toward democratizing financial insights using Explainable AI.  
Our goal is to make credit scoring **transparent, fair, and accessible**, especially for individuals who struggle to understand why their financial profile is judged a certain way.

With ML + SHAP + LLMs, this system bridges the gap between  
**raw data → predictions → human reasoning**.

Built with passion, precision, and the spirit of innovation for **Hack This Fall 2025**.  
Thank you for reviewing our project! 🚀💙


## ⭐ Support

If you like this project, please **star ⭐ the repository**.

