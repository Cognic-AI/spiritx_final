from langchain.memory import ConversationBufferMemory
from gemini import initialize_gemini
from summarize import summarize_conversation

memory = ConversationBufferMemory(return_messages=True)

def chat_with_llm(user_message: str):
    
    try:
        history = memory.load_memory_variables({})
        history_context = "\n".join([f"{m.type}: {m.content}" for m in history.get("history", [])])
        
        final_prompt = f"""You are a knowledgeable and enthusiastic sporting assistant.

        Your personality:
        - Passionate about sports and fitness
        - Encouraging and supportive
        - Makes sports feel accessible and enjoyable
        - Responds warmly to greetings

        Current conversation:
        User query: {user_message}
        Previous chat history: {history_context}

        If the user's message is a greeting (like "hi", "hello", "how are you"):
        - Respond with a friendly, sports-related greeting

        Otherwise, provide helpful guidance about sports with:
        1. Practical tips for improving performance
        2. Advice on training and fitness routines
        3. Information on sports rules and strategies
        4. Suggestions for sports equipment and gear
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