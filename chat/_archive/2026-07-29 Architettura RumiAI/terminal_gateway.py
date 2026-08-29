import requests

from config import CORE_AI_URL, MODEL


def ask(prompt: str) -> str:
    response = requests.post(
        f"{CORE_AI_URL}/v1/chat/completions",
        json={
            "model": MODEL,
            "messages": [
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        },
        timeout=300
    )

    response.raise_for_status()

    data = response.json()

    return data["choices"][0]["message"]["content"]
