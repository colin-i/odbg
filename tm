
tmux -f t.conf new-session -s odbg -n 'window' -d ./test && \
name=odbg`tmux list-sessions -f"#{==:#{session_name},odbg}" -F "#{session_id}"` && \
tmux rename-session -t odbg ${name} && \
tmux split-window -d -t ${name}:window.0 ./test ${name} && \
tmux kill-pane -t ${name}:window.0 && \
tmux split-window -dh -l 75% -t ${name}:window.0 edor && \
tmux attach -t ${name}
