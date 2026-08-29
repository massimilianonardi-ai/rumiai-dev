from terminal_gateway import ask

while True:
    prompt = input("RumiAI > ")

    if prompt.lower() in ("exit", "quit"):
        break

    print()
    print(ask(prompt))
    print()
