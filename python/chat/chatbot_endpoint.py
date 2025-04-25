# -*- coding: utf-8 -*-
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from chat import chat_with_llm
from translator import translate_text

app = FastAPI(default_response_class=JSONResponse)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    message: str
    language: str

class ChatResponse(BaseModel):
    response: str

    class Config:
        # Emit real Unicode (no \u escapes)
        json_dumps = lambda v, *, default: __import__('json').dumps(v, ensure_ascii=False)

@app.post("/chat", response_model=ChatResponse)
def chat_endpoint(request: ChatRequest):
    try:
        print(f"Received message: {request.message}")
        # 1) Translate inbound to English if needed
        lang = request.language.lower()
        if lang == "sinhala":
            prompt_en = translate_text(request.message, "si", "en")
            print(prompt_en)
        elif lang == "tamil":
            prompt_en = translate_text(request.message, "ta", "en")
            print(prompt_en)
        else:
            prompt_en = request.message

        # 2) Get LLM response in English
        resp_en = chat_with_llm(prompt_en)

        # 3) Translate response back to requested language
        if lang == "sinhala":
            final = translate_text(resp_en, "en", "si")
        elif lang == "tamil":
            final = translate_text(resp_en, "en", "ta")
        else:
            final = resp_en

        print(final)

        # 4) Return JSONResponse with explicit UTF-8 charset
        return JSONResponse(
            content={"response": final},
            media_type="application/json; charset=utf-8"
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
