
tmux -f t.conf new-session -s odbg -n 'window' -d ./test && \
name=odbg`tmux list-sessions -f"#{==:#{session_name},odbg}" -F "#{session_id}"` && \
tmux rename-session -t odbg ${name} && \
tmux split-window -d -t ${name}:window.0 ./test ${name} && \
tmux kill-pane -t ${name}:window.0 && \
tmux attach -t ${name}
