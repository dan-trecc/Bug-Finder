import os
import subprocess
from google import genai
from google.genai import types
from dotenv import load_dotenv

# --- 1. CONFIGURATION ---
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

if not GEMINI_API_KEY:
    raise ValueError("API Key missing! Ensure your .env file exists and contains GEMINI_API_KEY.")

# The modern SDK uses a centralized Client object.
# It automatically picks up GEMINI_API_KEY from the environment, 
# but passing it explicitly here keeps it highly deterministic.
client = genai.Client(api_key=GEMINI_API_KEY)

# Script tracks execution in the current directory (Godot project root)
GODOT_PROJECT_ROOT = os.path.abspath(".")

# --- 2. THE AGENT'S TOOLS ---
def save_gdscript(file_name: str, directory_path: str, code_content: str) -> str:
    """Saves or overwrites a GDScript file inside the specified project directory."""
    try:
        clean_dir_path = directory_path.lstrip('./').lstrip('/')
        full_dir = os.path.join(GODOT_PROJECT_ROOT, clean_dir_path)
        os.makedirs(full_dir, exist_ok=True)
        
        full_path = os.path.join(full_dir, file_name)
        with open(full_path, "w", encoding="utf-8") as f:
            f.write(code_content)
            
        return f"Successfully saved script to: {full_path}"
    except Exception as e:
        return f"Failed to save file due to error: {str(e)}"

def list_project_files(directory_path: str = ".") -> str:
    """Scans a directory in the Godot project and returns a list of files."""
    try:
        clean_dir_path = directory_path.lstrip('./').lstrip('/')
        full_dir = os.path.join(GODOT_PROJECT_ROOT, clean_dir_path)
        
        if not os.path.exists(full_dir):
            return f"Directory not found: {full_dir}"
        
        tree = []
        for root, dirs, files in os.walk(full_dir):
            dirs[:] = [d for d in dirs if not d.startswith('.') and d != "addons"]
            level = root.replace(full_dir, '').count(os.sep)
            indent = ' ' * 4 * level
            tree.append(f"{indent}{os.path.basename(root)}/")
            subindent = ' ' * 4 * (level + 1)
            for f in files:
                if f.endswith(('.gd', '.tscn', '.tres')): 
                    tree.append(f"{subindent}{f}")
                    
        return "\n".join(tree)
    except Exception as e:
        return f"Failed to list directory: {str(e)}"

def check_syntax(script_path: str) -> str:
    """Runs Godot's headless compiler to check a GDScript file for syntax errors."""
    try:
        clean_path = script_path.lstrip('./').lstrip('/')
        full_path = os.path.join(GODOT_PROJECT_ROOT, clean_path)
        
        if not os.path.exists(full_path):
            return f"File not found: {full_path}"

        command = ["godot", "--headless", "--check-only", full_path]
        result = subprocess.run(command, capture_output=True, text=True)
        output = result.stdout + "\n" + result.stderr
        
        if result.returncode == 0 and "Parse Error" not in output:
            return f"Syntax check passed cleanly for {script_path}!"
        else:
            return f"Syntax errors found in {script_path}. Please fix these:\n{output}"
            
    except FileNotFoundError:
        return "Error: 'godot' executable not found. Ensure Godot is in your system PATH."
    except Exception as e:
        return f"Syntax check failed to execute: {str(e)}"

# --- 3. MODEL CONFIGURATION & INITIALIZATION ---
# Group your Python tools together
coding_tools = [save_gdscript, list_project_files, check_syntax]

# In the new SDK, system instructions and tools live inside GenerateContentConfig
config = types.GenerateContentConfig(
    system_instruction=(
        "You are an expert Godot 4 engine co-developer specializing in GDScript.\n"
        "Your workflow is strictly as follows:\n"
        "1. Use 'list_project_files' to understand the current directory structure and avoid overwriting existing logic without checking.\n"
        "2. Write clean, static-typed GDScript code.\n"
        "3. Use 'save_gdscript' to write the file directly to the user's workspace.\n"
        "4. ALWAYS use 'check_syntax' on the file you just saved. If the syntax check returns an error, fix the code, save it again, and re-check until it passes.\n"
        "Do not ask the user to verify the code manually. Verify it yourself using the compiler tool."
    ),
    tools=coding_tools,
)

# --- 4. EXECUTION LOOP ---
# Start the stateful chat helper using the client object
# --- 4. EXECUTION LOOP ---
# Start the stateful chat helper using the client object
chat = client.chats.create(
    model="gemini-2.5-flash",
    config=config
)

print("="*60)
print("🤖 Godot GDScript AI Agent Initialized.")
print("Type 'exit' or 'quit' to close the program.")
print("="*60)

while True:
    # This prompts you in the terminal and waits for your input
    user_prompt = input("\nWhat should we build or modify next? (or type 'exit'): ")
    
    # Break the loop if you want to quit
    if user_prompt.lower() in ['exit', 'quit']:
        print("Goodbye!")
        break
        
    # Skip empty inputs
    if not user_prompt.strip():
        continue

    print("\nSending request to agent...")
    print("Reasoning, exploring files, and validating syntax. Please wait...")
    
    try:
        # Send your terminal prompt directly to Gemini
        response = chat.send_message(user_prompt)
        
        print("\n[Agent Response]:")
        print(response.text)
        print("-" * 60)
    except Exception as e:
        print(f"\nAn error occurred during execution: {str(e)}")