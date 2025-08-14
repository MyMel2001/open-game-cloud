docker run -it -d \
  --gpus all \
  --net=host \
  --device /dev/dri \
  --device /dev/input \
  -v /run/user/1000/pulse:/run/user/1000/pulse \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  -v $HOME/.config/sunshine:/home/gamer/.config/sunshine \
  game-stream-vnc
