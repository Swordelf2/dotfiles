#/usr/bin/bash

export OPENROUTER_API_KEY=$(xargs < ~/.local/openrouter_key)
# aider --model openrouter/google/gemini-2.5-pro
aider --model openrouter/qwen/qwen3-coder

