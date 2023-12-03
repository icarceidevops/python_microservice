#! /bin/env python
""" Answering module"""
import os
from decouple import config # type: ignore
from openai import OpenAI


OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY",config("OPENAI_API_KEY", default="no key"))
client = OpenAI(api_key=OPENAI_API_KEY)


def q_a(request: str, as_a: str = "normal human"):
    """OpenAi - chatGPT answer

    param request: question / work to chatGPT
    param as_a: as who we like to answer
    return: response from chatGPT
    """
    answer = None
    try:
        # pylint: disable=invalid-name
        completion = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": f"You are a {as_a}"},
                {"role": "user", "content": request},
            ],
        )
        answer = completion.choices[0].message.content
    # pylint: disable=broad-except
    except Exception as e:
        print(f"An exception has occured: {e}")

    return answer


if __name__ == "__main__":
    print(q_a("Give me qoute of the day - fast please", "You are a outstanding philosopher"))
