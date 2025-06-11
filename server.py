# # server.py

# from flask import Flask, request, jsonify
# from openai import OpenAI

# app = Flask(__name__)

# # إعداد العميل
# api_key = "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"
# client = OpenAI(
#     base_url="https://openrouter.ai/api/v1",
#     api_key=api_key
    
# )

# # بداية الرسائل
# messages = [{"role": "system", "content": "أنت مساعد مفيد يتحدث العربية بطلاقة."}]

# @app.route('/chat', methods=['POST'])
# def chat():
#     global messages
#     data = request.json
#     user_input = data.get('message')

#     if not user_input:
#         return jsonify({'error': 'No message provided'}), 400

#     # لو الرابط صورة
#     if user_input.startswith('http'):
#         content = [
#             {"type": "text", "text": "ما محتوى هذه الصورة؟"},
#             {"type": "image_url", "image_url": {"url": user_input}}
#         ]
#     else:
#         content = user_input

#     # إضافة للرسائل
#     messages.append({"role": "user", "content": content})

#     try:
#         response = client.chat.completions.create(
#             model="qwen/qwen2.5-vl-72b-instruct:free",
#             messages=messages
#         )

#         bot_reply = response.choices[0].message.content
#         messages.append({"role": "assistant", "content": bot_reply})

#         return jsonify({'reply': bot_reply})

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000)







# # server.py

# from flask import Flask, request, jsonify
# from openai import OpenAI

# app = Flask(__name__)

# # إعداد العميل
# api_key = "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"
# client = OpenAI(
#     base_url="https://openrouter.ai/api/v1",
#     api_key=api_key
# )

# # بداية الرسائل
# messages = [{"role": "system", "content": "أنت صديق ودود وذكي تجيب على الأسئلة بطريقة طبيعية ومفيدة باللغة العربية."}]

# @app.route('/chat', methods=['POST'])
# def chat():
#     global messages
#     data = request.json
#     user_input = data.get('message')

#     if not user_input:
#         return jsonify({'error': 'No message provided'}), 400

#     # لو الرابط صورة
#     if user_input.startswith('http'):
#         content = [
#             {"type": "text", "text": "ما محتوى هذه الصورة؟"},
#             {"type": "image_url", "image_url": {"url": user_input}}
#         ]
#     else:
#         content = user_input

#     # إضافة للرسائل
#     messages.append({"role": "user", "content": content})

#     # الاحتفاظ بآخر 6 رسائل فقط (لتحسين الأداء والطبيعية)
#     if len(messages) > 6:
#         messages = [messages[0]] + messages[-5:]

#     try:
#         response = client.chat.completions.create(
#             model="mistralai/mixtral-8x7b-instruct",   # موديل دردشة أقوى
#             messages=messages,
#             temperature=0.7,   # يخليه واقعي أكثر (مزيج إبداعي ومنطقي)
#             max_tokens=1000
#         )

#         bot_reply = response.choices[0].message.content.strip()
#         messages.append({"role": "assistant", "content": bot_reply})

#         return jsonify({'reply': bot_reply})

#     except Exception as e:
#         return jsonify({'error': str(e)}), 500

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5000)






# server.py

from flask import Flask, request, jsonify
from openai import OpenAI

app = Flask(__name__)

# إعداد العميل
api_key = "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"
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=api_key
)

# بداية الرسائل
messages = [{
    "role": "system",
    "content": "أنت صديق ذكي تتحدث العربية وتحب أن تشرح ببساطة وكأنك تتحدث مع صديق، بإجابات قصيرة وواضحة وسريعة."
}]

@app.route('/chat', methods=['POST'])
def chat():
    global messages
    data = request.json
    user_input = data.get('message')

    if not user_input:
        return jsonify({'error': 'No message provided'}), 400

    # لو الرابط صورة
    if user_input.startswith('http'):
        content = [
            {"type": "text", "text": "ما محتوى هذه الصورة؟"},
            {"type": "image_url", "image_url": {"url": user_input}}
        ]
    else:
        content = user_input

    # إضافة للرسائل
    messages.append({"role": "user", "content": content})

    # الاحتفاظ بآخر 6 رسائل فقط (لتحسين الأداء والطبيعية)
    if len(messages) > 6:
        messages = [messages[0]] + messages[-5:]

    try:
        response = client.chat.completions.create(
            model="openchat/openchat-7b:free",   # موديل دردشة سريع وبشري أكتر
            messages=messages,
            temperature=0.7,   # يخليه طبيعي أكتر
            max_tokens=500,    # أسرع رد وأقصر
            top_p=0.9
        )

        bot_reply = response.choices[0].message.content.strip()
        messages.append({"role": "assistant", "content": bot_reply})

        return jsonify({'reply': bot_reply})

    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
