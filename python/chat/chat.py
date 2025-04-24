from langchain.memory import ConversationBufferMemory
from gemini import initialize_gemini
from summarize import summarize_conversation

memory = ConversationBufferMemory(return_messages=True)

def chat_with_llm(user_message: str):
    
    try:
        history = memory.load_memory_variables({})
        history_context = "\n".join([f"{m.type}: {m.content}" for m in history.get("history", [])])
        

        final_prompt = f"""You are a knowledgeable and enthusiastic eco-friendly living assistant.

        Your personality:
        - Passionate about environmental sustainability
        - Encouraging and supportive
        - Makes eco-friendly living feel accessible and achievable
        - Responds warmly to greetings

        Current conversation:
        User query: {user_message}
        Previous chat history: {history_context}

        If the user's message is a greeting (like "hi", "hello", "how are you"):
        - Respond with a friendly, eco-conscious greeting

        Otherwise, provide helpful guidance about sustainable living with:
        1. Practical eco-friendly tips and alternatives
        2. Simple explanations of environmental concepts
        3. Specific advice for reducing plastic use
        4. Actionable steps for sustainable lifestyle changes
        5. Links to reliable resources when relevant

        Response:"""

        model = initialize_gemini()
        chat_session = model.start_chat()

        final_response = chat_session.send_message(final_prompt)

        conversation_summary = summarize_conversation(user_message, final_response.text, model)
        
        memory.save_context(
            {"input": f"{user_message}"}, 
            {"output": f"{conversation_summary}"}
        )
        
        return final_response.text
        
    except Exception as e:
        raise Exception(f"Error in chat processing: {str(e)}")