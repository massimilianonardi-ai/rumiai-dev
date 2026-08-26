from fastapi import FastAPI, Request, Response
import requests

app = FastAPI()

OLLAMA_URL = "http://ollama.ai:11434"


@app.api_route("/v1/{path:path}", methods=["GET", "POST", "PUT", "PATCH", "DELETE"])
async def proxy(path: str, request: Request):
    url = f"{OLLAMA_URL}/v1/{path}"

    headers = {
        k: v
        for k, v in request.headers.items()
        if k.lower() not in ("host", "content-length")
    }

    body = await request.body()

    response = requests.request(
        method=request.method,
        url=url,
        headers=headers,
        data=body,
        timeout=300,
    )

    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type=response.headers.get("content-type", "application/json"),
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=2000)
