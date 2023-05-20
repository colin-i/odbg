
tmux new-session -s odbg -n 'window' -d && \
name=odbg`tmux list-sessions -f"#{==:#{session_name},odbg}" -F "#{session_id}"` && \
tmux rename-session -t odbg ${name} && \
tmux send-keys -t ${name}:window.0 'pwd' C-j && \
tmux split-window -h && \
tmux send-keys -t ${name}:window.1 'uname' C-j && \
tmux select-pane -t ${name}:window.0 && \
tmux attach -t ${name}
